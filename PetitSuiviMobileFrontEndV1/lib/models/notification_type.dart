class NotificationType {
  final int? id;
  final String name;

  NotificationType({
    this.id,
    required this.name,
  });

  factory NotificationType.fromJson(Map<String, dynamic> json) {
    return NotificationType(
      id: json['id'] as int?,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
