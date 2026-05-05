/// Represents a partial payment toward a total amount.
class PartialPayment {
  final int? id;
  final DateTime date;
  final int targetMonth;
  final double value;

  PartialPayment({
    this.id,
    required this.date,
    required this.targetMonth,
    required this.value,
  });

  factory PartialPayment.fromJson(Map<String, dynamic> json) {
    return PartialPayment(
      id: json['id'] as int?,
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      targetMonth: json['targetMonth'] ?? 0,
      value: (json['value'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'targetMonth': targetMonth,
      'value': value,
    };
  }
}
