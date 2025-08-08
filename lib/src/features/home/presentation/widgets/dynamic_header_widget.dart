import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../application/home_providers.dart';
import '../../../../core/theme/app_colors.dart';

/// Dynamic header widget that displays user progress and streak
class DynamicHeaderWidget extends ConsumerWidget {
  final AsyncValue<User?> authState;

  const DynamicHeaderWidget({
    super.key,
    required this.authState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyProgressAsync = ref.watch(dailyProgressProvider);
    final dailyGoal = ref.watch(dailyGoalProvider);
    final progressPercentage = ref.watch(dailyProgressPercentageProvider);
    final streakText = ref.watch(streakTextProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outline.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Progress Indicator
          _buildProgressIndicator(context, dailyProgressAsync, dailyGoal, progressPercentage),
          
          const SizedBox(width: 20),
          
          // Greeting and Streak Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Personalized Greeting
                Text(
                  _getGreetingText(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Subtitle
                Text(
                  _getSubtitleText(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Streak Display
                if (streakText.isNotEmpty) ...[
                  Row(
                    children: [
                      const Text(
                        '🔥',
                        style: TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        streakText,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(
    BuildContext context,
    AsyncValue<int> dailyProgressAsync,
    int dailyGoal,
    double progressPercentage,
  ) {
    return dailyProgressAsync.when(
      data: (progress) => Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainerHighest,
            ),
          ),
          
          // Progress circle
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              value: progressPercentage.clamp(0.0, 1.0),
              strokeWidth: 8,
              backgroundColor: AppColors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                progressPercentage >= 1.0 ? AppColors.success : AppColors.primary,
              ),
            ),
          ),
          
          // User profile image or default icon
          _buildUserProfileImage(),
          
          // Progress text (only show if no profile image)
          if (!_hasProfileImage()) ...[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$progress',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '/$dailyGoal',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      loading: () => Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainerHighest,
            ),
          ),
          
          // User profile image or default icon (no loading indicator)
          _buildUserProfileImage(),
        ],
      ),
      error: (_, __) => Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainerHighest,
            ),
          ),
          
          // Error icon
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 32,
          ),
          
          // User profile image or default icon (even during error)
          _buildUserProfileImage(),
        ],
      ),
    );
  }

  Widget _buildUserProfileImage() {
    return authState.when(
      data: (user) {
        if (user == null) {
          // Misafir kullanıcı - default icon
          return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainerHighest,
            ),
            child: Icon(
              Icons.account_circle_outlined,
              color: AppColors.textSecondary,
              size: 40,
            ),
          );
        } else {
          // Giriş yapmış kullanıcı - profil resmi veya default icon
          if (user.photoURL != null && user.photoURL!.isNotEmpty) {
            // Kullanıcının profil resmi varsa
            return ClipOval(
              child: Image.network(
                user.photoURL!,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceContainerHighest,
                    ),
                    child: Icon(
                      Icons.account_circle,
                      color: AppColors.primary,
                      size: 40,
                    ),
                  );
                },
              ),
            );
          } else {
            // Profil resmi yoksa default icon
            return Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceContainerHighest,
              ),
              child: Icon(
                Icons.account_circle,
                color: AppColors.primary,
                size: 40,
              ),
            );
          }
        }
      },
      loading: () => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surfaceContainerHighest,
        ),
        child: Icon(
          Icons.account_circle_outlined,
          color: AppColors.textSecondary,
          size: 40,
        ),
      ),
      error: (_, __) => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surfaceContainerHighest,
        ),
        child: Icon(
          Icons.account_circle_outlined,
          color: AppColors.textSecondary,
          size: 40,
        ),
      ),
    );
  }

  bool _hasProfileImage() {
    return authState.when(
      data: (user) {
        if (user == null) return false;
        return user.photoURL != null && user.photoURL!.isNotEmpty;
      },
      loading: () => false,
      error: (_, __) => false,
    );
  }

  String _getGreetingText() {
    return authState.when(
      data: (user) {
        if (user == null) {
          return 'Merhaba!';
        }
        final displayName = user.displayName ?? user.email?.split('@').first ?? 'Kullanıcı';
        return 'Merhaba $displayName,';
      },
      loading: () => 'Merhaba!',
      error: (_, __) => 'Merhaba!',
    );
  }

  String _getSubtitleText() {
    return authState.when(
      data: (user) {
        if (user == null) {
          return 'Ehliyet sınavına hazırlanmaya başlayalım!';
        }
        return 'Bugünkü hedefine ulaşmaya hazır mısın?';
      },
      loading: () => 'Yükleniyor...',
      error: (_, __) => 'Ehliyet sınavına hazırlanmaya başlayalım!',
    );
  }
} 