/// Represents an incident report or alert (signalement) for a child.
///
/// Signalements are used to report specific incidents, behavioral alerts,
/// or noteworthy events associated with a child and optionally an activity.
class Signalement {
  final int id;
  final int childId;
  final int teacherId;
  final int? activityId;
  final String alertType;
  final String? comment;
  final DateTime incidentTime;
  final bool isRead;
  final ActivityInfo? activity;
  final TeacherInfo? teacher;

  /// Creates a new [Signalement] instance.
  Signalement({
    required this.id,
    required this.childId,
    required this.teacherId,
    this.activityId,
    required this.alertType,
    this.comment,
    required this.incidentTime,
    this.isRead = false,
    this.activity,
    this.teacher,
  });

  /// Factory constructor to create a [Signalement] from a JSON map.
  factory Signalement.fromJson(Map<String, dynamic> json) {
    return Signalement(
      id: json['id'],
      childId: json['child_id'],
      teacherId: json['teacher_id'],
      activityId: json['activity_id'],
      alertType: json['alert_type'],
      comment: json['comment'],
      incidentTime: DateTime.parse(json['incident_time']),
      isRead: json['is_read'] ?? false,
      activity: json['activity'] != null
          ? ActivityInfo.fromJson(json['activity'])
          : null,
      teacher: json['teacher'] != null
          ? TeacherInfo.fromJson(json['teacher'])
          : null,
    );
  }

  /// Converts the [Signalement] instance to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'child_id': childId,
      'teacher_id': teacherId,
      'activity_id': activityId,
      'alert_type': alertType,
      'comment': comment,
      'incident_time': incidentTime.toIso8601String(),
    };
  }
}

/// Simplified model for activity information within a signalement.
class ActivityInfo {
  final int id;
  final String title;

  /// Creates a new [ActivityInfo] instance.
  ActivityInfo({required this.id, required this.title});

  /// Factory constructor for [ActivityInfo].
  factory ActivityInfo.fromJson(Map<String, dynamic> json) {
    return ActivityInfo(id: json['id'], title: json['title']);
  }
}

/// Simplified model for teacher information within a signalement.
class TeacherInfo {
  final int cin;
  final String firstName;
  final String lastName;

  /// Returns the teacher's full name.
  String get fullName => '$firstName $lastName';

  /// Creates a new [TeacherInfo] instance.
  TeacherInfo({
    required this.cin,
    required this.firstName,
    required this.lastName,
  });

  /// Factory constructor for [TeacherInfo].
  factory TeacherInfo.fromJson(Map<String, dynamic> json) {
    return TeacherInfo(
      cin: json['cin'],
      firstName: json['firstName'],
      lastName: json['lastName'],
    );
  }
}
