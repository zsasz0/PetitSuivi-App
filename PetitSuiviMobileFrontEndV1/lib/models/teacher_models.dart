import 'package:flutter/material.dart';
import 'planning.dart';

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

  factory TeacherProfile.fromJson(Map<String, dynamic> json) {
    return TeacherProfile(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      age: json['age'] as int,
      specialization: json['specialization'] as String,
      yearsOfExperience: json['yearsOfExperience'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'age': age,
      'specialization': specialization,
      'yearsOfExperience': yearsOfExperience,
    };
  }
}

/// Represents a classroom entity containing and managed children.
class ClassRoom {
  final String id;
  final String name;
  final List<MockChild> children;
  final int? planningId;
  final Planning? planning;

  /// Creates a new [ClassRoom] instance.
  ClassRoom({
    required this.id,
    required this.name,
    required this.children,
    this.planningId,
    this.planning,
  });

  factory ClassRoom.fromJson(Map<String, dynamic> json) {
    return ClassRoom(
      id: json['id'] as String,
      name: json['name'] as String,
      children: (json['children'] as List)
          .map((e) => MockChild.fromJson(e as Map<String, dynamic>))
          .toList(),
      planningId: json['planningId'] as int?,
      planning: json['planning'] != null
          ? Planning.fromJson(json['planning'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'children': children.map((e) => e.toJson()).toList(),
      'planningId': planningId,
      'planning': planning?.toJson(),
    };
  }
}

/// Represents a simple text note associated with a child for a specific date.
class ChildNote {
  final DateTime date;
  final String text;

  /// Creates a new [ChildNote] instance.
  ChildNote({required this.date, required this.text});

  factory ChildNote.fromJson(Map<String, dynamic> json) {
    return ChildNote(
      date: DateTime.parse(json['date']),
      text: json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'text': text,
    };
  }
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

  factory MockChild.fromJson(Map<String, dynamic> json) {
    return MockChild(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      age: json['age'] as int,
      classId: json['classId'] as String,
      notes: json['notes'] != null
          ? (json['notes'] as List)
              .map((e) => ChildNote.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'classId': classId,
      'notes': notes.map((e) => e.toJson()).toList(),
    };
  }
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

  factory ActivitySuggestion.fromJson(Map<String, dynamic> json) {
    return ActivitySuggestion(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      day: json['day'] as String,
      time: json['time'] as String,
      isConfirmedByAdmin: json['isConfirmedByAdmin'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'day': day,
      'time': time,
      'isConfirmedByAdmin': isConfirmedByAdmin,
    };
  }
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

  factory ClassActivity.fromJson(Map<String, dynamic> json) {
    return ClassActivity(
      id: json['id'] as String,
      classId: json['classId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date']),
      time: json['time'] as String,
      // IconData is tricky to serialize/deserialize purely from JSON without mapping logic.
      // Usually, we store the codePoint or a string identifier.
      // For now, I'll omit it or assume it's handled elsewhere.
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classId': classId,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'time': time,
      'status': status,
    };
  }
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

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      childId: json['childId'] as String,
      date: DateTime.parse(json['date']),
      isPresent: json['isPresent'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'childId': childId,
      'date': date.toIso8601String(),
      'isPresent': isPresent,
    };
  }
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

  factory CompetencyRecord.fromJson(Map<String, dynamic> json) {
    return CompetencyRecord(
      childId: json['childId'] as String,
      skill: CompetencySkill.values.firstWhere((e) => e.toString() == json['skill']),
      level: CompetencyLevel.values.firstWhere((e) => e.toString() == json['level']),
      date: DateTime.parse(json['date']),
      comment: json['comment'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'childId': childId,
      'skill': skill.toString(),
      'level': level.toString(),
      'date': date.toIso8601String(),
      'comment': comment,
    };
  }
}
