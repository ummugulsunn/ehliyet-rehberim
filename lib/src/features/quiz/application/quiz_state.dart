import 'package:ehliyet_rehberim/src/features/quiz/domain/question_model.dart';

enum QuizStatus { initial, correct, incorrect, complete }

class QuizState {
  final List<Question> questions;
  final int questionIndex;
  final Map<int, String> selectedAnswers;
  final int score;
  final QuizStatus status;
  final int currentCombo;
  final int bestCombo;
  final String? examId;

  const QuizState({
    required this.questions,
    required this.questionIndex,
    required this.selectedAnswers,
    required this.score,
    required this.status,
    required this.currentCombo,
    required this.bestCombo,
    this.examId,
  });

  factory QuizState.initial() {
    return const QuizState(
      questions: [],
      questionIndex: 0,
      selectedAnswers: {},
      score: 0,
      status: QuizStatus.initial,
      currentCombo: 0,
      bestCombo: 0,
      examId: null,
    );
  }

  bool get isComplete => status == QuizStatus.complete;

  /// Get the total number of questions
  int get totalQuestions => questions.length;

  /// Get the current progress percentage
  double get progressPercentage {
    if (questions.isEmpty) return 0.0;
    return selectedAnswers.length / questions.length;
  }

  Question? get currentQuestion {
    if (questions.isEmpty || questionIndex >= questions.length) {
      return null;
    }
    return questions[questionIndex];
  }

  QuizState copyWith({
    List<Question>? questions,
    int? questionIndex,
    Map<int, String>? selectedAnswers,
    int? score,
    QuizStatus? status,
    int? currentCombo,
    int? bestCombo,
    String? examId,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      questionIndex: questionIndex ?? this.questionIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      score: score ?? this.score,
      status: status ?? this.status,
      currentCombo: currentCombo ?? this.currentCombo,
      bestCombo: bestCombo ?? this.bestCombo,
      examId: examId ?? this.examId,
    );
  }
}
