
/// Immutable model representing a quiz question
class Question {
  final int id;
  final String questionText;
  final String? imageUrl;
  final Map<String, String> options;
  final String correctAnswerKey;
  final String explanation;
  final String category;

  const Question({
    required this.id,
    required this.questionText,
    this.imageUrl,
    required this.options,
    required this.correctAnswerKey,
    required this.explanation,
    required this.category,
  });

  /// Factory constructor to create a Question from JSON
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as int,
      questionText: json['questionText'] as String,
      imageUrl: json['imageUrl'] as String?,
      options: Map<String, String>.from(json['options'] as Map),
      correctAnswerKey: json['correctAnswerKey'] as String,
      explanation: json['explanation'] as String,
      category: json['category'] as String,
    );
  }

  /// Convert Question to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionText': questionText,
      'imageUrl': imageUrl,
      'options': options,
      'correctAnswerKey': correctAnswerKey,
      'explanation': explanation,
      'category': category,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Question &&
        other.id == id &&
        other.questionText == questionText &&
        other.imageUrl == imageUrl &&
        other.options == options &&
        other.correctAnswerKey == correctAnswerKey &&
        other.explanation == explanation &&
        other.category == category;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      questionText,
      imageUrl,
      options,
      correctAnswerKey,
      explanation,
      category,
    );
  }

  @override
  String toString() {
    return 'Question(id: $id, questionText: $questionText, imageUrl: $imageUrl, options: $options, correctAnswerKey: $correctAnswerKey, explanation: $explanation, category: $category)';
  }
} 