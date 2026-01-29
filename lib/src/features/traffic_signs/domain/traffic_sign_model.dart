class TrafficSign {
  final String id;
  final String name;
  final String imageUrl;
  final String description;

  const TrafficSign({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
  });

  factory TrafficSign.fromJson(Map<String, dynamic> json) {
    return TrafficSign(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imageUrl': imageUrl,
        'description': description,
      };
}

class TrafficSignCategory {
  final String categoryName;
  final List<TrafficSign> signs;

  const TrafficSignCategory({
    required this.categoryName,
    required this.signs,
  });

  factory TrafficSignCategory.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawSigns = json['signs'] as List<dynamic>? ?? [];
    return TrafficSignCategory(
      categoryName: json['categoryName'] as String,
      signs: rawSigns
          .map((e) => TrafficSign.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
        'categoryName': categoryName,
        'signs': signs.map((e) => e.toJson()).toList(),
      };
}


