/// Represents a health-related comment.
class HealthComment {
  final int? id;
  final String content;
  HealthComment({this.id, required this.content});

  factory HealthComment.fromJson(Map<String, dynamic> json) {
    return HealthComment(
      id: json['id'] as int?,
      content: json['content'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
      };
}
