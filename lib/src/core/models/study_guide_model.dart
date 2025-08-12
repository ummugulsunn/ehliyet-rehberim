/// Base type for all content blocks displayed in a StudyGuide.
abstract class ContentBlock {
  const ContentBlock();

  factory ContentBlock.fromJson(Map<String, dynamic> json) {
    final String type = (json['type'] as String?)?.toLowerCase() ?? '';
    switch (type) {
      case 'subheading':
        return SubheadingBlock(json['text'] as String? ?? '');
      case 'paragraph':
        return ParagraphBlock(json['text'] as String? ?? '');
      case 'image':
        return ImageBlock(json['imageUrl'] as String? ?? '');
      case 'key_info':
      case 'keyinfo':
        return KeyInfoBlock(json['text'] as String? ?? '');
      default:
        // Fallback to paragraph to avoid crashes if unknown
        return ParagraphBlock(json['text'] as String? ?? '');
    }
  }

  Map<String, dynamic> toJson();
}

class SubheadingBlock extends ContentBlock {
  final String text;
  const SubheadingBlock(this.text);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'subheading',
        'text': text,
      };
}

class ParagraphBlock extends ContentBlock {
  final String text;
  const ParagraphBlock(this.text);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'paragraph',
        'text': text,
      };
}

class ImageBlock extends ContentBlock {
  final String imageUrl;
  const ImageBlock(this.imageUrl);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'image',
        'imageUrl': imageUrl,
      };
}

class KeyInfoBlock extends ContentBlock {
  final String text;
  const KeyInfoBlock(this.text);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'key_info',
        'text': text,
      };
}

class StudyGuide {
  final String category;
  final String title;
  final List<ContentBlock> content; // Structured content blocks
  final String? markdown; // Optional Markdown content

  const StudyGuide({
    required this.category,
    required this.title,
    required this.content,
    this.markdown,
  });

  factory StudyGuide.fromJson(Map<String, dynamic> json) {
    final dynamic raw = json['content'];
    if (raw is String) {
      return StudyGuide(
        category: json['category'] as String,
        title: json['title'] as String,
        content: const <ContentBlock>[],
        markdown: raw,
      );
    }

    final List<dynamic> listRaw = raw as List<dynamic>? ?? <dynamic>[];
    return StudyGuide(
      category: json['category'] as String,
      title: json['title'] as String,
      content: listRaw
          .map((e) => ContentBlock.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
        'category': category,
        'title': title,
        'content': markdown ?? content.map((e) => e.toJson()).toList(growable: false),
      };
}

