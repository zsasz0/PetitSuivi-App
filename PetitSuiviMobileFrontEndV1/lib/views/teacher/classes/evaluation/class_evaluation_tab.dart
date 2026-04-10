import 'package:provider/provider.dart';
import 'package:newv/theme_manager.dart';
import 'package:newv/theme_colors.dart';
import 'package:newv/utils/api_constants.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:newv/utils/unauthorized_handler.dart';
import 'package:newv/views/teacher/children/teacher_child_profile_page.dart';
import 'package:newv/views/teacher/classes/students/student_activity_models.dart';
import 'package:newv/models/teacher_models.dart'; // For MockChild
import 'package:newv/views/teacher/teacher_theme.dart';
import 'package:http/http.dart' as http;

// File: class_evaluation_tab.dart
// Purpose: Tab component for real-time skill evaluation of all students in a class for a specific date.
// Usage: Used as a tab in ClassDetailPage.
// API Usage:
//   - GET /api/classes/{id}/activities/date/{date} (Fetch activities/criteria)
//   - GET /api/classes/{id}/students (Fetch students)
//   - GET /api/children/{id}/evaluations/date/{date} (Fetch existing evaluations)
//   - POST /api/evaluations (Save evaluation)
// Dependencies: TeacherChildProfilePage, StudentActivityModels, TeacherModels, TeacherTheme.

/// Key format: "studentId|activityId|criteriaId"
typedef EvalKey = String;

/// A complex tab providing dual layouts ("By Student" or "By Activity") for recording skill mastery.

class ClassEvaluationTab extends StatefulWidget {
  final int classId;
  final DateTime selectedDate;
  final Future<void> Function() onPickDate;
  final String token;
  final int teacherCin; // required by backend for evaluation saves

  const ClassEvaluationTab({
    super.key,
    required this.classId,
    required this.selectedDate,
    required this.onPickDate,
    required this.token,
    required this.teacherCin,
  });

  @override
  State<ClassEvaluationTab> createState() => _ClassEvaluationTabState();
}

class _ClassEvaluationTabState extends State<ClassEvaluationTab> {
  static const String _apiBaseUrl = ApiConstants.baseUrl;

  // ─── Loaded data ───────────────────────────────────────────────
  List<ClassActivityWithCriteria> _activities = [];
  List<ClassStudent> _students = [];
  bool _isLoadingActivities = false;
  bool _isLoadingStudents = false;
  bool _isStudentLayout = true;
  String? _activitiesError;
  String? _studentsError;

  // ─── Evaluation state ──────────────────────────────────────────
  // null = En cours (not evaluated), acquise / aRenforcer = saved or pending save
  final Map<EvalKey, CriteriaEvalStatus?> _pending = {};
  // existing eval IDs from the backend so we can PUT instead of POST
  final Map<EvalKey, int> _existingEvalIds = {};

