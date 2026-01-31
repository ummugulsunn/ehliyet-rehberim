import 'dart:convert';

/// Represents the outcome of a single quiz session
class TestResult {
  final DateTime date;
  final int correctAnswers;
  final int totalQuestions;
  final String category; // e.g., "Karma" or specific topic
  final String? examId; // optional per exam result
  final Map<int, String>? selectedAnswers; // questionId -> selected option key
  final bool isExamMode;
  final int? timeTakenInSeconds;
  final bool? isPassed;

  const TestResult({
    required this.date,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.category,
    this.examId,
    this.selectedAnswers,
    this.isExamMode = false,
    this.timeTakenInSeconds,
    this.isPassed,
  });

  double get successRate => totalQuestions == 0
      ? 0
      : correctAnswers.clamp(0, totalQuestions) / totalQuestions;

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'correctAnswers': correctAnswers,
        'totalQuestions': totalQuestions,
        'category': category,
        'examId': examId,
        'selectedAnswers': selectedAnswers?.map((key, value) => MapEntry(key.toString(), value)),
        'isExamMode': isExamMode,
        'timeTakenInSeconds': timeTakenInSeconds,
        'isPassed': isPassed,
      };

  factory TestResult.fromJson(Map<String, dynamic> json) => TestResult(
        date: DateTime.parse(json['date'] as String),
        correctAnswers: (json['correctAnswers'] as num).toInt(),
        totalQuestions: (json['totalQuestions'] as num).toInt(),
        category: json['category'] as String? ?? 'Karma',
        examId: json['examId'] as String?,
        selectedAnswers: (json['selectedAnswers'] is Map)
            ? (json['selectedAnswers'] as Map)
                .map((key, value) => MapEntry(int.parse(key.toString()), value.toString()))
            : null,
        isExamMode: json['isExamMode'] as bool? ?? false,
        timeTakenInSeconds: json['timeTakenInSeconds'] as int?,
        isPassed: json['isPassed'] as bool?,
      );

  static String encodeList(List<TestResult> results) => jsonEncode(
        results.map((r) => r.toJson()).toList(),
      );

  static List<TestResult> decodeList(String jsonStr) {
    // Robust decoding that skips malformed items instead of crashing the whole list
    try {
      final dynamic data = jsonDecode(jsonStr);
      if (data is List) {
        final List<TestResult> results = [];
        for (var item in data) {
          if (item is Map<String, dynamic>) {
            try {
              results.add(TestResult.fromJson(item));
            } catch (e) {
              // Skip malformed item, but log it (if we had logger access, here we just skip)
              // print('Skipping malformed TestResult: $e'); 
            }
          }
        }
        return results;
      }
    } catch (e) {
      // If global jsonDecode fails, return empty list
    }
    return const [];
  }
}

