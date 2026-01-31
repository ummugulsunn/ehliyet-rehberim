import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';

/// A widget that displays a thumbnail and opens the video in external browser/app
/// This avoids WebView crashes on emulator and handles private Vimeo videos correctly via browser.
class VimeoPlayerWidget extends StatelessWidget {
  final String videoUrl;
  final double height;

  const VimeoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.height = 200,
  });

  String? _extractVideoId() {
    if (videoUrl.contains('player.vimeo.com/video/')) {
      final match = RegExp(
        r'player\.vimeo\.com/video/(\d+)',
      ).firstMatch(videoUrl);
      return match?.group(1);
    }
    final match = RegExp(r'vimeo\.com/(\d+)').firstMatch(videoUrl);
    return match?.group(1);
  }

  Future<void> _openVideo() async {
    final Uri url = Uri.parse(videoUrl);
    try {
      // Launch in external browser (best compatibility for private videos and emulator stability)
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch video: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoId = _extractVideoId();

    return GestureDetector(
      onTap: _openVideo,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          image: videoId != null
              ? DecorationImage(
                  image: NetworkImage('https://vumbnail.com/$videoId.jpg'),
                  fit: BoxFit.cover,
                  onError: (_, __) {},
                )
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Dark overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black.withValues(alpha: 0.4),
              ),
            ),

            // Play Button
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),

            // Text Label
            Positioned(
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.open_in_new,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Videoyu İzle (Tarayıcıda)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

bool isVideoUrl(String? url) {
  if (url == null) return false;
  return url.contains('vimeo.com') ||
      url.contains('youtube.com') ||
      url.endsWith('.mp4');
}
