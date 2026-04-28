import 'dart:async';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/connectivity_provider.dart';
import '../../../../core/storage/pending_likes_storage.dart';
import '../../../../core/utils/debouncer.dart';
import '../../data/models/post_model.dart';
import '../../data/repositories/feed_repository.dart';

class FeedState {
  final List<PostModel> posts;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentOffset;
  final String? error;
  final bool isOffline;
  final Set<String> pendingLikes;

  const FeedState({
    this.posts = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentOffset = 0,
    this.error,
    this.isOffline = false,
    this.pendingLikes = const {},
  });

  FeedState copyWith({
    List<PostModel>? posts,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentOffset,
    String? error,
    bool? isOffline,
    Set<String>? pendingLikes,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentOffset: currentOffset ?? this.currentOffset,
      error: error,
      isOffline: isOffline ?? this.isOffline,
      pendingLikes: pendingLikes ?? this.pendingLikes,
    );
  }
}

class FeedController extends Notifier<FeedState> {
  late final FeedRepository _repository;
  late final Debouncer _likeDebouncer;
  final Map<String, bool> _serverLikeState = {};

  @override
  FeedState build() {
    _repository = ref.read(feedRepositoryProvider);
    _likeDebouncer = Debouncer(
      delay: Duration(milliseconds: AppConstants.likeDebounceMs),
    );

    ref.onDispose(() => _likeDebouncer.dispose());

    _loadPersistedPendingLikes();

    ref.listen<AsyncValue<List<ConnectivityResult>>>(connectivityProvider, (_, async) {
      async.whenData((results) {
        final wasOffline = state.isOffline;
        final isNowOnline = results.isNotEmpty && !results.contains(ConnectivityResult.none);

        if (wasOffline && isNowOnline) {
          print('[Feed] Back online! Retrying ${state.pendingLikes.length} pending likes...');
          state = state.copyWith(isOffline: false);
          _retryPendingLikes();
        } else if (!wasOffline && !isNowOnline) {
          state = state.copyWith(isOffline: true);
        }
      });
    });

    _loadInitial();

    return const FeedState(isLoading: true);
  }

  Future<void> _loadPersistedPendingLikes() async {
    try {
      final pending = await PendingLikesStorage.loadPendingLikes();
      if (pending.isNotEmpty) {
        state = state.copyWith(pendingLikes: pending);
        
        final isOnline = ref.read(isOnlineProvider);
        if (isOnline) {
          Future.delayed(const Duration(milliseconds: 500), _retryPendingLikes);
        } else {
          state = state.copyWith(isOffline: true);
        }
      }
    } catch (e) {
      print('[Feed] Error loading pending: $e');
    }
  }

