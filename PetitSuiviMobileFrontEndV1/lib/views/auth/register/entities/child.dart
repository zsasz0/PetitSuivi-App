import 'inscription.dart';
import 'class.dart';
import '../../../../models/absence.dart';
import '../../../../models/child_food_exception.dart';

/// Represents a child entity within the schooling platform.
class Child {
  final int? id;
  final String firstName;
  final String lastName;
  final DateTime birthDate;

  /// Multiplicity: 1 Child -> * Inscriptions
  final List<Inscription> inscriptions;

  /// Multiplicity: 1 Child -> * SchoolClasses
  final List<SchoolClass> classes;

  /// Multiplicity: 1 Child -> * Absences
  final List<Absence> absences;

  /// Multiplicity: 1 Child -> 1 Food Exception
  final ChildFoodException? foodException;

  Child({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    this.inscriptions = const [],
    this.classes = const [],
    this.absences = const [],
    this.foodException,
  });

  /// Returns the combined first and last name of the child.
  String get fullName => '$firstName $lastName';

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'] as int?,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      birthDate: json['birthDate'] != null ? DateTime.parse(json['birthDate']) : DateTime.now(),
      inscriptions: (json['inscriptions'] as List?)
              ?.map((i) => Inscription.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      classes: (json['classes'] as List?)
              ?.map((c) => SchoolClass.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      absences: (json['absences'] as List?)
              ?.map((a) => Absence.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      foodException: json['foodException'] != null
          ? ChildFoodException.fromJson(json['foodException'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'birthDate': birthDate.toIso8601String(),
      'inscriptions': inscriptions.map((i) => i.toJson()).toList(),
      'classes': classes.map((c) => c.toJson()).toList(),
      'absences': absences.map((a) => a.toJson()).toList(),
      'foodException': foodException?.toJson(),
    };
  }
}
