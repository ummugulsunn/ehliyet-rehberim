import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/data/user_progress_repository.dart';
import '../../quiz/domain/test_result_model.dart';

final testResultsProvider = StreamProvider<List<TestResult>>((ref) {
  final repository = UserProgressRepository.instance;
  
  Stream<List<TestResult>> stream() async* {
    if (!repository.isInitialized) {
      await repository.initialize();
    }
    // Emit the current cached results immediately
    yield repository.getAllTestResults();
    // Then listen for future updates
    yield* repository.resultsStream;
  }
  
  return stream();
});

class SummaryStats {
  final double overallSuccessRate; // 0..1
  final int totalQuestionsAnswered;
  final int totalTests;
  final Map<String, double> categorySuccessRates; // 0..1 per category

  const SummaryStats({
    required this.overallSuccessRate,
    required this.totalQuestionsAnswered,
    required this.totalTests,
    required this.categorySuccessRates,
  });
}

final summaryStatsProvider = Provider<SummaryStats>((ref) {
  final resultsAsync = ref.watch(testResultsProvider);
  return resultsAsync.when(
    data: (results) {
      if (results.isEmpty) {
        return const SummaryStats(
          overallSuccessRate: 0,
          totalQuestionsAnswered: 0,
          totalTests: 0,
          categorySuccessRates: {},
        );
      }

      int correctSum = 0;
      int totalSum = 0;
      final Map<String, int> catCorrect = {};
      final Map<String, int> catTotal = {};

      for (final r in results) {
        correctSum += r.correctAnswers;
        totalSum += r.totalQuestions;
        catCorrect[r.category] = (catCorrect[r.category] ?? 0) + r.correctAnswers;
        catTotal[r.category] = (catTotal[r.category] ?? 0) + r.totalQuestions;
      }

      final Map<String, double> catRates = {
        for (final e in catTotal.entries)
          e.key: (catCorrect[e.key] ?? 0) / (e.value == 0 ? 1 : e.value),
      };

      final overall = totalSum == 0 ? 0.0 : correctSum / totalSum;

      return SummaryStats(
        overallSuccessRate: overall,
        totalQuestionsAnswered: totalSum,
        totalTests: results.length,
        categorySuccessRates: catRates,
      );
    },
    loading: () => const SummaryStats(
      overallSuccessRate: 0,
      totalQuestionsAnswered: 0,
      totalTests: 0,
      categorySuccessRates: {},
    ),
    error: (_, __) => const SummaryStats(
      overallSuccessRate: 0,
      totalQuestionsAnswered: 0,
      totalTests: 0,
      categorySuccessRates: {},
    ),
  );
});

