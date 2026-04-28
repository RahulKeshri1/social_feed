import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/image_utils.dart';
import '../../data/models/post_model.dart';
import '../../providers/feed_providers.dart';
import 'like_button.dart';

class PostCard extends ConsumerWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = MediaQuery.of(context).size.width;
    final h = w * 0.75;

    final cacheW = ImageUtils.getCacheWidth(
      context,
      displayWidth: w,
    );

    return GestureDetector(
      onTap: () => context.push('/detail', extra: post),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowDark.withValues(alpha: 0.4),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 40,
              spreadRadius: -4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPostHeader(context),
            _buildPostImage(w, h, cacheW),
            _buildEngagementSection(context, ref),
            _buildMetricsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPostHeader(BuildContext context) {
    final time = _getTimeAgo();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Social Creator',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                ),
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                ),
              ],
            ),
          ),

          // ── More Options ──
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
            iconSize: 20,
            onPressed: () {},
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildPostImage(double screenWidth, double imageHeight, int cachedImageWidth) {
    return Hero(
      tag: 'post-${post.id}',
      child: ClipRRect(
        child: CachedNetworkImage(
          imageUrl: post.mediaThumbUrl,
          width: screenWidth,
          height: imageHeight,
          fit: BoxFit.cover,
          // ── RAM Protection: constrain decoded bitmap ──
          memCacheWidth: cachedImageWidth,
          placeholder: (context, url) => Container(
            width: screenWidth,
            height: imageHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.cardDark,
                  AppColors.cardDarkElevated,
                ],
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: screenWidth,
            height: imageHeight,
            color: AppColors.cardDarkElevated,
            child: const Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: AppColors.textTertiary,
                size: 48,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEngagementSection(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Left Actions: Like, Comment, Share ──
          SizedBox(
            width: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Like Button
                Transform.scale(
                  scale: 1.1,
                  child: LikeButton(
                    isLiked: post.isLiked,
                    likeCount: 0, // Don't show count in compact view
                    onTap: () {
                      ref.read(feedControllerProvider.notifier).toggleLike(
                        post.id,
                        onError: (message) {
                          if (context.mounted) {
                            context.showErrorSnackBar(message);
                          }
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Comment Button
                IconButton(
                  icon: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: AppColors.textSecondary,
                    size: 24,
                  ),
                  onPressed: () {},
                  splashRadius: 24,
                ),
                const SizedBox(width: 8),

                // Share Button
                IconButton(
                  icon: const Icon(
                    Icons.send_outlined,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                  onPressed: () {},
                  splashRadius: 24,
                ),
              ],
            ),
          ),

          // ── Right Action: Bookmark ──
          IconButton(
            icon: const Icon(
              Icons.bookmark_outline_rounded,
              color: AppColors.textSecondary,
              size: 24,
            ),
            onPressed: () {},
            splashRadius: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Likes Count ──
          RichText(
            text: TextSpan(
              children: [
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () {},
                    child: Text(
                      '${post.likeCount} likes',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Post Content (Placeholder) ──
          Text(
            'Amazing moment captured! 📸✨',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // ── Comments Preview ──
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'View all 124 comments',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
            ),
          ),

          // ── Post Date ──
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _formatDate(post.createdAt),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo() {
    final difference = DateTime.now().difference(post.createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    }
    return 'Just now';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}

