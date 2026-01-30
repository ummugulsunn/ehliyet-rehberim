
import 'package:fl_chart/fl_chart.dart';
import '../../home/data/user_progress_repository.dart';
import '../../quiz/domain/test_result_model.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class StatsRepository {
  final UserProgressRepository _progressRepository;

  StatsRepository(this._progressRepository);

  /// Get score history as FlSpots for the last [days] days.
  /// Data points are (dayIndex, averageScore 0-100).
  /// dayIndex: 0 is [days] ago, [days]-1 is today.
  Future<List<FlSpot>> getScoreHistory({int days = 7}) async {
    final results = _progressRepository.getAllTestResults();
    if (results.isEmpty) return [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = today.subtract(Duration(days: days - 1));

    // Map: dayIndex -> List<score>
    final Map<int, List<double>> dailyScores = {};

    for (var result in results) {
      final date = result.date;
      final resultDate = DateTime(date.year, date.month, date.day);
      
      if (resultDate.isBefore(startDate)) continue;

      final dayIndex = resultDate.difference(startDate).inDays;
      if (dayIndex >= 0 && dayIndex < days) {
        final score = (result.correctAnswers / result.totalQuestions) * 100;
        dailyScores.putIfAbsent(dayIndex, () => []).add(score);
      }
    }

    // Convert to FlSpot list
    final List<FlSpot> spots = [];
    for (int i = 0; i < days; i++) {
        if (dailyScores.containsKey(i)) {
            final scores = dailyScores[i]!;
            final average = scores.reduce((a, b) => a + b) / scores.length;
            spots.add(FlSpot(i.toDouble(), average));
        } else {
             // Optional: Add gap or 0? 
             // Ideally we want gap, but FlChart handles gaps via null spots in separate lists or custom handling.
             // For simple line chart, we might just skip the point, but that draws a line across.
             // Let's return only existing points.
        }
    }
    
    // Sort by x coordinate
    spots.sort((a, b) => a.x.compareTo(b.x));

    return spots;
  }

  /// Get topic performance as Map<TopicName, SuccessRate 0-1>.
  Map<String, double> getTopicPerformance() {
    return _progressRepository.getCategoryStats();
  }
}
