

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/network/supabase_client.dart';
import '../models/post_model.dart';

class FeedRepository {
  Future<List<PostModel>> fetchPosts({
    required int offset,
    int limit = AppConstants.pageSize,
  }) async {
    print('[Feed] Fetching from offset $offset');
    try {
      final data = await supabase
          .from(SupabaseConstants.postsTable)
          .select()
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final items = <PostModel>[];
      for (final item in data as List) {
        items.add(PostModel.fromJson(item as Map<String, dynamic>));
      }
      
      print('[Feed] Got ${items.length} posts');
      return items;
    } catch (e) {
      print('[Feed] Network issue fetching posts - check connection');
      rethrow;
    }
  }

  Future<Set<String>> fetchUserLikes({
    required String userId,
    required List<String> postIds,
  }) async {
    if (postIds.isEmpty) return {};

    print('[Feed] Checking likes for $userId (${postIds.length} posts)');
    try {
      final res = await supabase
          .from(SupabaseConstants.userLikesTable)
          .select('post_id')
          .eq('user_id', userId)
          .inFilter('post_id', postIds);

      final liked = <String>{};
      for (final row in res as List) {
        liked.add(row['post_id'] as String);
      }
      
      print('[Feed] Found ${liked.length} likes');
      return liked;
    } catch (e) {
      print('[Feed] Error checking likes - offline?');
      rethrow;
    }
  }

  Future<void> toggleLike({
    required String postId,
    required String userId,
  }) async {
    print('[Feed] Toggling like for post $postId');
    try {
      await supabase.rpc(
        SupabaseConstants.toggleLikeRpc,
        params: {
          'p_post_id': postId,
          'p_user_id': userId,
        },
      );
    } catch (e) {
      print('[Feed] RPC failed - check network');
      rethrow;
    }
  }

  Future<bool> isPostLikedByUser({
    required String postId,
    required String userId,
  }) async {
    final res = await supabase
        .from(SupabaseConstants.userLikesTable)
        .select('post_id')
        .eq('user_id', userId)
        .eq('post_id', postId)
        .maybeSingle();

    return res != null;
  }
}
