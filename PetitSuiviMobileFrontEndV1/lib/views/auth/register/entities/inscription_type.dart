/// Represents the type of inscription (e.g., "Kindergarten", "Preschool").
class InscriptionType {
  final int? id;
  final String name;
  InscriptionType({this.id, required this.name});

  static const String kindergarten = "Kindergarten";
  static const String preschool = "Preschool";

  factory InscriptionType.fromJson(Map<String, dynamic> json) {
    return InscriptionType(
      id: json['id'] as int?,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}