  Future<void> _loadInitial() async {
    try {
      final posts = await _repository.fetchPosts(offset: 0);
      final enriched = await _enrichWithLikes(posts);
      state = state.copyWith(
        posts: enriched,
        isLoading: false,
        hasMore: posts.length >= AppConstants.pageSize,
        currentOffset: posts.length,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load feed. Pull down to retry.',
      );
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final posts = await _repository.fetchPosts(
        offset: state.currentOffset,
      );
      final enriched = await _enrichWithLikes(posts);
      state = state.copyWith(
        posts: [...state.posts, ...enriched],
        isLoadingMore: false,
        hasMore: posts.length >= AppConstants.pageSize,
        currentOffset: state.currentOffset + posts.length,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> refresh() async {
    try {
      final posts = await _repository.fetchPosts(offset: 0);
      final enriched = await _enrichWithLikes(posts);
      state = FeedState(
        posts: enriched,
        hasMore: posts.length >= AppConstants.pageSize,
        currentOffset: posts.length,
      );
    } catch (e) {
      state = state.copyWith(error: 'Refresh failed');
    }
  }

  void toggleLike(String postId, {void Function(String message)? onError}) {
    final idx = state.posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;

    final post = state.posts[idx];
    _serverLikeState[postId] ??= post.isLiked;

    final newLiked = !post.isLiked;
    final newCount = post.likeCount + (newLiked ? 1 : -1);
    final updated = post.copyWith(
      isLiked: newLiked,
      likeCount: max(0, newCount),
    );

    final posts = List<PostModel>.from(state.posts);
    posts[idx] = updated;
    state = state.copyWith(posts: posts);

    if (state.isOffline) {
      print('[Like] Queue: $postId');
      state = state.copyWith(
        pendingLikes: {...state.pendingLikes, postId},
      );
      PendingLikesStorage.addPendingLike(postId);
      onError?.call('Offline - will sync later');
      return;
    }

    _likeDebouncer.run(postId, () async {
      try {
        final curr = state.posts.where((p) => p.id == postId).firstOrNull;
        if (curr == null) return;

        final desired = curr.isLiked;
        final server = _serverLikeState[postId] ?? false;

        if (desired != server) {
          await _repository.toggleLike(
            postId: postId,
            userId: AppConstants.userId,
          );
          _serverLikeState[postId] = desired;
          state = state.copyWith(
            pendingLikes: (state.pendingLikes..remove(postId)),
          );
          await PendingLikesStorage.removePendingLike(postId);
        }
      } catch (e) {
        print('[Like] Sync failed: $e');
        _revertLike(postId);
        await PendingLikesStorage.addPendingLike(postId);
        state = state.copyWith(
          pendingLikes: {...state.pendingLikes, postId},
        );
        onError?.call('Failed to sync like');
      }
    });
  }

  void _revertLike(String postId) {
    final idx = state.posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;

    final serverLiked = _serverLikeState[postId] ?? false;
    final post = state.posts[idx];

    final delta = serverLiked ? 1 : -1;
    final currentDelta = post.isLiked ? 1 : -1;
    final adjust = delta - currentDelta;

    final reverted = post.copyWith(
      isLiked: serverLiked,
      likeCount: max(0, post.likeCount + adjust),
    );

    final posts = List<PostModel>.from(state.posts);
    posts[idx] = reverted;
    state = state.copyWith(posts: posts);
  }

  Future<void> _retryPendingLikes() async {
    final pending = List<String>.from(state.pendingLikes);
    print('[Feed] Retry ${pending.length} pending');
    
    for (final postId in pending) {
      try {
        final curr = state.posts.where((p) => p.id == postId).firstOrNull;
        if (curr == null) {
          state = state.copyWith(pendingLikes: (state.pendingLikes..remove(postId)));
          await PendingLikesStorage.removePendingLike(postId);
          continue;
        }

        final desired = curr.isLiked;
        final server = _serverLikeState[postId] ?? false;

        if (desired != server) {
          await _repository.toggleLike(
            postId: postId,
            userId: AppConstants.userId,
          );
          _serverLikeState[postId] = desired;
        }

        state = state.copyWith(
          pendingLikes: (state.pendingLikes..remove(postId)),
        );
        await PendingLikesStorage.removePendingLike(postId);
      } catch (e) {
        print('[Retry] Failed: $e');
      }
    }
  }

  Future<List<PostModel>> _enrichWithLikes(List<PostModel> posts) async {
    if (posts.isEmpty) return posts;

    try {
      final likedIds = await _repository.fetchUserLikes(
        userId: AppConstants.userId,
        postIds: posts.map((p) => p.id).toList(),
      );

      return posts.map((post) {
        final isLiked = likedIds.contains(post.id);
        _serverLikeState[post.id] = isLiked;
        return post.copyWith(isLiked: isLiked);
      }).toList();
    } catch (_) {
      return posts;
    }
  }

  PostModel? getPost(String postId) {
    try {
      return state.posts.firstWhere((p) => p.id == postId);
    } catch (_) {
      return null;
    }
  }
}

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepository();
});

final feedControllerProvider =
    NotifierProvider<FeedController, FeedState>(FeedController.new);
