/// Represents the status of an inscription (e.g., "rejected", "pending", "approved").
class InscriptionStatus {
  final int? id;
  final String name;
  InscriptionStatus({this.id, required this.name});

  static const String rejected = "rejected";
  static const String pending = "pending";
  static const String approved = "approved";

  factory InscriptionStatus.fromJson(Map<String, dynamic> json) {
    return InscriptionStatus(
      id: json['id'] as int?,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}
