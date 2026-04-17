/// Represents a dietary comment.
class DietaryComment {
  final int? id;
  final String content;
  DietaryComment({this.id, required this.content});

  factory DietaryComment.fromJson(Map<String, dynamic> json) {
    return DietaryComment(
      id: json['id'] as int?,
      content: json['content'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
      };
}
