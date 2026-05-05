import 'class_type.dart';
import '../../../../models/planning.dart';

/// Represents a school class.
/// Renamed from 'Class' to 'SchoolClass' to avoid Dart reserved keyword conflict.
class SchoolClass {
  final int? id;
  final int year;
  final int capacity;
  final bool isArchived;
  final String name;
  final ClassType? classType;
  
  final Planning? planning;

  SchoolClass({
    this.id,
    required this.year,
    required this.capacity,
    required this.isArchived,
    required this.name,
    this.classType,
    this.planning,
  });

  factory SchoolClass.fromJson(Map<String, dynamic> json) {
    return SchoolClass(
      id: json['id'] as int?,
      year: json['year'] ?? 0,
      capacity: json['capacity'] ?? 0,
      isArchived: json['isArchived'] ?? false,
      name: json['name'] ?? '',
      classType: json['classType'] != null
          ? ClassType.fromJson(json['classType'] as Map<String, dynamic>)
          : null,
      planning: json['planning'] != null
          ? Planning.fromJson(json['planning'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'year': year,
      'capacity': capacity,
      'isArchived': isArchived,
      'name': name,
      'classType': classType?.toJson(),
      'planning': planning?.toJson(),
    };
  }
}
