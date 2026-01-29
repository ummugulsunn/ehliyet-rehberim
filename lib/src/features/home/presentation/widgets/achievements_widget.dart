import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/achievement_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/home_providers.dart';

class AchievementsWidget extends ConsumerWidget {
  const AchievementsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlockedAsync = ref.watch(achievementsProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Başarımlar',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          unlockedAsync.when(
            data: (unlockedIds) {
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: Achievement.all.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final achievement = Achievement.all[index];
                  final isUnlocked = unlockedIds.contains(achievement.id);
                  return _buildAchievementTile(context, achievement, isUnlocked);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Hata: $err')),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementTile(BuildContext context, Achievement achievement, bool isUnlocked) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked 
              ? achievement.color.withValues(alpha: 0.5)
              : Theme.of(context).disabledColor.withValues(alpha: 0.2),
          width: isUnlocked ? 1.5 : 1,
        ),
        boxShadow: isUnlocked ? [
           BoxShadow(
             color: achievement.color.withValues(alpha: 0.1),
             blurRadius: 8,
             offset: const Offset(0, 2),
           )
        ] : [],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isUnlocked 
                  ? achievement.color.withValues(alpha: 0.2)
                  : Theme.of(context).disabledColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              achievement.iconData,
              color: isUnlocked ? achievement.color : Theme.of(context).disabledColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isUnlocked 
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).disabledColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isUnlocked 
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : Theme.of(context).disabledColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          if (isUnlocked)
            Icon(Icons.check_circle, color: AppColors.success, size: 20)
          else
            Icon(Icons.lock, color: Theme.of(context).disabledColor, size: 20),
        ],
      ),
    );
  }
}