  // ─── Collapsible criteria ("Par Activité" layout) ─────────────
  // Key: "activityId|criteriaId" – only criteria in this set are expanded.
  // Default: empty → all collapsed.
  final Set<String> _expandedCriteria = {};

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void didUpdateWidget(ClassEvaluationTab old) {
    super.didUpdateWidget(old);
    if (old.selectedDate != widget.selectedDate ||
        old.classId != widget.classId) {
      _loadAll();
    }
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadActivities(), _loadStudents()]);
    await _loadExistingEvals();
  }

  String _dateString(DateTime dt) {
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '${dt.year}-$m-$d';
  }

  Future<void> _loadActivities() async {
    setState(() {
      _isLoadingActivities = true;
      _activitiesError = null;
      _activities = [];
    });

    final dateStr = _dateString(widget.selectedDate);
    final uri = Uri.parse(
      '$_apiBaseUrl/api/classes/${widget.classId}/activities/date/$dateStr',
    );

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (!mounted) return;
      if (UnauthorizedHandler.handle(
        context: context,
        statusCode: response.statusCode,
      )) {
        setState(() => _isLoadingActivities = false);
        return;
      }

      final body = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode < 200 || response.statusCode >= 300) {
        setState(() {
          _isLoadingActivities = false;
          _activitiesError =
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
        _activities = parsed;
        _isLoadingActivities = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingActivities = false;
        _activitiesError = 'Erreur réseau. Vérifiez la connexion à l\'API.';
      });
    }
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoadingStudents = true;
      _studentsError = null;
      _students = [];
    });

    final uri = Uri.parse(
      '$_apiBaseUrl/api/classes/${widget.classId}/students',
    );

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (!mounted) return;
      if (UnauthorizedHandler.handle(
        context: context,
        statusCode: response.statusCode,
      )) {
        setState(() => _isLoadingStudents = false);
        return;
      }

      final body = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode < 200 || response.statusCode >= 300) {
        setState(() {
          _isLoadingStudents = false;
          _studentsError =
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
            parsed.add(ClassStudent.fromJson(item));
          }
        }
      } else if (data is List) {
        for (final item in data) {
          if (item is Map<String, dynamic>) {
            parsed.add(ClassStudent.fromJson(item));
          }
        }
      }

      setState(() {
        _students = parsed;
        _isLoadingStudents = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingStudents = false;
        _studentsError = 'Erreur réseau. Vérifiez la connexion à l\'API.';
      });
    }
  }

  Future<void> _loadExistingEvals() async {
    if (_students.isEmpty || _activities.isEmpty) return;

    final dateStr = _dateString(widget.selectedDate);
    final newExisting = <EvalKey, int>{};
    final newPending = <EvalKey, CriteriaEvalStatus?>{};

    for (final student in _students) {
      try {
        final uri = Uri.parse(
          '$_apiBaseUrl/api/children/${student.id}/evaluations/date/$dateStr',
        );

        final response = await http.get(
          uri,
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${widget.token}',
          },
        );

        if (!mounted) return;
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
              final key = _evalKey(student.id, activityId, criteriaId);
              newExisting[key] = evalId;
              newPending[key] = status;
            }
          }
        }
      } catch (_) {}
    }

    if (!mounted) return;

    // Apply defaults to Acquise if not fetched
    for (final student in _students) {
      for (final activity in _activities) {
        for (final criterion in activity.criteria) {
          final key = _evalKey(
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
      _existingEvalIds.clear();
      _existingEvalIds.addAll(newExisting);
      _pending.clear();
      _pending.addAll(newPending);
    });
  }

  EvalKey _evalKey(int studentId, int activityId, int criteriaId) {
    return '$studentId|$activityId|$criteriaId';
  }

  void _toggleStatus(
    int studentId,
    int activityId,
    int criteriaId,
    CriteriaEvalStatus tapped,
  ) {
    final key = _evalKey(studentId, activityId, criteriaId);
    final current = _pending[key];

    if (current == tapped) {
      setState(() => _pending[key] = null);
      return;
    }

    setState(() => _pending[key] = tapped);
  }

  Future<void> _saveAllEvals() async {
    final evaluations = [];
    _pending.forEach((key, status) {
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

    final dateStr = _dateString(widget.selectedDate);
    final requestBody = {
      'evaluations': evaluations,
      'teacher_id': widget.teacherCin.toString(),
      'evaluation_date': dateStr,
    };

    final url = '$_apiBaseUrl/api/evaluations/bulk';

    try {
      final uri = Uri.parse(url);
      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (widget.token.isNotEmpty)
            'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode(requestBody),
      );

      if (!mounted) return;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Évaluations enregistrées avec succès',
              style: TextStyle(fontFamily: TeacherTheme.fontName),
            ),
            backgroundColor: Colors.greenAccent.shade700,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _loadExistingEvals();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${response.statusCode}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur réseau: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _openStudentProfile(
    BuildContext context,
    ClassStudent student,
  ) async {
    final mockChild = MockChild(
      id: student.id.toString(),
      classId: widget.classId.toString(),
      firstName: student.firstName,
      lastName: student.lastName,
      age: 5,
    );

    final dailyActivities = _activities
        .map(
          (a) => DailyClassActivity(
            id: a.activityId,
            planDayId: 0,
            title: a.activityName,
            description: '',
            date: widget.selectedDate,
            startTime: '',
            endTime: '',
            criteria: a.criteria.map((c) => c.criteriaName).toList(),
          ),
        )
        .toList();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeacherChildProfilePage(
          child: mockChild,
          className: 'Classe',
          selectedDate: widget.selectedDate,
          activitiesForDay: dailyActivities,
          initialEvaluations: const {},
          classId: widget.classId,
          token: widget.token,
          teacherCin: widget.teacherCin,
          onEvaluationsChanged: (updatedLevels) {
            _loadExistingEvals();
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      '',
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    const days = [
      '',
      'lundi',
      'mardi',
      'mercredi',
      'jeudi',
      'vendredi',
      'samedi',
      'dimanche',
    ];
    return '${days[date.weekday]} ${date.day} ${months[date.month]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    final isLoading = _isLoadingActivities || _isLoadingStudents;
    final int activitiesCount = _activities.length;
    final int totalCriteria = _activities.fold(
      0,
      (sum, a) => sum + a.criteria.length,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: widget.onPickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: TeacherTheme.surfaceCard(borderRadius: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: TeacherTheme.tealAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _formatDate(widget.selectedDate),
                        style: TextStyle(
                          fontFamily: TeacherTheme.fontName,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: TeacherTheme.lightText,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: TeacherTheme.mutedText.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (!isLoading && _students.isNotEmpty && _activities.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _summaryChip(
                      icon: Icons.child_care,
                      label: 'Élèves',
                      value: '${_students.length}',
                      color: TeacherTheme.indigoAccent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _summaryChip(
                      icon: Icons.event_note,
                      label: 'Activités',
                      value: '$activitiesCount',
                      color: const Color(0xFF64B5F6),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _summaryChip(
                      icon: Icons.rule,
                      label: 'Critères',
                      value: '$totalCriteria',
                      color: TeacherTheme.tealAccent,
                    ),
                  ),
                ],
              ),
            ),
          if (isLoading)
            Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: LinearProgressIndicator(
                minHeight: 2,
                color: TeacherTheme.tealAccent,
              ),
            ),

          if (!isLoading && _activitiesError == null && _studentsError == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: ThemeColors.glassBorderSubtle,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isStudentLayout = true),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _isStudentLayout
                                ? TeacherTheme.surfaceDark
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _isStudentLayout
                                ? [
                                    BoxShadow(
                                      color: ThemeColors.shadow,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Par Élève',
                            style: TextStyle(
                              fontFamily: TeacherTheme.fontName,
                              fontWeight: _isStudentLayout
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 13,
                              color: _isStudentLayout
                                  ? TeacherTheme.tealAccent
                                  : TeacherTheme.mutedText,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isStudentLayout = false),
                        child: Container(
                          decoration: BoxDecoration(
                            color: !_isStudentLayout
                                ? TeacherTheme.surfaceDark
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: !_isStudentLayout
                                ? [
                                    BoxShadow(
                                      color: ThemeColors.shadow,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Par Activité',
                            style: TextStyle(
                              fontFamily: TeacherTheme.fontName,
                              fontWeight: !_isStudentLayout
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 13,
                              color: !_isStudentLayout
                                  ? TeacherTheme.tealAccent
                                  : TeacherTheme.mutedText,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (_activitiesError != null)
            _errorBanner(_activitiesError!, _loadActivities),
          if (_studentsError != null)
            _errorBanner(_studentsError!, _loadStudents),

          if (!isLoading &&
              _activitiesError == null &&
              _studentsError == null &&
              _activities.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: TeacherTheme.indigoAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _isStudentLayout
                      ? 'Aucun élève trouvé.'
                      : 'Aucune activité prévue pour cette date.',
                  style: TextStyle(
                    fontFamily: TeacherTheme.fontName,
                    fontSize: 13,
                    color: TeacherTheme.lightText,
                  ),
                ),
              ),
            ),

          if (_isStudentLayout)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: _students.length,
                itemBuilder: (context, i) =>
                    _buildChildCard(context, _students[i]),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: _activities.length,
                itemBuilder: (context, i) => _buildActivityCard(_activities[i]),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveAllEvals,
        backgroundColor: TeacherTheme.tealAccent,
        foregroundColor: TeacherTheme.baseDark,
        icon: const Icon(Icons.save),
        label: const Text(
          'Enregistrer',
          style: TextStyle(
            fontFamily: TeacherTheme.fontName,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildChildCard(BuildContext context, ClassStudent child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: TeacherTheme.surfaceCard(borderRadius: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openStudentProfile(context, child),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 21,
                      backgroundColor: TeacherTheme.tealAccent.withValues(
                        alpha: 0.15,
                      ),
                      child: Text(
                        '${child.firstName[0]}${child.lastName[0]}',
                        style: TextStyle(
                          fontFamily: TeacherTheme.fontName,
                          fontWeight: FontWeight.bold,
                          color: TeacherTheme.tealAccent,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            child.fullName,
                            style: TextStyle(
                              fontFamily: TeacherTheme.fontName,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: TeacherTheme.lightText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '5 ans', // Fallback age
                            style: TextStyle(
                              fontFamily: TeacherTheme.fontName,
                              fontSize: 12,
                              color: TeacherTheme.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: TeacherTheme.mutedText.withValues(alpha: 0.6),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Touchez pour voir les activités et évaluer les compétences.',
                  style: TextStyle(
                    fontFamily: TeacherTheme.fontName,
                    fontSize: 12,
                    color: TeacherTheme.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(ClassActivityWithCriteria activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: TeacherTheme.surfaceCard(borderRadius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: TeacherTheme.indigoAccent.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event_note,
                  color: TeacherTheme.indigoAccent,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    activity.activityName,
                    style: TextStyle(
                      fontFamily: TeacherTheme.fontName,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: TeacherTheme.lightText,
                    ),
                  ),
                ),
                _miniChip(
                  '${activity.criteria.length} critère(s)',
                  TeacherTheme.tealAccent,
                ),
              ],
            ),
          ),

          if (activity.criteria.isEmpty)
            Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'Aucun critère défini pour cette activité.',
                style: TextStyle(
                  fontFamily: TeacherTheme.fontName,
                  fontSize: 12,
                  color: TeacherTheme.mutedText,
                ),
              ),
            )
          else
            ...activity.criteria.map(
              (criterion) => _buildCriterionRow(activity, criterion),
            ),
        ],
      ),
    );
  }

  Widget _buildCriterionRow(
    ClassActivityWithCriteria activity,
    ActivityCriterion criterion,
  ) {
    final criterionKey = '${activity.activityId}|${criterion.criteriaId}';
    final isExpanded = _expandedCriteria.contains(criterionKey);

    // Count how many students have been evaluated for this criterion
    int evaluatedCount = 0;
    for (final s in _students) {
      final key = _evalKey(s.id, activity.activityId, criterion.criteriaId);
      if (_pending[key] != null) evaluatedCount++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Tappable criterion header ──
        InkWell(
          onTap: () {
            setState(() {
              if (isExpanded) {
                _expandedCriteria.remove(criterionKey);
              } else {
                _expandedCriteria.add(criterionKey);
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Icon(Icons.rule, size: 15, color: TeacherTheme.tealAccent),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    criterion.criteriaName,
                    style: TextStyle(
                      fontFamily: TeacherTheme.fontName,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: TeacherTheme.lightText,
                    ),
                  ),
                ),
                // Badge: evaluated / total
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: TeacherTheme.indigoAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$evaluatedCount/${_students.length}',
                    style: TextStyle(
                      fontFamily: TeacherTheme.fontName,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: TeacherTheme.indigoAccent,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.expand_more,
                    size: 20,
                    color: TeacherTheme.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ),
        // ── Collapsible student list ──
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: _students
                .map(
                  (student) =>
                      _buildStudentEvalRow(activity, criterion, student),
                )
                .toList(),
          ),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
          sizeCurve: Curves.easeInOut,
        ),
        Divider(
          color: ThemeColors.glassBorderSubtle,
          thickness: 1,
          indent: 16,
          endIndent: 16,
        ),
      ],
    );
  }

  Widget _buildStudentEvalRow(
    ClassActivityWithCriteria activity,
    ActivityCriterion criterion,
    ClassStudent student,
  ) {
    final key = _evalKey(student.id, activity.activityId, criterion.criteriaId);
    final status = _pending[key];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  _openStudentProfile(context, student);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: TeacherTheme.indigoAccent.withValues(
                          alpha: 0.15,
                        ),
                        child: Text(
                          '${student.firstName[0]}${student.lastName[0]}',
                          style: TextStyle(
                            fontFamily: TeacherTheme.fontName,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: TeacherTheme.indigoAccent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          student.fullName,
                          style: TextStyle(
                            fontFamily: TeacherTheme.fontName,
                            fontSize: 13,
                            color: TeacherTheme.lightText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _evalChip(
            label: 'Acquise',
            icon: Icons.check_circle_outline,
            color: Colors.greenAccent,
            isSelected: status == CriteriaEvalStatus.acquise,
            onTap: () => _toggleStatus(
              student.id,
              activity.activityId,
              criterion.criteriaId,
              CriteriaEvalStatus.acquise,
            ),
          ),
          const SizedBox(width: 6),
          _evalChip(
            label: 'À renforcer',
            icon: Icons.warning_amber_rounded,
            color: Colors.redAccent,
            isSelected: status == CriteriaEvalStatus.aRenforcer,
            onTap: () => _toggleStatus(
              student.id,
              activity.activityId,
              criterion.criteriaId,
              CriteriaEvalStatus.aRenforcer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _evalChip({
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : TeacherTheme.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : ThemeColors.glassBorder,
            width: isSelected ? 1.6 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? color : TeacherTheme.mutedText,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: TeacherTheme.fontName,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? color : TeacherTheme.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: TeacherTheme.fontName,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _errorBanner(String message, VoidCallback onRetry) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: TeacherTheme.fontName,
                  color: Colors.redAccent,
                  fontSize: 12,
                ),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: TeacherTheme.fontName,
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: TeacherTheme.fontName,
              fontSize: 11,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
