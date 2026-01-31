import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/onboarding_providers.dart';
import '../widgets/onboarding_step_layout.dart';

class DailyGoalStep extends ConsumerWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const DailyGoalStep({super.key, required this.onNext, required this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingStateProvider);
    final currentGoal = state.dailyGoal;

    return OnboardingStepLayout(
      title: 'Günlük Hedefin?',
      subtitle:
          'Kendine gerçekçi bir hedef koy. Küçük adımlar büyük başarılara götürür.',
      bottomWidget: Row(
        children: [
          TextButton(
            onPressed: onBack,
            style: TextButton.styleFrom(minimumSize: const Size(80, 56)),
            child: const Text('Geri'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton(
              onPressed: onNext,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Planımı Oluştur',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _GoalCard(
              goal: 20,
              title: 'Hafif Tempo',
              description: 'Günde 5-10 dk',
              isSelected: currentGoal == 20,
              badge: 'Başlangıç',
              onTap: () =>
                  ref.read(onboardingStateProvider.notifier).setDailyGoal(20),
            ),
            const SizedBox(height: 16),
            _GoalCard(
              goal: 50,
              title: 'Standart',
              description: 'Günde 15-20 dk',
              isSelected: currentGoal == 50,
              badge: 'Önerilen',
              isRecommended: true,
              onTap: () =>
                  ref.read(onboardingStateProvider.notifier).setDailyGoal(50),
            ),
            const SizedBox(height: 16),
            _GoalCard(
              goal: 100,
              title: 'Yoğun',
              description: 'Günde 30+ dk',
              isSelected: currentGoal == 100,
              badge: 'Hızlandırılmış',
              onTap: () =>
                  ref.read(onboardingStateProvider.notifier).setDailyGoal(100),
            ),

            const SizedBox(height: 24),

            // Psychological Reinforcement
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: ValueKey(currentGoal),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        currentGoal == 20
                            ? 'Harika! Küçük adımlarla başlamak en iyisi.'
                            : currentGoal == 50
                            ? 'Mükemmel seçim! Bu tempo ile konuları rahatça bitirirsin.'
                            : currentGoal == 100
                            ? 'Vay canına! Azmine hayran kaldık. Bu hedefe ulaşmak sana çok şey katacak.'
                            : 'Kendine uygun bir hedef seç.',
                        style: TextStyle(
                          color: AppColors.successDark,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
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

class _GoalCard extends StatelessWidget {
  final int goal;
  final String title;
  final String description;
  final bool isSelected;
  final String badge;
  final bool isRecommended;
  final VoidCallback onTap;

  const _GoalCard({
    required this.goal,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.badge,
    this.isRecommended = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            // Circular Checkbox
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey.shade400,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (isRecommended)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'ÖNERİLEN',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Goal Number Visual
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '$goal',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                  const Text(
                    'Soru',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
