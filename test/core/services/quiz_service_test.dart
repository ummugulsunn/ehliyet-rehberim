import 'package:flutter_test/flutter_test.dart';
import 'package:ehliyet_rehberim/src/core/services/quiz_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  test('QuizService should load exams', () async {
    final quizService = QuizService();
    final exams = await quizService.loadExams();
    expect(exams, isNotEmpty);
    expect(exams.first.questions, isNotEmpty);
  });

  test('QuizService should load questions for specific exam', () async {
    final quizService = QuizService();
    final questions = await quizService.loadQuestionsForExam('deneme_sinavi_1');
    expect(questions, isNotEmpty);
  });
}
