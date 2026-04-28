import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../../../app/theme/app_colors.dart';

class DownloadButton extends StatefulWidget {
  final String rawUrl;

  const DownloadButton({super.key, required this.rawUrl});

  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  _DownloadState _state = _DownloadState.idle;
  double _progress = 0;

  Future<void> _download() async {
    if (_state == _DownloadState.downloading) return;
    
    setState(() {
      _state = _DownloadState.downloading;
      _progress = 0;
    });

    try {
      final req = http.Request('GET', Uri.parse(widget.rawUrl));
      final res = await http.Client().send(req);

      if (res.statusCode != 200) {
        throw 'HTTP ${res.statusCode}';
      }

      final contentLength = res.contentLength ?? 0;
      final buf = <int>[];
      int got = 0;

      await for (final chunk in res.stream) {
        buf.addAll(chunk);
        got += chunk.length;
        if (contentLength > 0 && mounted) {
          setState(() => _progress = got / contentLength);
        }
      }

      final dir = await getApplicationDocumentsDirectory();
      final fname = 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final f = File('${dir.path}/$fname');
      await f.writeAsBytes(buf);

      if (mounted) {
        setState(() => _state = _DownloadState.done);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Saved to downloads'),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => _state = _DownloadState.idle);
        });
      }
    } catch (e) {
      print('[DL] Failed - $e');
      if (mounted) {
        setState(() => _state = _DownloadState.error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _state = _DownloadState.idle);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _state == _DownloadState.downloading ? null : _download,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: _state == _DownloadState.done
                  ? const LinearGradient(
                      colors: [AppColors.success, Color(0xFF00A878)],
                    )
                  : _state == _DownloadState.error
                      ? const LinearGradient(
                          colors: [AppColors.error, Color(0xFFE8434A)],
                        )
                      : AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (_state == _DownloadState.done
                          ? AppColors.success
                          : AppColors.primary)
                      .withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Progress bar background
                if (_state == _DownloadState.downloading)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(16),
                      ),
                      child: LinearProgressIndicator(
                        value: _progress,
                        minHeight: 3,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                  ),

                // Button content
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _state == _DownloadState.done
                          ? Icons.check_circle_rounded
                          : _state == _DownloadState.error
                              ? Icons.error_outline_rounded
                              : _state == _DownloadState.downloading
                                  ? Icons.downloading_rounded
                                  : Icons.download_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _state == _DownloadState.done
                          ? 'Downloaded!'
                          : _state == _DownloadState.error
                              ? 'Failed — Tap to Retry'
                              : _state == _DownloadState.downloading
                                  ? 'Downloading ${(_progress * 100).toInt()}%'
                                  : 'Download Full Resolution',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _DownloadState { idle, downloading, done, error }
