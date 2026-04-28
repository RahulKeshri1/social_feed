import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../feed/data/models/post_model.dart';
import '../../../feed/providers/feed_providers.dart';
import '../widgets/download_button.dart';
import '../widgets/tiered_image.dart';

/// Detail screen with Hero animation destination and tiered image loading.
///
/// Immediately shows the cached thumbnail, then crossfades to the 1080p
/// mobile image, with a button to download the full-res raw image.
class DetailScreen extends ConsumerWidget {
  final PostModel post;

  const DetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the feed state to get live like updates
    final feedState = ref.watch(feedControllerProvider);
    final livePost = feedState.posts.where((p) => p.id == post.id).firstOrNull ?? post;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _buildBackButton(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {},
            splashRadius: 28,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Full Screen Hero Image ──
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.55,
            pinned: false,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'post-${post.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    TieredImage(
                      thumbUrl: post.mediaThumbUrl,
                      mobileUrl: post.mediaMobileUrl,
                    ),
                    // Gradient overlay at bottom
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 120,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.9),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Content Area ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── User Info ──
                  _buildUserInfoSection(context),
                  const SizedBox(height: 24),

                  // ── Post Caption ──
                  _buildCaptionSection(context),
                  const SizedBox(height: 24),

                  // ── Engagement Buttons ──
                  _buildEngagementButtons(context, ref, livePost),
                  const SizedBox(height: 24),

                  // ── Engagement Stats ──
                  _buildEngagementStats(context, livePost),
                  const SizedBox(height: 24),

                  // ── Download Button ──
                  DownloadButton(rawUrl: post.mediaRawUrl),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.8),
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.2) ?? Colors.grey.withValues(alpha: 0.2),
            ),
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoSection(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
          ),
          child: const Center(
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 24,
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                'Followed by 12.5K',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Follow',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildCaptionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Amazing moment captured! 📸✨ This is where the post caption goes with hashtags and mentions.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildHashtag('#photography'),
            _buildHashtag('#explore'),
            _buildHashtag('#trending'),
          ],
        ),
      ],
    );
  }

  Widget _buildHashtag(String tag) {
    return Text(
      tag,
      style: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
    );
  }

  Widget _buildEngagementButtons(BuildContext context, WidgetRef ref, PostModel livePost) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildEngagementButton(
          icon: livePost.isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
          label: '${livePost.likeCount}',
          color: livePost.isLiked ? AppColors.liked : (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
          onTap: () {
            ref.read(feedControllerProvider.notifier).toggleLike(
              livePost.id,
              onError: (message) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message)),
                  );
                }
              },
            );
          },
        ),
        _buildEngagementButton(
          icon: Icons.chat_bubble_outline_rounded,
          label: '124',
          color: AppColors.textSecondary,
          onTap: () {},
        ),
        _buildEngagementButton(
          icon: Icons.send_outlined,
          label: 'Share',
          color: AppColors.textSecondary,
          onTap: () {},
        ),
        _buildEngagementButton(
          icon: Icons.bookmark_outline_rounded,
          label: 'Save',
          color: AppColors.textSecondary,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildEngagementButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementStats(BuildContext context, PostModel livePost) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Engagement Stats',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Likes', '${livePost.likeCount}'),
              _buildStatItem('Comments', '124'),
              _buildStatItem('Shares', '32'),
              _buildStatItem('Views', '2.5K'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textTertiary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
