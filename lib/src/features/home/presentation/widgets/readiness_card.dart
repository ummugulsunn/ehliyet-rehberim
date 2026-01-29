import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:ehliyet_rehberim/src/features/home/data/user_progress_repository.dart';
import 'package:ehliyet_rehberim/src/features/quiz/application/quiz_providers.dart';
import 'package:ehliyet_rehberim/src/features/stats/application/stats_providers.dart';
import '../../../../core/theme/app_colors.dart';

class ReadinessCard extends ConsumerWidget {
  const ReadinessCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testResultsAsync = ref.watch(testResultsProvider);

    return testResultsAsync.when(
      data: (results) {
        final validResults = results.where((r) => r.category != 'Yanlışlarım' && r.totalQuestions >= 10).toList();
        final score = ref.read(userProgressRepositoryProvider).calculateReadinessScore();
        
        if (score == -1) {
          // Insufficient data view
          return _buildCard(
            context,
            score: null,
            title: 'Sınav Hazırlık',
            subtitle: 'Tahmin için ${5 - validResults.length} test daha çöz',
            color: Colors.grey,
            icon: Icons.hourglass_empty,
          );
        }

        // Determine status
        Color color;
        String status;
        IconData icon;
        
        if (score >= 90) {
          color = const Color(0xFFFFD700); // Gold
          status = 'Efsane!';
          icon = Icons.workspace_premium;
        } else if (score >= 80) {
          color = AppColors.success;
          status = 'Hazırsın';
          icon = Icons.check_circle;
        } else if (score >= 70) {
          color = AppColors.warning;
          status = 'Sınırda';
          icon = Icons.warning_amber;
        } else {
          color = AppColors.error;
          status = 'Riskli';
          icon = Icons.dangerous;
        }

        return _buildCard(
          context,
          score: score,
          title: 'Hazırlık Puanı',
          subtitle: status,
          color: color,
          icon: icon,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required int? score,
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Indicator
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              children: [
                Center(
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: score != null ? score / 100 : 0,
                      backgroundColor: color.withValues(alpha: 0.1),
                      color: color,
                      strokeWidth: 6,
                    ),
                  ),
                ),
                Center(
                  child: score != null 
                    ? Text(
                        '$score',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      )
                    : Icon(icon, color: color.withValues(alpha: 0.5)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
