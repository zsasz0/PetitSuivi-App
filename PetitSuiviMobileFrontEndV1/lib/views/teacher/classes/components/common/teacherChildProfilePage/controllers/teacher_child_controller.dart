import 'package:flutter/material.dart';
import 'package:newv/models/signalement.dart';
import 'package:newv/models/teacher_models.dart';
import 'package:newv/views/teacher/classes/components/students/student_activity_models.dart';
import 'package:newv/views/teacher/classes/components/common/teacherChildProfilePage/apis/teacher_child_api.dart';

class TeacherChildController {
  final MockChild child;
  final int? classId;
  final DateTime? selectedDate;
  final String? token;
  final int? teacherCin;
  final List<DailyClassActivity> activitiesForDay;
  final ValueChanged<Map<String, CompetencyLevel>>? onEvaluationsChanged;
  final Function(VoidCallback) setState;
  final BuildContext context;

  late final TeacherChildApi _api;

  // State
  Map<String, CompetencyLevel> activityEvaluations = {};
  final Map<String, int> criteriaIdByName = {};
  final Map<String, int> activityIdByTitle = {};
  bool idsLoaded = false;
  List<Signalement> todaySignalements = [];
  String? dietaryComment;
  String? healthComment;
  bool loadingAiSummaries = true;
  bool isSaving = false;
  bool isSendingSignal = false;
  List<Signalement> recentSignals = [];
  bool isLoadingSignals = true;

  TeacherChildController({
    required this.child,
    this.classId,
    this.selectedDate,
    this.token,
    this.teacherCin,
    required this.activitiesForDay,
    this.onEvaluationsChanged,
    required this.setState,
    required this.context,
    Map<String, CompetencyLevel> initialEvaluations = const {},
  }) {
    _api = TeacherChildApi(token: token);
    activityEvaluations = Map<String, CompetencyLevel>.from(initialEvaluations);
  }

  void init() {
    _initializeEvaluations();
    loadAllData();
  }

  void _initializeEvaluations() {
    bool hasChanges = false;
    for (final activity in activitiesForDay) {
      for (final criterion in activity.criteria) {
        final key = getActivityCriterionKey(activity, criterion);
        if (!activityEvaluations.containsKey(key)) {
          activityEvaluations[key] = CompetencyLevel.acquise;
          hasChanges = true;
        }
      }
    }
    if (hasChanges) {
      onEvaluationsChanged?.call(Map<String, CompetencyLevel>.from(activityEvaluations));
    }
  }

  Future<void> loadAllData() async {
    // loadCriteriaIds must finish first — loadExistingEvaluations needs criteriaIdByName
    await Future.wait([
      loadAiSummaries(),
      loadTodaySignalements(),
      loadCriteriaIds(),
      loadRecentSignals(),
    ]);
    // Now criteriaIdByName is populated, so we can match by ID
    await loadExistingEvaluations();
  }

  String getActivityCriterionKey(DailyClassActivity activity, String criterion) {
    return '${activity.key}|$criterion';
  }

  CompetencyLevel? getCurrentLevel(DailyClassActivity activity, String criterion) {
    return activityEvaluations[getActivityCriterionKey(activity, criterion)];
  }

  void setActivityLevel(DailyClassActivity activity, String criterion, CompetencyLevel level) {
    setState(() {
      activityEvaluations[getActivityCriterionKey(activity, criterion)] = level;
    });
    onEvaluationsChanged?.call(Map<String, CompetencyLevel>.from(activityEvaluations));
  }

  String formatDateApi(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }

  Future<void> loadAiSummaries() async {
    final childId = int.tryParse(child.id);
    if (childId == null) {
      setState(() => loadingAiSummaries = false);
      return;
    }
    final body = await _api.getAiSummaries(childId);
    setState(() {
      if (body != null) {
        dietaryComment = body['dietary_comment'] as String?;
        healthComment = body['health_comment'] as String?;
      }
      loadingAiSummaries = false;
    });
  }

  Future<void> loadTodaySignalements() async {
    final childId = int.tryParse(child.id);
    if (childId == null) return;
    final data = await _api.getSignalements(childId);
    if (data != null) {
      final now = DateTime.now();
      final all = data.whereType<Map<String, dynamic>>().map((e) => Signalement.fromJson(e)).toList();
      final today = all.where((s) => s.incidentTime.year == now.year && s.incidentTime.month == now.month && s.incidentTime.day == now.day).toList();
      setState(() {
        todaySignalements = today;
      });
    }
  }

  Future<void> loadCriteriaIds() async {
    if (classId == null || selectedDate == null) return;
    final dateStr = formatDateApi(selectedDate!);
    final body = await _api.getClassActivities(classId!, dateStr);
    if (body != null) {
      final data = body['data'];
      if (data is Map && data['activities'] is List) {
        for (final item in data['activities'] as List) {
          if (item is! Map<String, dynamic>) continue;
          final actId = (item['activity_id'] as num?)?.toInt() ?? 0;
          final actName = item['activity_name']?.toString() ?? '';
          if (actId > 0 && actName.isNotEmpty) {
            activityIdByTitle[actName] = actId;
          }
          final criteria = item['criteria'];
          if (criteria is List) {
            for (final cr in criteria) {
              if (cr is! Map<String, dynamic>) continue;
              final crId = (cr['criteria_id'] as num?)?.toInt() ?? 0;
              final crName = cr['criteria_name']?.toString() ?? '';
              if (crId > 0 && crName.isNotEmpty) {
                criteriaIdByName[crName] = crId;
              }
            }
          }
        }
        setState(() {
          idsLoaded = true;
        });
      }
    }
  }

