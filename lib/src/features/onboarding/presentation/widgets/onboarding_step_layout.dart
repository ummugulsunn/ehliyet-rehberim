import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class OnboardingStepLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final Widget bottomWidget;

  const OnboardingStepLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.bottomWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 32),
          Expanded(child: child),
          const SizedBox(height: 16),
          bottomWidget,
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
