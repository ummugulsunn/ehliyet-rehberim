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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // Theme-adaptive card background for proper contrast in dark mode
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          // App Logo removed for cleaner design
          // Main content row
          Row(
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
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.95)
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Daily Goal Progress Text
                    dailyProgressAsync.when(
                      data: (progress) => Text(
                        'Bugünkü Hedef: $progress/$dailyGoal',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? (progress >= dailyGoal ? AppColors.successLight : AppColors.primaryLight)
                              : (progress >= dailyGoal ? AppColors.success : AppColors.primary),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      loading: () => Text(
                        'Bugünkü Hedef: 0/$dailyGoal',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withValues(alpha: 0.8)
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      error: (_, __) => Text(
                        'Bugünkü Hedef: 0/$dailyGoal',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withValues(alpha: 0.8)
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Enhanced Streak Display
                    if (streakText.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? AppColors.warning.withValues(alpha: 0.2)
                              : AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark 
                              ? AppColors.warning.withValues(alpha: 0.4)
                              : AppColors.warning.withValues(alpha: 0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.warning.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness == Brightness.dark 
                                  ? AppColors.warning.withValues(alpha: 0.3)
                                  : AppColors.warning.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Text(
                                '🔥',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              streakText,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).brightness == Brightness.dark 
                                  ? AppColors.warning.withValues(alpha: 0.9)
                                  : AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
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
          // Background circle with theme-adaptive color
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.6)
                  : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          
          // Progress circle with enhanced design
          SizedBox(
            width: 110,
            height: 110,
            child: CircularProgressIndicator(
              value: progressPercentage.clamp(0.0, 1.0),
              strokeWidth: 8,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                progressPercentage >= 1.0 ? AppColors.success : AppColors.primary,
              ),
              strokeCap: StrokeCap.round,
            ),
          ),
          
          // User profile image or default icon
          _buildUserProfileImage(context),
          
          // Progress text overlay (only show if no profile image)
          if (!_hasProfileImage()) ...[
            Positioned(
              bottom: -20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$progress',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? (progressPercentage >= 1.0 ? AppColors.successLight : AppColors.primaryLight)
                          : (progressPercentage >= 1.0 ? AppColors.success : AppColors.primary),
                    ),
                  ),
                  Text(
                    '/$dailyGoal',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.8)
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      loading: () => Stack(
        alignment: Alignment.center,
        children: [
          // Background circle with theme-adaptive color
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.6)
                  : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          
          // User profile image or default icon (no loading indicator)
          _buildUserProfileImage(context),
        ],
      ),
      error: (_, __) => Stack(
        alignment: Alignment.center,
        children: [
          // Background circle with gradient
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.surfaceContainerHighest,
                  Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          
          // Error icon
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 32,
          ),
          
          // User profile image or default icon (even during error)
          _buildUserProfileImage(context),
        ],
      ),
    );
  }

  Widget _buildUserProfileImage(BuildContext context) {
    return authState.when(
      data: (user) {
        if (user == null) {
          // Misafir kullanıcı - default icon
          return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Icon(
              Icons.account_circle_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
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


} 