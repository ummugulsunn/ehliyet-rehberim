import 'package:flutter/material.dart';
import '../services/ad_service.dart';

/// Widget for displaying banner ads at the bottom of screens
/// Only shows ads for non-Pro users
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  bool _isAdVisible = true;

  @override
  Widget build(BuildContext context) {
    final adWidget = AdService.instance.getBannerAdWidget();
    
    // Only show banner if ad is available and visible
    if (adWidget != null && _isAdVisible) {
      return Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Banner Ad - Fixed size container with proper constraints
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: adWidget,
                  ),
                ),
              ),
              // Close Button (Top Right)
              Positioned(
                top: 4,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isAdVisible = false;
                    });
                    AdService.instance.hideBannerAd();
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.error,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    // If no ad is available, show fallback or nothing
    return const SizedBox.shrink();
  }
}

/// Smaller banner ad widget for use in lists or cards
class SmallBannerAdWidget extends StatefulWidget {
  const SmallBannerAdWidget({super.key});

  @override
  State<SmallBannerAdWidget> createState() => _SmallBannerAdWidgetState();
}

class _SmallBannerAdWidgetState extends State<SmallBannerAdWidget> {
  @override
  Widget build(BuildContext context) {
    final adWidget = AdService.instance.getBannerAdWidget();
    
    if (adWidget != null) {
      return Container(
        width: double.infinity,
        height: 50,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: adWidget,
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
}

/// Fallback banner ad widget that shows a placeholder when no ad is available
class FallbackBannerAdWidget extends StatelessWidget {
  const FallbackBannerAdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star_outline,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              'Pro sürüme geçin',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}