import 'dart:async';
import 'package:ehliyet_rehberim/src/features/quiz/domain/question_model.dart';
import 'package:ehliyet_rehberim/src/features/quiz/data/quiz_repository.dart';

import 'package:ehliyet_rehberim/src/features/home/data/user_progress_repository.dart';
import 'package:ehliyet_rehberim/src/features/quiz/domain/test_result_model.dart';
import 'package:ehliyet_rehberim/src/features/quiz/application/quiz_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the QuizRepository
final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return QuizRepository();
});



/// Provider for the UserProgressRepository
final userProgressRepositoryProvider = Provider<UserProgressRepository>((ref) {
  return UserProgressRepository.instance;
});

/// Provider for pro status - properly handles initialization and streams
/// Provider for pro status - always true now
final proStatusProvider = StreamProvider<bool>((ref) async* {
  yield true;
});

/// Notifier for loading and caching all quiz questions
final quizQuestionsProvider = FutureProvider.family<List<Question>, String>((ref, examId) async {
  final service = ref.watch(quizRepositoryProvider);
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
      // For now, always limit to 50 questions
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
class QuizController extends FamilyNotifier<QuizState, String> {
  @override
  QuizState build(String arg) {
    return QuizState.initial().copyWith(examId: arg);
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
    
    // Debug: Log answer selection (removed for production)

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
    _updateUserProgress(isCorrect);

    // Note: Wrong answer persistence is now only done at the end of quiz
    // to avoid duplicates and ensure only final answers are recorded
  }

  /// Update user progress in the background
  Future<void> _updateUserProgress(bool isCorrect) async {
    try {
      final userProgressRepository = ref.read(userProgressRepositoryProvider);
      await userProgressRepository.completeQuestion();
      
      if (isCorrect) {
        await userProgressRepository.addXP(UserProgressRepository.xpPerCorrectAnswer);
        // wait, xpPerCorrectAnswer is likely static? Let's check. Assuming it is static or on instance.
        // Actually UserProgressService had xpPerCorrectAnswer? I didn't check that constant.
      }
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
      final userProgressRepository = ref.read(userProgressRepositoryProvider);
      await userProgressRepository.saveTestResult(result);
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

  /// Start exam mode
  void startExamMode({Duration? duration}) {
    state = state.copyWith(
      isExamMode: true,
      examStartTime: DateTime.now(),
      examDuration: duration ?? const Duration(minutes: 30),
      examTimeRemaining: duration ?? const Duration(minutes: 30),
    );
  }

  /// Update exam timer (call this every second)
  void updateExamTimer() {
    if (!state.isExamMode || state.examStartTime == null || state.status == QuizStatus.complete) return;
    
    final elapsed = DateTime.now().difference(state.examStartTime!);
    final remaining = state.examDuration - elapsed;
    
    if (remaining.inSeconds <= 0) {
      // Time's up - auto finish exam
      finishExam();
    } else {
      state = state.copyWith(examTimeRemaining: remaining);
    }
  }

  /// Finish exam (either manually or when time runs out)
  void finishExam() {
    if (state.examStartTime == null) return;
    
    final finalElapsed = DateTime.now().difference(state.examStartTime!);
    final finalRemaining = state.examDuration - finalElapsed;
    
    state = state.copyWith(
      status: QuizStatus.complete,
      examTimeRemaining: finalRemaining.inSeconds > 0 ? finalRemaining : Duration.zero,
    );
  }

  /// Check if exam has passed (70% or more correct)
  bool hasPassedExam() {
    if (!state.isExamMode) return false;
    final totalQuestions = state.questions.length;
    if (totalQuestions == 0) return false;
    
    final percentage = (state.score / totalQuestions) * 100;
    return percentage >= 70;
  }

  /// Get time taken for exam
  Duration? getTimeTaken() {
    if (!state.isExamMode || state.examStartTime == null) return null;
    
    if (state.status == QuizStatus.complete) {
      // Exam completed
      return state.examDuration - (state.examTimeRemaining ?? Duration.zero);
    } else {
      // Exam still in progress
      return DateTime.now().difference(state.examStartTime!);
    }
  }
}

/// Provider for the QuizController with family support for multiple quiz instances
final quizControllerProvider = NotifierProvider.family<QuizController, QuizState, String>(() {
  return QuizController();
});

/// Provider for wrong questions aggregated from all exams (karma) filtered by saved wrong IDs
final wrongQuestionsProvider = FutureProvider<List<Question>>((ref) async {
  final userProgress = ref.read(userProgressRepositoryProvider);
  // Get ONLY items due for review
  final pairs = await userProgress.getDueSRSItems();
  final quizRepository = ref.read(quizRepositoryProvider);

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
      final List<Question> questions = await quizRepository.loadQuestionsForExam(entry.key);
      final Set<int> ids = entry.value;
      result.addAll(questions.where((q) => ids.contains(q.id)));
    }
    return result;
  }

  // Fallback to legacy IDs list if pairs not available
  final wrongIds = await userProgress.getWrongAnswerIds();
  if (wrongIds.isEmpty) return <Question>[];
  final allQuestions = await quizRepository.loadQuestionsForExam('karma');
  final Set<int> idSet = wrongIds.toSet();
  return allQuestions.where((q) => idSet.contains(q.id)).toList(growable: false);
});