  Future<void> loadExistingEvaluations() async {
    if (selectedDate == null) return;
    final childId = int.tryParse(child.id);
    if (childId == null) return;
    final dateStr = formatDateApi(selectedDate!);

    final body = await _api.getExistingEvaluations(childId, dateStr);
    if (body == null) return;

    final data = body['data'];
    if (data is! Map) return;

    final evalsList = data['evaluations'];
    if (evalsList is! List) return;

    // Build reverse lookup: criteria_id → criteria_name
    final criteriaNameById = <int, String>{};
    for (final entry in criteriaIdByName.entries) {
      criteriaNameById[entry.value] = entry.key;
    }

    // Build reverse lookup: activity_id → DailyClassActivity
    final activityById = <int, DailyClassActivity>{};
    for (final activity in activitiesForDay) {
      activityById[activity.id] = activity;
    }

    setState(() {
      for (final evalRaw in evalsList) {
        if (evalRaw is! Map<String, dynamic>) continue;

        // API returns activity_id, not activity_name
        final actId = (evalRaw['activity_id'] as num?)?.toInt();
        if (actId == null) continue;

        final activity = activityById[actId];
        if (activity == null) continue;

        final criteria = evalRaw['criteria'];
        if (criteria is! List) continue;

        for (final cr in criteria) {
          if (cr is! Map<String, dynamic>) continue;

          // API returns criteria_id, not criteria_name
          final crId = (cr['criteria_id'] as num?)?.toInt();
          if (crId == null) continue;

          final crName = criteriaNameById[crId];
          if (crName == null || !activity.criteria.contains(crName)) continue;

          final statusLabel = cr['status_label']?.toString() ?? '';
          final key = getActivityCriterionKey(activity, crName);

          if (statusLabel == 'Acquise') {
            activityEvaluations[key] = CompetencyLevel.acquise;
          } else if (statusLabel == 'À renforcer' || statusLabel == '\u00c0 renforcer') {
            activityEvaluations[key] = CompetencyLevel.aRenforcer;
          }
        }
      }
    });
  }


  Future<void> loadRecentSignals() async {
    final childId = int.tryParse(child.id);
    if (childId == null) {
      setState(() => isLoadingSignals = false);
      return;
    }
    final data = await _api.getSignalements(childId);
    setState(() {
      if (data != null) {
        recentSignals = data.whereType<Map<String, dynamic>>().map((e) => Signalement.fromJson(e)).toList();
      }
      isLoadingSignals = false;
    });
  }

  Future<void> saveAllEvals() async {
    if (classId == null || teacherCin == null) {
      _showSnackBar('Données manquantes (classId ou teacherCin)', isError: true);
      return;
    }
    if (selectedDate == null) return;
    final childId = int.tryParse(child.id);
    if (childId == null) return;

    setState(() => isSaving = true);

    try {
      final dateStr = formatDateApi(selectedDate!);
      final evaluations = <Map<String, dynamic>>[];

      for (final activity in activitiesForDay) {
        final actId = activityIdByTitle[activity.title] ?? activity.id;
        for (final criterion in activity.criteria) {
          final level = getCurrentLevel(activity, criterion);
          if (level == null || level == CompetencyLevel.enCours) continue;
          final crId = criteriaIdByName[criterion];
          if (crId == null || crId == 0) continue;
          final statusLabel = level == CompetencyLevel.acquise ? 'Acquise' : 'À renforcer';
          evaluations.add({
            'child_id': childId,
            'activity_id': actId,
            'criteria_id': crId,
            'status_label': statusLabel,
          });
        }
      }

      final requestBody = {
        'teacher_id': teacherCin,
        'evaluation_date': dateStr,
        'evaluations': evaluations,
      };

      final response = await _api.saveEvaluationsBulk(requestBody);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _showSnackBar('Toutes les évaluations ont été enregistrées ✓');
      } else {
        _showSnackBar('Erreur: ${response.statusCode}', isError: true);
      }
    } catch (e) {
      _showSnackBar('Erreur réseau', isError: true);
    } finally {
      setState(() => isSaving = false);
    }
  }

  Future<void> submitSignalement(String type, String? comment) async {
    final childId = int.tryParse(child.id);
    if (childId == null || teacherCin == null) {
      _showSnackBar('Données manquantes (childId ou teacherCin)', isError: true);
      return;
    }

    setState(() => isSendingSignal = true);

    final requestBody = {
      'child_id': childId,
      'teacher_id': teacherCin,
      'alert_type': type,
      'comment': comment,
      'incident_time': DateTime.now().toIso8601String(),
    };

    try {
      final response = await _api.postSignalement(requestBody);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _showSnackBar('Signalement enregistré pour ${child.firstName} ✓');
        await loadTodaySignalements();
        await loadRecentSignals();
      } else {
        _showSnackBar('Erreur: ${response.statusCode}', isError: true);
      }
    } catch (e) {
      _showSnackBar('Erreur réseau', isError: true);
    } finally {
      setState(() => isSendingSignal = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF00C853),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  int getTotalCriteriaCount() {
    var total = 0;
    for (final activity in activitiesForDay) {
      total += activity.criteria.length;
    }
    return total;
  }

  int getRatedCriteriaCount() {
    var rated = 0;
    for (final activity in activitiesForDay) {
      for (final criterion in activity.criteria) {
        if (getCurrentLevel(activity, criterion) != null) {
          rated++;
        }
      }
    }
    return rated;
  }
}
