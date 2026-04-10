import 'package:flutter/material.dart';

/// Represents the profile details of a teacher.
class TeacherProfile {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final int age;
  final String specialization;
  final int yearsOfExperience;

  /// Creates a new [TeacherProfile] instance.
  TeacherProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.age,
    required this.specialization,
    required this.yearsOfExperience,
  });

  /// Returns the teacher's full name.
  String get fullName => '$firstName $lastName';
}

/// Represents a classroom entity containing and managed children.
class ClassRoom {
  final String id;
  final String name;
  final List<MockChild> children;
  final DateTime? planningStartDate;
  final DateTime? planningEndDate;

  /// Creates a new [ClassRoom] instance.
  ClassRoom({
    required this.id,
    required this.name,
    required this.children,
    this.planningStartDate,
    this.planningEndDate,
  });
}

/// Represents a simple text note associated with a child for a specific date.
class ChildNote {
  final DateTime date;
  final String text;

  /// Creates a new [ChildNote] instance.
  ChildNote({required this.date, required this.text});
}

/// A mock representation of a child used for testing and UI prototyping within teacher views.
class MockChild {
  final String id;
  final String firstName;
  final String lastName;
  final int age;
  final String classId;
  final List<ChildNote> notes;

  /// Creates a new [MockChild] instance.
  MockChild({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.classId,
    List<ChildNote>? notes,
  }) : notes = notes ?? [];

  /// Returns the child's full name.
  String get fullName => '$firstName $lastName';
}

/// Represents an activity suggested by a teacher for review.
class ActivitySuggestion {
  final String id;
  final String name;
  final String description;
  final String day;
  final String time;
  final bool isConfirmedByAdmin;

  /// Creates a new [ActivitySuggestion] instance.
  ActivitySuggestion({
    required this.id,
    required this.name,
    required this.description,
    required this.day,
    required this.time,
    required this.isConfirmedByAdmin,
  });
}

/// Represents a scheduled activity for a specific classroom.
class ClassActivity {
  final String id;
  final String classId;
  final String title;
  final String description;
  final DateTime date;
  final String time;
  final IconData? icon;

  /// The execution status (e.g., null, 'executed', or 'not_executed').
  String? status;

  /// Creates a new [ClassActivity] instance.
  ClassActivity({
    required this.id,
    required this.classId,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    this.icon,
    this.status,
  });
}

// --- Attendance ---

/// Represents an attendance record for a single child on a specific date.
class AttendanceRecord {
  final String childId;
  final DateTime date;
  bool isPresent;

  /// Creates a new [AttendanceRecord] instance. Defaults to present.
  AttendanceRecord({
    required this.childId,
    required this.date,
    this.isPresent = true,
  });
}

// --- Competency Tracking ---

/// Enumerates the different skill categories for competency tracking.
enum CompetencySkill { motricite, langage, autonomie, interactionSociale }

/// Enumerates the acquisition levels for a specific skill.
enum CompetencyLevel { enCours, acquise, aRenforcer }

/// Represents a competency assessment record for a child.
class CompetencyRecord {
  final String childId;
  final CompetencySkill skill;
  CompetencyLevel level;
  final DateTime date;
  final String? comment;

  /// Creates a new [CompetencyRecord] instance.
  CompetencyRecord({
    required this.childId,
    required this.skill,
    required this.level,
    required this.date,
    this.comment,
  });
}
