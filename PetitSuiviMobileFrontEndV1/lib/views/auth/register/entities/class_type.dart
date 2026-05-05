/// Represents the type of a school class.
class ClassType {
  final int? id;
  final String name;
  ClassType({this.id, required this.name});

  factory ClassType.fromJson(Map<String, dynamic> json) {
    return ClassType(
      id: json['id'] as int?,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}
