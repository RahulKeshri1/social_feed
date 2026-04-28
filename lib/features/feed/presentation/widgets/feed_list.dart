import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../../core/constants/app_constants.dart';
import '../../providers/feed_providers.dart';
import '../controllers/feed_controller.dart';
import 'post_card.dart';
import 'shimmer_loader.dart';

/// The scrollable list of post cards with infinite pagination.
class FeedList extends ConsumerStatefulWidget {
  final FeedState feedState;

  const FeedList({super.key, required this.feedState});

  @override
  ConsumerState<FeedList> createState() => _FeedListState();
}

class _FeedListState extends ConsumerState<FeedList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final threshold = maxScroll * AppConstants.paginationThreshold;

    if (currentScroll >= threshold) {
      ref.read(feedControllerProvider.notifier).fetchNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final posts = widget.feedState.posts;
    final isLoadingMore = widget.feedState.isLoadingMore;
    final hasMore = widget.feedState.hasMore;

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
      // +1 for loading indicator at the bottom
      itemCount: posts.length + (isLoadingMore || hasMore ? 1 : 0),
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: false, // We add our own RepaintBoundary on each card
      itemBuilder: (context, index) {
        // ── Loading footer ──
        if (index >= posts.length) {
          if (isLoadingMore) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: ShimmerPostCard(),
            );
          }
          return const SizedBox(height: 24);
        }

        // ── Post card ──
        final post = posts[index];
        return RepaintBoundary(
          child: PostCard(
            key: ValueKey(post.id),
            post: post,
          ),
        );
      },
    );
  }
}
