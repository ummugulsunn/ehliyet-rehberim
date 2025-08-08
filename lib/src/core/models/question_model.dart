
/// Immutable model representing a quiz question
class Question {
  final int id;
  final String questionText;
  final String? imageUrl;
  final Map<String, dynamic> options; // Changed to dynamic to support both String and Map
  final String correctAnswerKey;
  final String explanation;
  final String category;
  /// The source examId that this question belongs to. This is populated by the loader.
  final String? examId;

  const Question({
    required this.id,
    required this.questionText,
    this.imageUrl,
    required this.options,
    required this.correctAnswerKey,
    required this.explanation,
    required this.category,
    this.examId,
  });

  /// Factory constructor to create a Question from JSON
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as int,
      questionText: json['questionText'] as String,
      imageUrl: json['imageUrl'] as String?,
      options: json['options'] as Map<String, dynamic>,
      correctAnswerKey: json['correctAnswerKey'] as String,
      explanation: json['explanation'] as String,
      category: json['category'] as String,
      // examId is intentionally not read from JSON; it is set by the loader
      examId: json['examId'] as String?,
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
      if (examId != null) 'examId': examId,
    };
  }

  /// Create a new Question with the provided examId
  Question withExamId(String examId) {
    return Question(
      id: id,
      questionText: questionText,
      imageUrl: imageUrl,
      options: options,
      correctAnswerKey: correctAnswerKey,
      explanation: explanation,
      category: category,
      examId: examId,
    );
  }

  /// Helper method to get option text
  String getOptionText(String key) {
    final option = options[key];
    if (option is String) {
      return option;
    } else if (option is Map<String, dynamic>) {
      return option['text'] as String? ?? '';
    }
    return '';
  }

  /// Helper method to get option image URL
  String? getOptionImageUrl(String key) {
    final option = options[key];
    if (option is Map<String, dynamic>) {
      return option['imageUrl'] as String?;
    }
    return null;
  }

  /// Check if options have images
  bool get hasOptionImages {
    return options.values.any((option) => option is Map<String, dynamic>);
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
        other.category == category &&
        other.examId == examId;
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
      examId,
    );
  }

  @override
  String toString() {
    return 'Question(id: $id, questionText: $questionText, imageUrl: $imageUrl, options: $options, correctAnswerKey: $correctAnswerKey, explanation: $explanation, category: $category, examId: $examId)';
  }
} 