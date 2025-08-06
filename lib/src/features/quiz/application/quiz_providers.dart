import 'package:ehliyet_rehberim/src/core/models/question_model.dart';
import 'package:ehliyet_rehberim/src/core/services/quiz_service.dart';
import 'package:ehliyet_rehberim/src/core/services/purchase_service.dart';
import 'package:ehliyet_rehberim/src/features/quiz/application/quiz_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the QuizService
final quizServiceProvider = Provider<QuizService>((ref) {
  return QuizService();
});

/// Provider for the PurchaseService
final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  return PurchaseService();
});

/// Stream provider for pro status
final proStatusProvider = StreamProvider<bool>((ref) {
  final purchaseService = ref.read(purchaseServiceProvider);
  return purchaseService.proStatusStream;
});

/// Provider for loading questions from JSON with optional category filtering and pro status check
final quizQuestionsProvider = FutureProvider.family<List<Question>, String?>((ref, category) async {
  final quizService = ref.read(quizServiceProvider);
  final purchaseService = ref.read(purchaseServiceProvider);
  final allQuestions = await quizService.loadQuestions();
  
  // Check pro status
  final isPro = purchaseService.isPro;
  
  // If user is not pro, limit to first 50 questions
  final limitedQuestions = isPro ? allQuestions : allQuestions.take(50).toList();
  
  // If category is null, return all questions (limited or full based on pro status)
  if (category == null) {
    return limitedQuestions;
  }
  
  // Otherwise, filter questions by category from the limited/full list
  return limitedQuestions.where((question) => question.category == category).toList();
});

/// Controller for managing quiz state
class QuizController extends Notifier<QuizState> {
  @override
  QuizState build() {
    return QuizState.initial();
  }

  /// Initialize the quiz with questions
  void initializeQuiz(List<Question> questions) {
    state = state.copyWith(
      questions: questions,
      questionIndex: 0,
      selectedAnswers: {},
      score: 0,
      status: QuizStatus.initial,
    );
  }

  /// Handle user answering a question
  void answerQuestion(String selectedOption) {
    if (state.currentQuestion == null) return;

    final currentQuestion = state.currentQuestion!;
    final isCorrect = selectedOption == currentQuestion.correctAnswerKey;

    // Update selected answers
    final updatedSelectedAnswers = Map<int, String>.from(state.selectedAnswers);
    updatedSelectedAnswers[currentQuestion.id] = selectedOption;

    // Update score
    final newScore = isCorrect ? state.score + 1 : state.score;

    // Update status
    final newStatus = isCorrect ? QuizStatus.correct : QuizStatus.incorrect;

    state = state.copyWith(
      selectedAnswers: updatedSelectedAnswers,
      score: newScore,
      status: newStatus,
    );
  }

  /// Move to the next question
  void nextQuestion() {
    if (state.isComplete) {
      // Quiz is already complete
      return;
    }

    final nextIndex = state.questionIndex + 1;
    final newStatus = nextIndex >= state.questions.length 
        ? QuizStatus.complete 
        : QuizStatus.initial;

    state = state.copyWith(
      questionIndex: nextIndex,
      status: newStatus,
    );
  }

  /// Reset the quiz to initial state
  void reset() {
    if (state.questions.isEmpty) return;

    state = state.copyWith(
      questionIndex: 0,
      selectedAnswers: {},
      score: 0,
      status: QuizStatus.initial,
    );
  }

  /// Get the current question's correct answer
  String? getCurrentQuestionCorrectAnswer() {
    return state.currentQuestion?.correctAnswerKey;
  }

  /// Check if the current question has been answered
  bool isCurrentQuestionAnswered() {
    if (state.currentQuestion == null) return false;
    return state.selectedAnswers.containsKey(state.currentQuestion!.id);
  }

  /// Get the selected answer for the current question
  String? getCurrentQuestionSelectedAnswer() {
    if (state.currentQuestion == null) return null;
    return state.selectedAnswers[state.currentQuestion!.id];
  }

  /// Check if the current question was answered correctly
  bool isCurrentQuestionCorrect() {
    final selectedAnswer = getCurrentQuestionSelectedAnswer();
    final correctAnswer = getCurrentQuestionCorrectAnswer();
    return selectedAnswer == correctAnswer;
  }
}

/// Provider for the QuizController
final quizControllerProvider = NotifierProvider<QuizController, QuizState>(() {
  return QuizController();
});
