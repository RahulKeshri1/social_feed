import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

/// A progressive image loader that shows the thumbnail immediately,
/// then crossfades to the 1080p mobile image when it finishes loading.
///
/// Flow:
/// 1. Show [thumbUrl] from disk/memory cache (instant)
/// 2. Start loading [mobileUrl] in background
/// 3. AnimatedOpacity crossfade from thumb → mobile
class TieredImage extends StatefulWidget {
  final String thumbUrl;
  final String mobileUrl;

  const TieredImage({
    super.key,
    required this.thumbUrl,
    required this.mobileUrl,
  });

  @override
  State<TieredImage> createState() => _TieredImageState();
}

class _TieredImageState extends State<TieredImage> {
  bool _mobileLoaded = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Layer 1: Thumbnail (from cache, shown immediately)
        CachedNetworkImage(
          imageUrl: widget.thumbUrl,
          fit: BoxFit.cover,
          fadeInDuration: Duration.zero,
        ),

        // Layer 2: Mobile 1080p (loads async, fades in)
        AnimatedOpacity(
          opacity: _mobileLoaded ? 1.0 : 0.0,
          duration: const Duration(
            milliseconds: AppConstants.imageCrossfadeDurationMs,
          ),
          curve: Curves.easeInOut,
          child: CachedNetworkImage(
            imageUrl: widget.mobileUrl,
            fit: BoxFit.cover,
            fadeInDuration: Duration.zero, // We handle fade ourselves
            progressIndicatorBuilder: (context, url, progress) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  // Show loading progress on top of thumb
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: _buildProgressBar(progress.progress),
                  ),
                ],
              );
            },
            imageBuilder: (context, imageProvider) {
              // Mark as loaded on next frame to trigger fade
              if (!_mobileLoaded) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() => _mobileLoaded = true);
                  }
                });
              }
              return Image(
                image: imageProvider,
                fit: BoxFit.cover,
              );
            },
            errorWidget: (context, url, error) {
              // If 1080p fails, keep showing thumbnail
              return const SizedBox.shrink();
            },
          ),
        ),

        // ── Quality badge ──
        Positioned(
          top: MediaQuery.of(context).padding.top + 60,
          right: 16,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey(_mobileLoaded),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _mobileLoaded
                    ? AppColors.success.withValues(alpha: 0.9)
                    : AppColors.scaffoldDark.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _mobileLoaded
                        ? Icons.hd_rounded
                        : Icons.photo_size_select_small_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _mobileLoaded ? 'HD' : 'Loading HD...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(double? progress) {
    if (progress == null) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 3,
        backgroundColor: Colors.white.withValues(alpha: 0.2),
        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }
}
