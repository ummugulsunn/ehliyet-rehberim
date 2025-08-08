import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../quiz/application/quiz_providers.dart';
import '../../quiz/presentation/quiz_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../stats/application/stats_providers.dart';

class TopicSelectionScreen extends ConsumerWidget {
  const TopicSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Load questions from default aggregated exam for topic practice
    final questionsAsync = ref.watch(quizQuestionsProvider('karma'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konu Seçimi'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: questionsAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Konular yükleniyor...'),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Sorular yüklenirken bir hata oluştu',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(quizQuestionsProvider);
                },
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
        data: (questions) {
          // Watch summary stats to extract per-category success rates
          final summary = ref.watch(summaryStatsProvider);
          final Map<String, double> categoryRates = summary.categorySuccessRates;

          // Extract unique categories and count questions per category
          final Map<String, int> categoryCounts = {};
          for (final question in questions) {
            categoryCounts[question.category] = (categoryCounts[question.category] ?? 0) + 1;
          }

          final List<MapEntry<String, int>> sortedCategories = categoryCounts.entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedCategories.length,
            itemBuilder: (context, index) {
              final category = sortedCategories[index];
              final double rate = (categoryRates[category.key] ?? 0.0).clamp(0.0, 1.0);
              final int percentage = (rate * 100).round();
              final Color barColor = rate >= 0.8
                  ? AppColors.success
                  : rate >= 0.5
                      ? AppColors.warning
                      : AppColors.error;

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => QuizScreen(examId: 'karma', category: category.key),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: Icon(
                              _getCategoryIcon(category.key),
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.key,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${category.value} soru',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: rate,
                                minHeight: 10,
                                backgroundColor: AppColors.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation<Color>(barColor),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$percentage% Başarı',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: barColor,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Trafik İşaretleri':
        return Icons.traffic;
      case 'Trafik ve Çevre Bilgisi':
        return Icons.directions_car;
      case 'İlk Yardım':
        return Icons.medical_services;
      case 'Motor ve Araç Tekniği':
        return Icons.build;
      case 'Trafik Adabı':
        return Icons.psychology;
      default:
        return Icons.topic;
    }
  }
}
