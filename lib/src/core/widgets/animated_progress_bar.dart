import 'package:flutter/material.dart';

/// Animated progress bar with smooth transitions
class AnimatedProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final double height;
  final Color? backgroundColor;
  final Color? valueColor;
  final BorderRadius? borderRadius;
  final Duration duration;
  final Curve curve;
  final Widget? label;

  const AnimatedProgressBar({
    super.key,
    required this.value,
    this.height = 8.0,
    this.backgroundColor,
    this.valueColor,
    this.borderRadius,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(height / 2);
    final effectiveBackgroundColor =
        backgroundColor ?? theme.colorScheme.surfaceContainerHighest;
    final effectiveValueColor = valueColor ?? theme.colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[label!, const SizedBox(height: 4)],
        Container(
          height: height,
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: effectiveBorderRadius,
          ),
          child: ClipRRect(
            borderRadius: effectiveBorderRadius,
            child: TweenAnimationBuilder<double>(
              duration: duration,
              curve: curve,
              tween: Tween<double>(begin: 0, end: value.clamp(0.0, 1.0)),
              builder: (context, animatedValue, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: animatedValue,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          effectiveValueColor,
                          effectiveValueColor.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: effectiveBorderRadius,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Circular progress indicator with animated value and optional pulse effect
class AnimatedCircularProgress extends StatefulWidget {
  final double value; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;
  final Color? valueColor;
  final Widget? center;
  final Duration duration;
  final bool showPulse;

  const AnimatedCircularProgress({
    super.key,
    required this.value,
    this.size = 100,
    this.strokeWidth = 8,
    this.backgroundColor,
    this.valueColor,
    this.center,
    this.duration = const Duration(milliseconds: 800),
    this.showPulse = false,
  });

  @override
  State<AnimatedCircularProgress> createState() =>
      _AnimatedCircularProgressState();
}

class _AnimatedCircularProgressState extends State<AnimatedCircularProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.showPulse) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedCircularProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showPulse && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.showPulse && _pulseController.isAnimating) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBackgroundColor =
        widget.backgroundColor ?? theme.colorScheme.surfaceContainerHighest;
    final effectiveValueColor = widget.valueColor ?? theme.colorScheme.primary;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.showPulse ? _pulseAnimation.value : 1.0,
          child: child,
        );
      },
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: TweenAnimationBuilder<double>(
          duration: widget.duration,
          curve: Curves.easeOutCubic,
          tween: Tween<double>(begin: 0, end: widget.value.clamp(0.0, 1.0)),
          builder: (context, animatedValue, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: animatedValue,
                  strokeWidth: widget.strokeWidth,
                  backgroundColor: effectiveBackgroundColor,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    effectiveValueColor,
                  ),
                ),
                if (widget.center != null) widget.center!,
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Progress bar with percentage label
class LabeledProgressBar extends StatelessWidget {
  final double value;
  final String label;
  final bool showPercentage;
  final Color? valueColor;
  final TextStyle? labelStyle;
  final TextStyle? percentageStyle;

  const LabeledProgressBar({
    super.key,
    required this.value,
    required this.label,
    this.showPercentage = true,
    this.valueColor,
    this.labelStyle,
    this.percentageStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = (value * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: labelStyle ?? theme.textTheme.bodyMedium),
            if (showPercentage)
              Text(
                '%$percentage',
                style:
                    percentageStyle ??
                    theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: valueColor ?? theme.colorScheme.primary,
                    ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedProgressBar(value: value, height: 10, valueColor: valueColor),
      ],
    );
  }
}
