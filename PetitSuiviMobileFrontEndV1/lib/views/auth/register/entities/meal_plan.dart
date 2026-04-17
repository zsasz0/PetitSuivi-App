/// Represents a meal plan for a child.
class MealPlan {
  final int? id;
  final String name;
  MealPlan({this.id, required this.name});

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      id: json['id'] as int?,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}
