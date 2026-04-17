// File: student_activity_models.dart
// Purpose: Data models for teacher-specific classroom activities, student records, and evaluations.
// Usage: Heavily used in ClassEvaluationTab and TeacherChildProfilePage.
// Dependencies: None.

/// Model representing a single daily activity with its criteria.
class DailyClassActivity {
  final int id;
  final int planDayId;
  final String title;
  final String description;
  final DateTime date;
  final String? startTime;
  final String? endTime;
  final List<String> criteria;

  const DailyClassActivity({
    required this.id,
    required this.planDayId,
    required this.title,
    required this.description,
    required this.date,
    this.startTime,
    this.endTime,
    required this.criteria,
  });

  String get key => '${planDayId}_$id';

  String get timeLabel {
    final start = _formatTime(startTime);
    final end = _formatTime(endTime);

    if (start == null || start.isEmpty) return '';
    if (end == null || end.isEmpty) return start;
    return '$start → $end';
  }

  static String? _formatTime(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.length >= 5 && trimmed[2] == ':') {
      return trimmed.substring(0, 5);
    }
    return trimmed;
  }

  factory DailyClassActivity.fromJson(Map<String, dynamic> json) {
    return DailyClassActivity(
      id: json['id'] as int,
      planDayId: json['planDayId'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date']),
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      criteria: (json['criteria'] as List).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'planDayId': planDayId,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'criteria': criteria,
    };
  }
}

// ── Enum for the new class-level evaluation feature ──

enum CriteriaEvalStatus { acquise, aRenforcer }

// A single criterion with ID (from the date-based activity API)
class ActivityCriterion {
  final int criteriaId;
  final String criteriaName;

  const ActivityCriterion({
    required this.criteriaId,
    required this.criteriaName,
  });

  factory ActivityCriterion.fromJson(Map<String, dynamic> json) {
    return ActivityCriterion(
      criteriaId:
          (json['criteria_id'] as num?)?.toInt() ??
          int.tryParse(json['criteria_id']?.toString() ?? '') ??
          0,
      criteriaName: json['criteria_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'criteria_id': criteriaId,
      'criteria_name': criteriaName,
    };
  }
}

// An activity with full IDs (from GET /api/classes/{id}/activities/date/{date})
class ClassActivityWithCriteria {
  final int activityId;
  final String activityName;
  final List<ActivityCriterion> criteria;

  const ClassActivityWithCriteria({
    required this.activityId,
    required this.activityName,
    required this.criteria,
  });

  factory ClassActivityWithCriteria.fromJson(Map<String, dynamic> json) {
    final rawCriteria = json['criteria'];
    final criteria = <ActivityCriterion>[];
    if (rawCriteria is List) {
      for (final c in rawCriteria) {
        if (c is Map<String, dynamic>) {
          criteria.add(ActivityCriterion.fromJson(c));
        }
      }
    }
    return ClassActivityWithCriteria(
      activityId:
          (json['activity_id'] as num?)?.toInt() ??
          int.tryParse(json['activity_id']?.toString() ?? '') ??
          0,
      activityName: json['activity_name']?.toString() ?? '',
      criteria: criteria,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activity_id': activityId,
      'activity_name': activityName,
      'criteria': criteria.map((e) => e.toJson()).toList(),
    };
  }
}

// A student (from GET /api/classes/{id}/students)
class ClassStudent {
  final int id;
  final String firstName;
  final String lastName;

  const ClassStudent({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  String get fullName => '$firstName $lastName';

  factory ClassStudent.fromJson(Map<String, dynamic> json) {
    String getSafeString(String key1, String key2) {
      final v = json[key1]?.toString() ?? json[key2]?.toString() ?? '';
      return v.trim().isEmpty ? 'U' : v.trim();
    }

    return ClassStudent(
      id:
          (json['id'] as num?)?.toInt() ??
          int.tryParse(json['id']?.toString() ?? '') ??
          0,
      firstName: getSafeString('first_name', 'firstName'),
      lastName: getSafeString('last_name', 'lastName'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
    };
  }
}

// Holds an existing evaluation entry from the backend
class ExistingCriteriaEval {
  final int evaluationId; // the evaluation record id
  final int criteriaId;
  final CriteriaEvalStatus status;

  const ExistingCriteriaEval({
    required this.evaluationId,
    required this.criteriaId,
    required this.status,
  });

  factory ExistingCriteriaEval.fromJson(Map<String, dynamic> json) {
    return ExistingCriteriaEval(
      evaluationId: json['evaluationId'] as int,
      criteriaId: json['criteriaId'] as int,
      status: CriteriaEvalStatus.values.firstWhere((e) => e.toString() == json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'evaluationId': evaluationId,
      'criteriaId': criteriaId,
      'status': status.toString(),
    };
  }
}
