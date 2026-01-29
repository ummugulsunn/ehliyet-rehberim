class FavoriteItem {
  final int questionId;
  final String? note;
  final DateTime savedAt;

  const FavoriteItem({
    required this.questionId,
    this.note,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'note': note,
      'savedAt': savedAt.toIso8601String(),
    };
  }

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      questionId: json['questionId'] as int,
      note: json['note'] as String?,
      savedAt: DateTime.parse(json['savedAt'] as String),
    );
  }
    
  FavoriteItem copyWith({
    int? questionId,
    String? note,
    DateTime? savedAt,
  }) {
    return FavoriteItem(
      questionId: questionId ?? this.questionId,
      note: note ?? this.note,
      savedAt: savedAt ?? this.savedAt,
    );
  }
}
