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
    final userProgressStateAsync = ref.watch(userProgressStateProvider);
    final dailyGoal = ref.watch(dailyGoalProvider);

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
      child: userProgressStateAsync.when(
        data: (state) {
          final dailyProgress = state.dailyProgress;
          final progressPercentage = (dailyProgress / dailyGoal).clamp(0.0, 1.0);
          final level = state.level;
          final xp = state.xp;
          final streak = state.streak;
          
          // Enhanced Streak Text Logic
          String streakText = '';
          if (streak > 0) {
             streakText = streak == 1 ? '1 Günlük Seri!' : '$streak Günlük Seri!';
          }

          // Level Title Logic
          String levelTitle = 'Acemi Sürücü';
          if (level < 5) {
            levelTitle = 'Acemi Sürücü';
          } else if (level < 10) {
            levelTitle = 'Şehir İçi Uzmanı';
          } else if (level < 20) {
            levelTitle = 'Otoyol Faresi';
          } else if (level < 50) {
            levelTitle = 'Trafik Efsanesi';
          } else {
            levelTitle = 'Ehliyet Kralı';
          }

          // XP Calculation
          final userProgressRepository = ref.read(userProgressRepositoryProvider);
          final currentLevelBaseXP = userProgressRepository.getXPForCurrentLevel(level);
          final nextLevelBaseXP = userProgressRepository.getXPForNextLevel(level);
          final levelRange = nextLevelBaseXP - currentLevelBaseXP;
          final xpInLevel = xp - currentLevelBaseXP;
          final xpProgress = levelRange > 0 ? (xpInLevel / levelRange).clamp(0.0, 1.0) : 1.0;

          return Column(
            children: [
              // App Logo removed for cleaner design
              // Main content row
              Row(
                children: [
                  // Circular Progress Indicator
                  _buildProgressIndicator(context, AsyncValue.data(dailyProgress), dailyGoal, progressPercentage),
                  
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
                        
                        // Level and Rank Display
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$levelTitle (Lvl $level)',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.primaryLight 
                                    : AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // XP Progress Bar
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: xpProgress,
                                    minHeight: 6,
                                    backgroundColor: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white.withValues(alpha: 0.1)
                                        : Colors.grey.withValues(alpha: 0.2),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).brightness == Brightness.dark
                                          ? AppColors.successLight
                                          : AppColors.success,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${(xpProgress * 100).toInt()}% (Sonraki Seviye)',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 10,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white.withValues(alpha: 0.6)
                                        : Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Enhanced Streak Display
                        if (streakText.isNotEmpty) ...[
                          GestureDetector(
                            onTap: () => _showStreakShop(context, ref, streak, state.streakFreezes, xp),
                            child: Container(
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
                                  const SizedBox(width: 8),
                                  Text(
                                    streakText,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).brightness == Brightness.dark 
                                        ? AppColors.warning.withValues(alpha: 0.9)
                                        : AppColors.warning,
                                    ),
                                  ),
                                  if (state.streakFreezes > 0) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 1, 
                                      height: 16, 
                                      color: Theme.of(context).dividerColor.withValues(alpha: 0.5)
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('❄️', style: TextStyle(fontSize: 14)),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${state.streakFreezes}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade300,
                                      ),
                                    ),
                                  ]
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
        loading: () => Column(
          children: [
             Row(
                children: [
                  _buildProgressIndicator(context, const AsyncValue.loading(), dailyGoal, 0.0),
                   const SizedBox(width: 20),
                   // Skeleton text or loading simplified
                   const Expanded(child: Center(child: CircularProgressIndicator())),
                ]
             )
          ]
        ),
        error: (_, __) => Column(
          children: [
             Row(
                children: [
                  _buildProgressIndicator(context, const AsyncValue.loading(), dailyGoal, 0.0),
                   const SizedBox(width: 20),
                   const Text('Bir hata oluştu'),
                ]
             )
          ]
        ),
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

  void _showStreakShop(BuildContext context, WidgetRef ref, int currentStreak, int freezes, int currentXP) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 16),
                Text(
                  '$currentStreak Günlük Seri',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Serini korumak için dondurucu al!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            
            // Streak Freeze Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Text('❄️', style: TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Seri Dondurucu',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bir gün girmesen bile serin bozulmaz. (Stok: $freezes/2)',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Buy Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: freezes >= 2 
                  ? null 
                  : (currentXP < 500 ? null : () async {
                      Navigator.pop(context); // Close sheet first
                      final success = await ref.read(userProgressRepositoryProvider).buyStreakFreeze();
                      if (!context.mounted) return;
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('❄️ Seri Dondurucu alındı!'),
                            backgroundColor: Colors.blue,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } else {
                        // Error handling normally not needed due to button disable
                      }
                    }),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.blue,
                  disabledBackgroundColor: Colors.grey.withValues(alpha: 0.2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (freezes >= 2) ...[
                      const Text('Maksimum Stok'),
                    ] else ...[
                      const Text('Satın Al'),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '500 XP',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: currentXP >= 500 ? Colors.white : Colors.red.shade200,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (currentXP < 500 && freezes < 2) 
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Yetersiz XP (Mevcut: $currentXP)',
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }


} 