/// Represents an absence record.
class Absence {
  final int? id;
  final DateTime date;
  Absence({this.id, required this.date});

  factory Absence.fromJson(Map<String, dynamic> json) {
    return Absence(
      id: json['id'] as int?,
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
      };
}
