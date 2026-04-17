/// Represents a food exception for a child.
class ChildFoodException {
  final int? id;
  final String reason;
  ChildFoodException({this.id, required this.reason});

  factory ChildFoodException.fromJson(Map<String, dynamic> json) {
    return ChildFoodException(
      id: json['id'] as int?,
      reason: json['reason'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reason': reason,
      };
}
