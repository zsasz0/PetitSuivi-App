/// Represents a school planning period (e.g., a school year or semester).
class Planning {
  final int? id;
  final String label;
  final DateTime startDate;
  final DateTime endDate;
  final bool isArchived;

  Planning({
    this.id,
    required this.label,
    required this.startDate,
    required this.endDate,
    required this.isArchived,
  });

  factory Planning.fromJson(Map<String, dynamic> json) {
    return Planning(
      id: json['id'] as int?,
      label: json['label'] ?? '',
      startDate: json['startDate'] != null || json['start_date'] != null
          ? DateTime.parse((json['startDate'] ?? json['start_date']).toString())
          : DateTime.now(),
      endDate: json['endDate'] != null || json['end_date'] != null
          ? DateTime.parse((json['endDate'] ?? json['end_date']).toString())
          : DateTime.now(),
      isArchived: _parseBool(json['isArchived'] ?? json['is_archived']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isArchived': isArchived,
    };
  }

  /// Safely parses a value that may be bool, int (0/1), or string ("true"/"1").
  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    final s = value.toString().toLowerCase().trim();
    return s == 'true' || s == '1';
  }
}
