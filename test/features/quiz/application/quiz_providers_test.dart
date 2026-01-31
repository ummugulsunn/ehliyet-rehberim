import 'package:ehliyet_rehberim/src/features/quiz/domain/question_model.dart';
import 'package:ehliyet_rehberim/src/features/quiz/application/quiz_providers.dart';
import 'package:ehliyet_rehberim/src/features/quiz/application/quiz_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QuizProviders', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('quizQuestionsProvider should load questions', () async {
      final questions = await container.read(
        quizQuestionsProvider('karma').future,
      );
      expect(questions, isA<List<Question>>());
    });

    test('QuizController should initialize with empty state', () {
      final state = container.read(quizControllerProvider('karma'));

      expect(state.questions, isEmpty);
      expect(state.questionIndex, 0);
      expect(state.selectedAnswers, isEmpty);
      expect(state.score, 0);
      expect(state.status, QuizStatus.initial);
    });

    test('QuizController should initialize quiz with questions', () {
      final quizController = container.read(
        quizControllerProvider('karma').notifier,
      );
      final questions = [
        Question(
          id: 1,
          questionText: 'Test question?',
          options: {'A': 'Option A', 'B': 'Option B'},
          correctAnswerKey: 'A',
          explanation: 'Test explanation',
          category: 'Test Category',
        ),
      ];

      quizController.initializeQuiz(questions, examId: 'karma');

      final state = container.read(quizControllerProvider('karma'));
      expect(state.questions, questions);
      expect(state.questionIndex, 0);
      expect(state.selectedAnswers, isEmpty);
      expect(state.score, 0);
      expect(state.status, QuizStatus.initial);
    });

    test('QuizController should handle correct answer', () {
      final quizController = container.read(
        quizControllerProvider('karma').notifier,
      );
      final questions = [
        Question(
          id: 1,
          questionText: 'Test question?',
          options: {'A': 'Option A', 'B': 'Option B'},
          correctAnswerKey: 'A',
          explanation: 'Test explanation',
          category: 'Test Category',
        ),
      ];

      quizController.initializeQuiz(questions, examId: 'karma');
      quizController.answerQuestion('A');

      final state = container.read(quizControllerProvider('karma'));
      expect(state.score, 1);
      expect(state.status, QuizStatus.correct);
      expect(state.selectedAnswers[1], 'A');
    });

    test('QuizController should handle incorrect answer', () {
      final quizController = container.read(
        quizControllerProvider('karma').notifier,
      );
      final questions = [
        Question(
          id: 1,
          questionText: 'Test question?',
          options: {'A': 'Option A', 'B': 'Option B'},
          correctAnswerKey: 'A',
          explanation: 'Test explanation',
          category: 'Test Category',
        ),
      ];

      quizController.initializeQuiz(questions, examId: 'karma');
      quizController.answerQuestion('B');

      final state = container.read(quizControllerProvider('karma'));
      expect(state.score, 0);
      expect(state.status, QuizStatus.incorrect);
      expect(state.selectedAnswers[1], 'B');
    });

    test('QuizController should move to next question', () {
      final quizController = container.read(
        quizControllerProvider('karma').notifier,
      );
      final questions = [
        Question(
          id: 1,
          questionText: 'Question 1?',
          options: {'A': 'Option A', 'B': 'Option B'},
          correctAnswerKey: 'A',
          explanation: 'Test explanation',
          category: 'Test Category',
        ),
        Question(
          id: 2,
          questionText: 'Question 2?',
          options: {'A': 'Option A', 'B': 'Option B'},
          correctAnswerKey: 'B',
          explanation: 'Test explanation',
          category: 'Test Category',
        ),
      ];

      quizController.initializeQuiz(questions, examId: 'karma');
      quizController.answerQuestion('A');
      quizController.nextQuestion();

      final state = container.read(quizControllerProvider('karma'));
      expect(state.questionIndex, 1);
      expect(state.status, QuizStatus.initial);
    });

    test('QuizController should complete quiz', () {
      final quizController = container.read(
        quizControllerProvider('karma').notifier,
      );
      final questions = [
        Question(
          id: 1,
          questionText: 'Question 1?',
          options: {'A': 'Option A', 'B': 'Option B'},
          correctAnswerKey: 'A',
          explanation: 'Test explanation',
          category: 'Test Category',
        ),
      ];

      quizController.initializeQuiz(questions);
      quizController.answerQuestion('A');
      quizController.nextQuestion();

      final state = container.read(quizControllerProvider('karma'));
      expect(state.questionIndex, 1);
      expect(state.status, QuizStatus.complete);
      expect(state.isComplete, true);
    });

    test('QuizController should reset quiz', () {
      final quizController = container.read(
        quizControllerProvider('karma').notifier,
      );
      final questions = [
        Question(
          id: 1,
          questionText: 'Test question?',
          options: {'A': 'Option A', 'B': 'Option B'},
          correctAnswerKey: 'A',
          explanation: 'Test explanation',
          category: 'Test Category',
        ),
      ];

      quizController.initializeQuiz(questions);
      quizController.answerQuestion('A');
      quizController.nextQuestion();
      quizController.reset();

      final state = container.read(quizControllerProvider('karma'));
      expect(state.questionIndex, 0);
      expect(state.selectedAnswers, isEmpty);
      expect(state.score, 0);
      expect(state.status, QuizStatus.initial);
    });
  });
}
