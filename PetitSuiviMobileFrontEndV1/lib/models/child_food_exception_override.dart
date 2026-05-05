/// Represents an override for a child's food exception.
class ChildFoodExceptionOverride {
  final int? id;
  final String? reason;
  ChildFoodExceptionOverride({this.id, this.reason});

  factory ChildFoodExceptionOverride.fromJson(Map<String, dynamic> json) {
    return ChildFoodExceptionOverride(
      id: json['id'] as int?,
      reason: json['reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reason': reason,
      };
}
