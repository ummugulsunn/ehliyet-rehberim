import 'dart:convert';

class UnfinishedExam {
  final String examId;
  final int currentQuestionIndex;
  final int remainingSeconds;
  final List<int> questionIds; // To restore specific question order/selection
  final Map<String, String> answers; // QuestionId -> AnswerKey
  final DateTime savedAt;

  UnfinishedExam({
    required this.examId,
    required this.questionIds,
    required this.currentQuestionIndex,
    required this.remainingSeconds,
    required this.answers,
    required this.savedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'examId': examId,
      'questionIds': questionIds,
      'currentQuestionIndex': currentQuestionIndex,
      'remainingSeconds': remainingSeconds,
      'answers': answers,
      'savedAt': savedAt.millisecondsSinceEpoch,
    };
  }

  factory UnfinishedExam.fromMap(Map<String, dynamic> map) {
    return UnfinishedExam(
      examId: map['examId'] ?? '',
      questionIds: List<int>.from(map['questionIds'] ?? []),
      currentQuestionIndex: map['currentQuestionIndex']?.toInt() ?? 0,
      remainingSeconds: map['remainingSeconds']?.toInt() ?? 0,
      answers: Map<String, String>.from(map['answers'] ?? {}),
      savedAt: DateTime.fromMillisecondsSinceEpoch(map['savedAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory UnfinishedExam.fromJson(String source) => UnfinishedExam.fromMap(json.decode(source));
}
