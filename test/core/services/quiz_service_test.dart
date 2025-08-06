import 'package:flutter_test/flutter_test.dart';
import 'package:ehliyet_rehberim/src/core/services/quiz_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  test('QuizService should load questions', () async {
    final quizService = QuizService();
    final questions = await quizService.loadQuestions();
    expect(questions, isNotEmpty);
  });
}
