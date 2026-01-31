
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:ehliyet_rehberim/src/features/quiz/domain/test_result_model.dart';

void main() {
  test('decodeList robustly skips malformed items', () {
    // A list with one valid item and one invalid item (missing required 'date')
    final jsonStr = jsonEncode([
      {
        'date': DateTime.now().toIso8601String(),
        'correctAnswers': 10,
        'totalQuestions': 10,
        'category': 'Test',
      },
      {
        // Missing 'date', would crash standard fromJson
        'correctAnswers': 5,
        'totalQuestions': 10,
        'category': 'Corrupt',
      }
    ]);

    try {
      final results = TestResult.decodeList(jsonStr);
      print('Decoded ${results.length} items');
      expect(results.length, 1); // Should have 1 valid item
      expect(results.first.correctAnswers, 10);
    } catch (e) {
      fail('Should not crash: $e');
    }
  });
}
