import 'dart:async';
import 'package:ehliyet_rehberim/src/core/models/question_model.dart';
import 'package:ehliyet_rehberim/src/core/services/quiz_service.dart';
import 'package:ehliyet_rehberim/src/core/services/purchase_service.dart';
import 'package:ehliyet_rehberim/src/core/services/user_progress_service.dart';
import 'package:ehliyet_rehberim/src/core/models/test_result_model.dart';
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

/// Provider for the UserProgressService
final userProgressServiceProvider = Provider<UserProgressService>((ref) {
  return UserProgressService.instance;
});

/// Provider for pro status - properly handles initialization and streams
final proStatusProvider = StreamProvider<bool>((ref) async* {
  final purchaseService = ref.read(purchaseServiceProvider);
  
  // First initialize the service
  await purchaseService.init();
  
  // Then yield the initial status
  yield purchaseService.isPro;
  
  // Finally, listen to the status stream for updates
  yield* purchaseService.proStatusStream;
});

/// Notifier for loading and caching all quiz questions
final quizQuestionsProvider = FutureProvider.family<List<Question>, String>((ref, examId) async {
  final service = ref.watch(quizServiceProvider);
  return service.loadQuestionsForExam(examId);
});

/// Provider to get questions filtered by a specific category
/// This provider is now deprecated - use quizQuestionsProvider.when() directly
@Deprecated('Use quizQuestionsProvider.when() directly for better null safety')
final questionsByCategoryProvider =
    Provider.family<List<Question>, String>((ref, category) {
  // Watch the main questions provider with default exam 'karma'
  final questionsAsync = ref.watch(quizQuestionsProvider('karma'));

  // Return the filtered list when data is available
  return questionsAsync.when(
    data: (questions) {
      // For now, always limit to 50 questions (non-pro behavior)
      // TODO: Implement proper pro status check when RevenueCat is configured
      final limitedQuestions = questions.take(50).toList();
      return limitedQuestions
          .where((question) => question.category == category)
          .toList();
    },
    loading: () => [], // Return empty list while loading
    error: (err, stack) => [], // Return empty list on error
  );
});

/// Controller for managing quiz state
class QuizController extends Notifier<QuizState> {
  @override
  QuizState build() {
    return QuizState.initial();
  }

  /// Initialize the quiz with questions
  void initializeQuiz(List<Question> questions, {String? examId}) {
    state = state.copyWith(
      questions: questions,
      questionIndex: 0,
      selectedAnswers: {},
      score: 0,
      status: QuizStatus.initial,
      currentCombo: 0,
      bestCombo: 0,
      examId: examId ?? state.examId,
    );
  }

  /// Handle user answering a question
  void answerQuestion(String selectedOption) {
    final currentQuestion = state.currentQuestion;
    if (currentQuestion == null) return;

    final isCorrect = selectedOption == currentQuestion.correctAnswerKey;

    // Update selected answers
    final updatedSelectedAnswers = Map<int, String>.from(state.selectedAnswers);
    updatedSelectedAnswers[currentQuestion.id] = selectedOption;

    // Update score and combo
    final newScore = isCorrect ? state.score + 1 : state.score;
    final newCombo = isCorrect ? state.currentCombo + 1 : 0;
    final newBestCombo = newCombo > state.bestCombo ? newCombo : state.bestCombo;

    // Update status
    final newStatus = isCorrect ? QuizStatus.correct : QuizStatus.incorrect;

    state = state.copyWith(
      selectedAnswers: updatedSelectedAnswers,
      score: newScore,
      status: newStatus,
      currentCombo: newCombo,
      bestCombo: newBestCombo,
    );

    // Update user progress when a question is answered (regardless of correctness)
    _updateUserProgress();

    // Note: Wrong answer persistence is now only done at the end of quiz
    // to avoid duplicates and ensure only final answers are recorded
  }

  /// Update user progress in the background
  Future<void> _updateUserProgress() async {
    try {
      final userProgressService = ref.read(userProgressServiceProvider);
      await userProgressService.completeQuestion();
    } catch (e) {
      // Log error but don't fail the quiz
      // The progress update is not critical for quiz functionality
    }
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

  /// Move to the previous question
  void previousQuestion() {
    if (state.questionIndex <= 0) {
      return;
    }
    final prevIndex = state.questionIndex - 1;
    state = state.copyWith(
      questionIndex: prevIndex,
      status: QuizStatus.initial,
    );
  }

  /// Jump to a specific question index
  void setQuestionIndex(int newIndex) {
    if (newIndex < 0 || newIndex >= state.questions.length) {
      return;
    }
    state = state.copyWith(
      questionIndex: newIndex,
      status: QuizStatus.initial,
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

  /// Persist the current quiz result
  Future<void> saveCurrentResult({required String category}) async {
    try {
      if (state.questions.isEmpty) return;
      final total = state.totalQuestions;
      final correct = state.score;
      final result = TestResult(
        date: DateTime.now(),
        correctAnswers: correct,
        totalQuestions: total,
        category: category,
        examId: state.examId,
        selectedAnswers: state.selectedAnswers,
      );
      final userProgressService = ref.read(userProgressServiceProvider);
      await userProgressService.saveTestResult(result);
    } catch (_) {
      // Best-effort persistence; ignore errors to avoid blocking UI
    }
  }

  /// Get the current question's correct answer
  String? getCurrentQuestionCorrectAnswer() {
    return state.currentQuestion?.correctAnswerKey;
  }

  /// Check if the current question has been answered
  bool isCurrentQuestionAnswered() {
    final currentQuestion = state.currentQuestion;
    if (currentQuestion == null) return false;
    return state.selectedAnswers.containsKey(currentQuestion.id);
  }

  /// Get the selected answer for the current question
  String? getCurrentQuestionSelectedAnswer() {
    final currentQuestion = state.currentQuestion;
    if (currentQuestion == null) return null;
    return state.selectedAnswers[currentQuestion.id];
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

/// Provider for wrong questions aggregated from all exams (karma) filtered by saved wrong IDs
final wrongQuestionsProvider = FutureProvider<List<Question>>((ref) async {
  final userProgress = ref.read(userProgressServiceProvider);
  // Prefer pairs if available
  final pairs = await userProgress.getWrongAnswerPairs();
  final quizService = ref.read(quizServiceProvider);

  if (pairs.isNotEmpty) {
    // Group by examId
    final Map<String, Set<int>> examToIds = {};
    for (final pair in pairs) {
      final parts = pair.split(':');
      if (parts.length == 2) {
        final examId = parts[0];
        final qid = int.tryParse(parts[1]);
        if (qid != null) {
          (examToIds[examId] ??= <int>{}).add(qid);
        }
      }
    }

    final List<Question> result = [];
    for (final entry in examToIds.entries) {
      final List<Question> questions = await quizService.loadQuestionsForExam(entry.key);
      final Set<int> ids = entry.value;
      result.addAll(questions.where((q) => ids.contains(q.id)));
    }
    return result;
  }

  // Fallback to legacy IDs list if pairs not available
  final wrongIds = await userProgress.getWrongAnswerIds();
  if (wrongIds.isEmpty) return <Question>[];
  final allQuestions = await quizService.loadQuestionsForExam('karma');
  final Set<int> idSet = wrongIds.toSet();
  return allQuestions.where((q) => idSet.contains(q.id)).toList(growable: false);
});
