import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:newv/utils/unauthorized_handler.dart';
import 'package:newv/views/teacher/classes/apis/teacher_classes_api.dart';
import 'package:newv/views/teacher/classes/components/students/student_activity_models.dart';
import 'package:newv/views/teacher/classes/themes/teacher_classes_theme.dart';

typedef EvalKey = String;

class ClassEvaluationController {
  List<ClassActivityWithCriteria> activities = [];
  List<ClassStudent> students = [];
  bool isLoadingActivities = false;
  bool isLoadingStudents = false;
  bool isStudentLayout = true;
  String? activitiesError;
  String? studentsError;

  final Map<EvalKey, CriteriaEvalStatus?> pending = {};
  final Map<EvalKey, int> existingEvalIds = {};
  final Set<String> expandedCriteria = {};

  Future<void> loadAll({
    required BuildContext context,
    required int classId,
    required DateTime selectedDate,
    required String token,
    required Function(VoidCallback fn) setState,
    required bool Function() isMounted,
  }) async {
    await Future.wait([
      loadActivities(
        context: context,
        classId: classId,
        selectedDate: selectedDate,
        token: token,
        setState: setState,
        isMounted: isMounted,
      ),
      loadStudents(
        context: context,
        classId: classId,
        token: token,
        setState: setState,
        isMounted: isMounted,
      ),
    ]);
    await loadExistingEvals(
      selectedDate: selectedDate,
      token: token,
      setState: setState,
      isMounted: isMounted,
    );
  }

  String dateString(DateTime dt) {
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '${dt.year}-$m-$d';
  }

