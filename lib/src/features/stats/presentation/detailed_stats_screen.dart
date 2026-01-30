import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../application/stats_providers.dart';
import 'widgets/category_pie_chart.dart';
import 'widgets/daily_progress_line_chart.dart';
import 'widgets/weekly_performance_bar_chart.dart';
import 'package:intl/intl.dart';

/// Detailed statistics screen with charts and visualizations
class DetailedStatsScreen extends ConsumerWidget {
  const DetailedStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(testResultsProvider);
    final summary = ref.watch(summaryStatsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Detaylı İstatistikler',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: resultsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
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
                'İstatistikler yüklenemedi',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ),
        data: (results) {
          if (results.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz Test Çözmediniz',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'İlk testinizi çözerek detaylı istatistiklerinizi görün!',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Prepare data for charts
          final dailyProgressData = _getDailyProgressData(results);
          final weeklyPerformanceData = _getWeeklyPerformanceData(results);
          final categoryScores = _getCategoryScores(summary.categorySuccessRates);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Daily Progress Chart
              _ChartCard(
                title: 'Günlük İlerleme',
                subtitle: 'Son 7 gündeki çözülen soru sayısı',
                icon: Icons.show_chart,
                iconColor: AppColors.primary,
                child: DailyProgressLineChart(
                  dailyProgress: dailyProgressData['progress'] as List<int>,
                  labels: dailyProgressData['labels'] as List<String>,
                ),
              ),
              const SizedBox(height: 20),

              // Weekly Performance Chart
              _ChartCard(
                title: 'Haftalık Performans',
                subtitle: 'Son 7 gündeki başarı oranları',
                icon: Icons.bar_chart,
                iconColor: AppColors.success,
                child: WeeklyPerformanceBarChart(
                  weeklyScores: weeklyPerformanceData['scores'] as List<double>,
                  labels: weeklyPerformanceData['labels'] as List<String>,
                ),
              ),
              const SizedBox(height: 20),

              // Category Performance Pie Chart
              _ChartCard(
                title: 'Konu Dağılımı',
                subtitle: 'Kategori bazlı başarı oranları',
                icon: Icons.pie_chart,
                iconColor: AppColors.warning,
                child: Column(
                  children: [
                    CategoryPerformancePieChart(
                      categoryScores: categoryScores,
                    ),
                    const SizedBox(height: 16),
                    CategoryLegend(
                      categoryScores: categoryScores,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Performance Insights
              _PerformanceInsights(
                summary: summary,
                results: results,
              ),
            ],
          );
        },
      ),
    );
  }

  Map<String, dynamic> _getDailyProgressData(List results) {
    // Get last 7 days
    final now = DateTime.now();
    final List<int> progress = [];
    final List<String> labels = [];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      
      // Count questions answered on this day
      int count = 0;
      for (var result in results) {
        final resultDateStr = DateFormat('yyyy-MM-dd').format(result.date);
        if (resultDateStr == dateStr) {
          count += result.totalQuestions as int;
        }
      }
      
      progress.add(count);
      labels.add(DateFormat('E', 'tr_TR').format(date)); // Day abbreviation
    }

    return {
      'progress': progress,
      'labels': labels,
    };
  }

  Map<String, dynamic> _getWeeklyPerformanceData(List results) {
    // Get last 7 days
    final now = DateTime.now();
    final List<double> scores = [];
    final List<String> labels = [];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      
      // Calculate average success rate for this day
      int totalQuestions = 0;
      int correctAnswers = 0;
      
      for (var result in results) {
        final resultDateStr = DateFormat('yyyy-MM-dd').format(result.date);
        if (resultDateStr == dateStr) {
          totalQuestions += result.totalQuestions as int;
          correctAnswers += result.correctAnswers as int;
        }
      }
      
      final score = totalQuestions > 0 
          ? (correctAnswers / totalQuestions * 100) 
          : 0.0;
      
      scores.add(score);
      labels.add(DateFormat('E', 'tr_TR').format(date));
    }

    return {
      'scores': scores,
      'labels': labels,
    };
  }

  Map<String, double> _getCategoryScores(Map<String, double> categoryRates) {
    // Convert to percentage
    return categoryRates.map((key, value) => MapEntry(key, value * 100));
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _PerformanceInsights extends StatelessWidget {
  final SummaryStats summary;
  final List results;

  const _PerformanceInsights({
    required this.summary,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate insights
    final bestCategory = _getBestCategory();
    final worstCategory = _getWorstCategory();
    final trend = _getPerformanceTrend();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Performans Önerileri',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (bestCategory != null)
            _InsightItem(
              icon: Icons.emoji_events,
              iconColor: AppColors.success,
              title: 'En İyi Konunuz',
              description: '$bestCategory - ${(summary.categorySuccessRates[bestCategory]! * 100).toInt()}%',
            ),
          const SizedBox(height: 12),
          if (worstCategory != null)
            _InsightItem(
              icon: Icons.flag,
              iconColor: AppColors.error,
              title: 'Geliştirilmesi Gereken Konu',
              description: '$worstCategory - ${(summary.categorySuccessRates[worstCategory]! * 100).toInt()}%',
            ),
          const SizedBox(height: 12),
          _InsightItem(
            icon: trend == 'up' ? Icons.trending_up : Icons.trending_down,
            iconColor: trend == 'up' ? AppColors.success : AppColors.warning,
            title: 'Performans Trendi',
            description: trend == 'up' 
                ? 'Son testlerinizde ilerleme var! 📈'
                : 'Daha fazla çalışma yapabilirsiniz 💪',
          ),
        ],
      ),
    );
  }

  String? _getBestCategory() {
    if (summary.categorySuccessRates.isEmpty) return null;
    return summary.categorySuccessRates.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  String? _getWorstCategory() {
    if (summary.categorySuccessRates.isEmpty) return null;
    return summary.categorySuccessRates.entries
        .reduce((a, b) => a.value < b.value ? a : b)
        .key;
  }

  String _getPerformanceTrend() {
    if (results.length < 2) return 'neutral';
    
    // Compare last 3 tests with previous 3 tests
    final sortedResults = results.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    
    final recentTests = sortedResults.take(3).toList();
    final olderTests = sortedResults.skip(3).take(3).toList();
    
    if (recentTests.isEmpty || olderTests.isEmpty) return 'neutral';
    
    final recentAvg = recentTests
        .map((r) => r.successRate)
        .reduce((a, b) => a + b) / recentTests.length;
    
    final olderAvg = olderTests
        .map((r) => r.successRate)
        .reduce((a, b) => a + b) / olderTests.length;
    
    return recentAvg > olderAvg ? 'up' : 'down';
  }
}

class _InsightItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const _InsightItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
