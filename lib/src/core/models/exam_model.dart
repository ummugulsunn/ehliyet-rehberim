import 'question_model.dart';

class Exam {
  final String examId;
  final String examName;
  final List<Question> questions;

  const Exam({
    required this.examId,
    required this.examName,
    required this.questions,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    final List<dynamic> q = json['questions'] as List<dynamic>? ?? [];
    return Exam(
      examId: json['examId'] as String,
      examName: json['examName'] as String,
      questions: q.map((e) => Question.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'examId': examId,
        'examName': examName,
        'questions': questions.map((e) => e.toJson()).toList(),
      };
}

