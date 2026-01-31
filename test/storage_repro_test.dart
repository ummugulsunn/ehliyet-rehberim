import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ehliyet_rehberim/src/features/quiz/data/exam_storage_service.dart';
import 'package:ehliyet_rehberim/src/features/quiz/domain/unfinished_exam.dart';

void main() {
  test('ExamStorageService isolates exams by ID', () async {
    // 1. Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    final storage = ExamStorageService();

    // 2. Save Exam 1
    final exam1 = UnfinishedExam(
      examId: 'exam_1',
      questionIds: [1, 2, 3],
      currentQuestionIndex: 1,
      remainingSeconds: 100,
      answers: {'1': 'A'},
      savedAt: DateTime.now(),
    );
    await storage.saveExam(exam1);

    // 3. Verify Exam 1 exists
    final loaded1 = await storage.getUnfinishedExam('exam_1');
    expect(loaded1, isNotNull);
    expect(loaded1!.examId, 'exam_1');
    expect(loaded1.answers['1'], 'A');

    // 4. Verify Exam 2 does NOT exist
    final loaded2 = await storage.getUnfinishedExam('exam_2');
    if (loaded2 != null) {
      print(
        'CRITICAL FAILURE: Retrieved Exam 2 but expected null. Got: ${loaded2.examId} with answers: ${loaded2.answers}',
      );
    } else {
      print('SUCCESS: Exam 2 is null as expected.');
    }

    expect(
      loaded2,
      isNull,
      reason: "Exam 2 should be null but got ${loaded2?.examId}",
    );
  });
}
