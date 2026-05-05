import '../../../../models/dietary_comment.dart';
import '../../../../models/health_comment.dart';
import '../../../../models/child_food_exception_override.dart';

/// Represents a medical form for a child.
class MedicalForm {
  final int? id;
  final String formData;

  /// Optional: multiplicity 0..1
  final DietaryComment? dietaryComment;
  final HealthComment? healthComment;
  final ChildFoodExceptionOverride? foodOverride;

  MedicalForm({
    this.id,
    required this.formData,
    this.dietaryComment,
    this.healthComment,
    this.foodOverride,
  });

  factory MedicalForm.fromJson(Map<String, dynamic> json) {
    return MedicalForm(
      id: json['id'] as int?,
      formData: json['formData'] ?? '',
      dietaryComment: json['dietaryComment'] != null
          ? DietaryComment.fromJson(json['dietaryComment'] as Map<String, dynamic>)
          : null,
      healthComment: json['healthComment'] != null
          ? HealthComment.fromJson(json['healthComment'] as Map<String, dynamic>)
          : null,
      foodOverride: json['foodOverride'] != null
          ? ChildFoodExceptionOverride.fromJson(json['foodOverride'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'formData': formData,
      'dietaryComment': dietaryComment?.toJson(),
      'healthComment': healthComment?.toJson(),
      'foodOverride': foodOverride?.toJson(),
    };
  }
}
