/// Represents a performance or behavioral evaluation for a child.
///
/// An evaluation is tied to a specific activity and teacher, containing
/// a list of criteria that were assessed.
class Evaluation {
  final int id;
  final int childId;
  final int activityId;
  final int teacherId;
  final DateTime evaluationDate;
  final List<EvaluationCriteria> criteriaList;
  final ActivityInfo? activity;
  final TeacherInfo? teacher;

  /// Creates a new [Evaluation] instance.
  Evaluation({
    required this.id,
    required this.childId,
    required this.activityId,
    required this.teacherId,
    required this.evaluationDate,
    required this.criteriaList,
    this.activity,
    this.teacher,
  });

  /// Factory constructor to create an [Evaluation] from a JSON map.
  factory Evaluation.fromJson(Map<String, dynamic> json) {
    return Evaluation(
      id: json['id'],
      childId: json['child_id'],
      activityId: json['activity_id'],
      teacherId: json['teacher_id'],
      evaluationDate: DateTime.parse(json['evaluation_date']),
      criteriaList: json['criteria'] != null
          ? List<EvaluationCriteria>.from(
              json['criteria'].map((x) => EvaluationCriteria.fromJson(x)),
            )
          : [],
      activity: json['activity'] != null
          ? ActivityInfo.fromJson(json['activity'])
          : null,
      teacher: json['teacher'] != null
          ? TeacherInfo.fromJson(json['teacher'])
          : null,
    );
  }

  /// Converts the [Evaluation] instance to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'child_id': childId,
      'activity_id': activityId,
      'teacher_id': teacherId,
      'evaluation_date': evaluationDate.toIso8601String().split('T')[0],
      'criteria': criteriaList.map((x) => x.toJson()).toList(),
    };
  }
}

/// Represents a specific criterion within an [Evaluation].
class EvaluationCriteria {
  final int id;
  final int evaluationId;
  final int criteriaId;
  final String statusLabel;
  final String? comment;
  final String? criteriaName;

  /// Creates a new [EvaluationCriteria] instance.
  EvaluationCriteria({
    required this.id,
    required this.evaluationId,
    required this.criteriaId,
    required this.statusLabel,
    this.comment,
    this.criteriaName,
  });

  /// Factory constructor to create an [EvaluationCriteria] from a JSON map.
  factory EvaluationCriteria.fromJson(Map<String, dynamic> json) {
    return EvaluationCriteria(
      id: json['id'] ?? 0,
      evaluationId: json['evaluation_id'] ?? 0,
      criteriaId: json['criteria_id'],
      statusLabel: json['status_label'],
      comment: json['comment'],
      criteriaName: json['criteria']?['name'],
    );
  }

  /// Converts the criterion into a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'criteria_id': criteriaId,
      'status_label': statusLabel,
      'comment': comment,
    };
  }
}

/// Simplified model for activity information within an evaluation.
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

/// Simplified model for teacher information within an evaluation.
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