  Future<void> loadActivities({
    required BuildContext context,
    required int classId,
    required DateTime selectedDate,
    required String token,
    required Function(VoidCallback fn) setState,
    required bool Function() isMounted,
  }) async {
    setState(() {
      isLoadingActivities = true;
      activitiesError = null;
      activities = [];
    });

    final dateStr = dateString(selectedDate);
    try {
      final response = await TeacherClassesApi.getClassActivities(
        classId,
        dateStr,
        token,
      );

      if (!isMounted() || !context.mounted) {
        return;
      }
      if (UnauthorizedHandler.handle(
        context: context,
        statusCode: response.statusCode,
      )) {
        setState(() => isLoadingActivities = false);
        return;
      }

      final body = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode < 200 || response.statusCode >= 300) {
        setState(() {
          isLoadingActivities = false;
          activitiesError =
              body['message']?.toString() ??
              'Impossible de charger les activités.';
        });
        return;
      }

      final data = body['data'];
      List<ClassActivityWithCriteria> parsed = [];
      if (data is Map && data['activities'] is List) {
        for (final item in data['activities'] as List) {
          if (item is Map<String, dynamic>) {
            parsed.add(ClassActivityWithCriteria.fromJson(item));
          }
        }
      } else if (data is List) {
        for (final item in data) {
          if (item is Map<String, dynamic>) {
            parsed.add(ClassActivityWithCriteria.fromJson(item));
          }
        }
      }

      setState(() {
        activities = parsed;
        isLoadingActivities = false;
      });
    } catch (_) {
      if (!isMounted()) return;
      setState(() {
        isLoadingActivities = false;
        activitiesError = 'Erreur réseau. Vérifiez la connexion à l\'API.';
      });
    }
  }

  Future<void> loadStudents({
    required BuildContext context,
    required int classId,
    required String token,
    required Function(VoidCallback fn) setState,
    required bool Function() isMounted,
  }) async {
    setState(() {
      isLoadingStudents = true;
      studentsError = null;
      students = [];
    });

    try {
      final response = await TeacherClassesApi.getClassStudents(classId, token);

      if (!isMounted() || !context.mounted) {
        return;
      }
      if (UnauthorizedHandler.handle(
        context: context,
        statusCode: response.statusCode,
      )) {
        setState(() => isLoadingStudents = false);
        return;
      }

      final body = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode < 200 || response.statusCode >= 300) {
        setState(() {
          isLoadingStudents = false;
          studentsError =
              body['message']?.toString() ??
              'Impossible de charger les élèves.';
        });
        return;
      }

      final data = body['data'];
      List<ClassStudent> parsed = [];
      if (data is Map && data['students'] is List) {
        for (final item in data['students'] as List) {
          if (item is Map<String, dynamic>) {
            bool isArchived =
                item['is_archived'] == true ||
                item['is_archived'] == 1 ||
                item['isArchived'] == true ||
                item['isArchived'] == 1;

            final inscriptions = item['inscriptions'];
            if (inscriptions is List && inscriptions.isNotEmpty) {
              final lastInscription = inscriptions.last;
              if (lastInscription is Map) {
                if (lastInscription['is_archived'] == true ||
                    lastInscription['is_archived'] == 1 ||
                    lastInscription['isArchived'] == true ||
                    lastInscription['isArchived'] == 1) {
                  isArchived = true;
                }
              }
            }

            if (!isArchived) {
              parsed.add(ClassStudent.fromJson(item));
            }
          }
        }
      } else if (data is List) {
        for (final item in data) {
          if (item is Map<String, dynamic>) {
            bool isArchived =
                item['is_archived'] == true ||
                item['is_archived'] == 1 ||
                item['isArchived'] == true ||
                item['isArchived'] == 1;

            final inscriptions = item['inscriptions'];
            if (inscriptions is List && inscriptions.isNotEmpty) {
              final lastInscription = inscriptions.last;
              if (lastInscription is Map) {
                if (lastInscription['is_archived'] == true ||
                    lastInscription['is_archived'] == 1 ||
                    lastInscription['isArchived'] == true ||
                    lastInscription['isArchived'] == 1) {
                  isArchived = true;
                }
              }
            }

            if (!isArchived) {
              parsed.add(ClassStudent.fromJson(item));
            }
          }
        }
      }

      setState(() {
        students = parsed;
        isLoadingStudents = false;
      });
    } catch (_) {
      if (!isMounted()) return;
      setState(() {
        isLoadingStudents = false;
        studentsError = 'Erreur réseau. Vérifiez la connexion à l\'API.';
      });
    }
  }

  Future<void> loadExistingEvals({
    required DateTime selectedDate,
    required String token,
    required Function(VoidCallback fn) setState,
    required bool Function() isMounted,
  }) async {
    if (students.isEmpty || activities.isEmpty) return;

    final dateStr = dateString(selectedDate);
    final newExisting = <EvalKey, int>{};
    final newPending = <EvalKey, CriteriaEvalStatus?>{};

    for (final student in students) {
      try {
        final response = await TeacherClassesApi.getChildEvaluations(
          student.id,
          dateStr,
          token,
        );
        if (!isMounted()) return;
        if (response.statusCode < 200 || response.statusCode >= 300) continue;

        final body = response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};
        final data = body['data'];
        final List<dynamic> evalList =
            (data is Map && data['evaluations'] is List)
            ? data['evaluations'] as List
            : [];

        for (final evalRaw in evalList) {
          if (evalRaw is! Map<String, dynamic>) continue;
          final evalId =
              (evalRaw['evaluation_id'] as num?)?.toInt() ??
              int.tryParse(evalRaw['evaluation_id']?.toString() ?? '') ??
              (evalRaw['id'] as num?)?.toInt() ??
              0;
          final activityId =
              (evalRaw['activity_id'] as num?)?.toInt() ??
              int.tryParse(evalRaw['activity_id']?.toString() ?? '') ??
              0;
          final criteriaRaw = evalRaw['criteria'];
          if (criteriaRaw is! List) continue;

          for (final cr in criteriaRaw) {
            if (cr is! Map<String, dynamic>) continue;
            final criteriaId =
                (cr['criteria_id'] as num?)?.toInt() ??
                int.tryParse(cr['criteria_id']?.toString() ?? '') ??
                0;
            final statusLabel = cr['status_label']?.toString() ?? '';
            CriteriaEvalStatus? status;
            if (statusLabel == 'Acquise') {
              status = CriteriaEvalStatus.acquise;
            } else if (statusLabel == 'À renforcer') {
              status = CriteriaEvalStatus.aRenforcer;
            }

            if (status != null && criteriaId > 0 && activityId > 0) {
              final key = evalKey(student.id, activityId, criteriaId);
              newExisting[key] = evalId;
              newPending[key] = status;
            }
          }
        }
      } catch (_) {}
    }

    if (!isMounted()) return;

    for (final student in students) {
      for (final activity in activities) {
        for (final criterion in activity.criteria) {
          final key = evalKey(
            student.id,
            activity.activityId,
            criterion.criteriaId,
          );
          if (!newPending.containsKey(key)) {
            newPending[key] = CriteriaEvalStatus.acquise;
          }
        }
      }
    }

    setState(() {
      existingEvalIds.clear();
      existingEvalIds.addAll(newExisting);
      pending.clear();
      pending.addAll(newPending);
    });
  }

  EvalKey evalKey(int studentId, int activityId, int criteriaId) =>
      '$studentId|$activityId|$criteriaId';

  void toggleStatus(
    int studentId,
    int activityId,
    int criteriaId,
    CriteriaEvalStatus tapped,
    Function(VoidCallback fn) setState,
    DateTime selectedDate,
    BuildContext context,
  ) {
    final now = DateTime.now();
    if (selectedDate.year != now.year ||
        selectedDate.month != now.month ||
        selectedDate.day != now.day) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vous ne pouvez modifier que les évaluations d\'aujourd\'hui.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    final key = evalKey(studentId, activityId, criteriaId);
    final current = pending[key];
    setState(() => pending[key] = (current == tapped) ? null : tapped);
  }

  Future<void> saveAllEvals({
    required BuildContext context,
    required DateTime selectedDate,
    required String token,
    required int teacherCin,
    required Function(VoidCallback fn) setState,
    required bool Function() isMounted,
  }) async {
    final now = DateTime.now();
    if (selectedDate.year != now.year ||
        selectedDate.month != now.month ||
        selectedDate.day != now.day) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vous ne pouvez modifier que les évaluations d\'aujourd\'hui.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final evaluations = [];
    pending.forEach((key, status) {
      if (status != null) {
        final parts = key.split('|');
        if (parts.length == 3) {
          evaluations.add({
            'child_id': int.parse(parts[0]),
            'activity_id': int.parse(parts[1]),
            'criteria_id': int.parse(parts[2]),
            'status_label': status == CriteriaEvalStatus.acquise
                ? 'Acquise'
                : 'À renforcer',
          });
        }
      }
    });

    if (evaluations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune évaluation à enregistrer')),
      );
      return;
    }

    final dateStr = dateString(selectedDate);
    final requestBody = {
      'evaluations': evaluations,
      'teacher_id': teacherCin.toString(),
      'evaluation_date': dateStr,
    };

    try {
      final response = await TeacherClassesApi.saveBulkEvaluations(
        requestBody,
        token,
      );
      if (!isMounted() || !context.mounted) {
        return;
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Évaluations enregistrées avec succès',
              style: TextStyle(fontFamily: TeacherClassesTheme.fontName),
            ),
            backgroundColor: Colors.greenAccent.shade700,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
        loadExistingEvals(
          selectedDate: selectedDate,
          token: token,
          setState: setState,
          isMounted: isMounted,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${response.statusCode}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (isMounted()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur réseau: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void toggleCriteriaExpansion(
    String expansionKey,
    Function(VoidCallback fn) setState,
  ) {
    setState(() {
      if (expandedCriteria.contains(expansionKey)) {
        expandedCriteria.remove(expansionKey);
      } else {
        expandedCriteria.add(expansionKey);
      }
    });
  }
}
