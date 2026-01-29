import 'dart:convert';

/// Represents the outcome of a single quiz session
class TestResult {
  final DateTime date;
  final int correctAnswers;
  final int totalQuestions;
  final String category; // e.g., "Karma" or specific topic
  final String? examId; // optional per exam result
  final Map<int, String>? selectedAnswers; // questionId -> selected option key

  const TestResult({
    required this.date,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.category,
    this.examId,
    this.selectedAnswers,
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
        'selectedAnswers': selectedAnswers,
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
      );

  static String encodeList(List<TestResult> results) => jsonEncode(
        results.map((r) => r.toJson()).toList(),
      );

  static List<TestResult> decodeList(String jsonStr) {
    final dynamic data = jsonDecode(jsonStr);
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map((e) => TestResult.fromJson(e))
          .toList();
    }
    return const [];
  }
}

