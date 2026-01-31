import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../core/theme/app_colors.dart';

class ExamTimerWidget extends StatefulWidget {
  final Duration duration;
  final VoidCallback onTimeUp;
  final bool isPaused;

  const ExamTimerWidget({
    super.key,
    required this.duration,
    required this.onTimeUp,
    this.isPaused = false,
  });

  @override
  State<ExamTimerWidget> createState() => _ExamTimerWidgetState();
}

class _ExamTimerWidgetState extends State<ExamTimerWidget>
    with SingleTickerProviderStateMixin {
  late Duration _remainingTime;
  Timer? _timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.duration;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _startTimer();
  }

  @override
  void didUpdateWidget(ExamTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPaused != oldWidget.isPaused) {
      if (widget.isPaused) {
        _pauseTimer();
      } else {
        _resumeTimer();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && !widget.isPaused) {
        setState(() {
          if (_remainingTime.inSeconds > 0) {
            _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);

            // Start pulsing when less than 5 minutes remain
            if (_remainingTime.inMinutes < 5 && !_pulseController.isAnimating) {
              _pulseController.repeat(reverse: true);
            }

            // Stop pulsing when time is up
            if (_remainingTime.inSeconds == 0) {
              _pulseController.stop();
              widget.onTimeUp();
            }
          } else {
            timer.cancel();
          }
        });
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _pulseController.stop();
  }

  void _resumeTimer() {
    _startTimer();
  }

  Color _getTimerColor() {
    final minutes = _remainingTime.inMinutes;
    if (minutes >= 15) {
      return AppColors.success;
    } else if (minutes >= 5) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }

  String _formatTime() {
    final minutes = _remainingTime.inMinutes;
    final seconds = _remainingTime.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final timerColor = _getTimerColor();
    final isLowTime = _remainingTime.inMinutes < 5;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = isLowTime ? 1.0 + (_pulseController.value * 0.05) : 1.0;

        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: timerColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: timerColor.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_outlined, color: timerColor, size: 24),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Kalan Süre',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: timerColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatTime(),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: timerColor,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                    ),
                  ],
                ),
                if (widget.isPaused) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'DURAKLAT ILDI',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
