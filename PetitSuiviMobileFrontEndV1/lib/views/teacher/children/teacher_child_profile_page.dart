import 'package:provider/provider.dart';
import 'package:newv/theme_manager.dart';
import 'package:newv/theme_colors.dart';
import 'package:newv/utils/api_constants.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:newv/app_theme.dart';
import 'package:newv/views/teacher/teacher_theme.dart';
import 'package:newv/models/signalement.dart';
import 'package:newv/models/teacher_models.dart';
import 'package:newv/views/teacher/classes/students/student_activity_models.dart';

// File: teacher_child_profile_page.dart
// Purpose: Comprehensive profile view of a student from the teacher's perspective.
// Usage: Navigated from ClassEvaluationTab or student lists.
// API Usage:
//   - GET /api/children/{id}/ai-summaries (Fetch dietary/health summaries)
//   - GET /api/children/{id}/signalements (Fetch incident reports)
//   - GET /api/classes/{id}/activities/date/{date} (Fetch class activities)
//   - GET /api/children/{id}/evaluations/date/{date} (Fetch existing evaluations)
//   - POST /api/evaluations (Save evaluation)
//   - DELETE /api/evaluations/criteria (Reset evaluation)
// Dependencies: TeacherTheme, AppTheme, Signalement, TeacherModels, StudentActivityModels.

/// A detailed page allowing teachers to view child medical/dietary info and record skill evaluations.
class TeacherChildProfilePage extends StatefulWidget {
  final MockChild child;
  final String? className;
  final DateTime? selectedDate;
  final List<DailyClassActivity> activitiesForDay;
  final Map<String, CompetencyLevel> initialEvaluations;
  final ValueChanged<Map<String, CompetencyLevel>>? onEvaluationsChanged;
  final int? classId;
  final String? token;
  final int? teacherCin;

  const TeacherChildProfilePage({
    super.key,
    required this.child,
    this.className,
    this.selectedDate,
    this.activitiesForDay = const [],
    this.initialEvaluations = const {},
    this.onEvaluationsChanged,
    this.classId,
    this.token,
    this.teacherCin,
  });

  @override
  State<TeacherChildProfilePage> createState() =>
      _TeacherChildProfilePageState();
}

class _TeacherChildProfilePageState extends State<TeacherChildProfilePage> {
  static const String _apiBaseUrl = ApiConstants.baseUrl;

  late final Map<String, CompetencyLevel> _activityEvaluations;

  // Lookup maps: criteria name -> criteria id, loaded from date-based API
  final Map<String, int> _criteriaIdByName = {};
  // activity title -> activity id from the date-based API
  final Map<String, int> _activityIdByTitle = {};
  bool _idsLoaded = false;

  // Today's signalements for alert banner
  List<Signalement> _todaySignalements = [];

  // AI Summaries
  String? _dietaryComment;
  String? _healthComment;
  bool _loadingAiSummaries = true;

  @override
  void initState() {
    super.initState();
    _activityEvaluations = Map<String, CompetencyLevel>.from(
      widget.initialEvaluations,
    );

    bool hasChanges = false;
    for (final activity in widget.activitiesForDay) {
      for (final criterion in activity.criteria) {
        final key = _activityCriterionKey(activity, criterion);
        if (!_activityEvaluations.containsKey(key)) {
          _activityEvaluations[key] = CompetencyLevel.acquise;
          hasChanges = true;
        }
      }
    }

    if (hasChanges) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onEvaluationsChanged?.call(
            Map<String, CompetencyLevel>.from(_activityEvaluations),
          );
        }
      });
    }

    // Load criteria IDs from date-based API for auto-save
    _loadCriteriaIds();
    // Load existing evaluations from backend
    _loadExistingEvaluations();
    // Load today's signalements for alert banner
    _loadTodaySignalements();
    // Load AI summaries
    _loadAiSummaries();
  }

  /// Fetch AI summaries (dietary + health) for this child
  Future<void> _loadAiSummaries() async {
    final childId = int.tryParse(widget.child.id);
    if (childId == null) {
      setState(() => _loadingAiSummaries = false);
      return;
    }
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/api/children/$childId/ai-summaries'),
        headers: {
          'Accept': 'application/json',
          if (widget.token != null && widget.token!.isNotEmpty)
            'Authorization': 'Bearer ${widget.token}',
        },
      );
      if (!mounted) return;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          _dietaryComment = body['dietary_comment'] as String?;
          _healthComment = body['health_comment'] as String?;
          _loadingAiSummaries = false;
        });
      } else {
        setState(() => _loadingAiSummaries = false);
      }
    } catch (e) {
      debugPrint('[ChildProfile] Failed to load AI summaries: $e');
      if (mounted) setState(() => _loadingAiSummaries = false);
    }
  }

  /// Fetch signalements for this child and filter to today
  Future<void> _loadTodaySignalements() async {
    final childId = int.tryParse(widget.child.id);
    if (childId == null) return;
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/api/children/$childId/signalements'),
        headers: {
          'Accept': 'application/json',
          if (widget.token != null && widget.token!.isNotEmpty)
            'Authorization': 'Bearer ${widget.token}',
        },
      );
      if (!mounted) return;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'];
        if (data is List) {
          final now = DateTime.now();
          final all = data
              .whereType<Map<String, dynamic>>()
              .map((e) => Signalement.fromJson(e))
              .toList();
          final today = all
              .where(
                (s) =>
                    s.incidentTime.year == now.year &&
                    s.incidentTime.month == now.month &&
                    s.incidentTime.day == now.day,
              )
              .toList();
          setState(() {
            _todaySignalements = today;
          });
        } else {
        }
      } else {
      }
    } catch (e) {
      debugPrint('[ChildProfile] Failed to load signalements: $e');
      if (mounted){}
    }
  }

  /// Load activities with criteria IDs from date-based API
  Future<void> _loadCriteriaIds() async {
    if (widget.classId == null || widget.selectedDate == null) return;
    final dateStr = _formatDateApi(widget.selectedDate!);
    final url =
        '$_apiBaseUrl/api/classes/${widget.classId}/activities/date/$dateStr';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          if (widget.token != null && widget.token!.isNotEmpty)
            'Authorization': 'Bearer ${widget.token}',
        },
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'];
        if (data is Map && data['activities'] is List) {
          for (final item in data['activities'] as List) {
            if (item is! Map<String, dynamic>) continue;
            final activityId = (item['activity_id'] as num?)?.toInt() ?? 0;
            final activityName = item['activity_name']?.toString() ?? '';
            if (activityId > 0 && activityName.isNotEmpty) {
              _activityIdByTitle[activityName] = activityId;
            }
            final criteria = item['criteria'];
            if (criteria is List) {
              for (final cr in criteria) {
                if (cr is! Map<String, dynamic>) continue;
                final crId = (cr['criteria_id'] as num?)?.toInt() ?? 0;
                final crName = cr['criteria_name']?.toString() ?? '';
                if (crId > 0 && crName.isNotEmpty) {
                  _criteriaIdByName[crName] = crId;
                }
              }
            }
          }
          _idsLoaded = true;
          debugPrint(
            '[ChildProfile] Loaded ${_activityIdByTitle.length} activities, ${_criteriaIdByName.length} criteria IDs',
          );
        }
      }
    } catch (e) {
      debugPrint('[ChildProfile] Failed to load criteria IDs: $e');
    }
  }

  /// Load existing evaluations for this child on this date
  Future<void> _loadExistingEvaluations() async {
    if (widget.selectedDate == null) return;
    final childId = int.tryParse(widget.child.id);
    if (childId == null) return;
    final dateStr = _formatDateApi(widget.selectedDate!);
    final url = '$_apiBaseUrl/api/children/$childId/evaluations/date/$dateStr';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          if (widget.token != null && widget.token!.isNotEmpty)
            'Authorization': 'Bearer ${widget.token}',
        },
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'];
        if (data is Map && data['evaluations'] is List) {
          for (final evalRaw in data['evaluations'] as List) {
            if (evalRaw is! Map<String, dynamic>) continue;
            final activityName = evalRaw['activity_name']?.toString() ?? '';
            final criteria = evalRaw['criteria'];
            if (criteria is! List) continue;
            for (final cr in criteria) {
              if (cr is! Map<String, dynamic>) continue;
              final crName = cr['criteria_name']?.toString() ?? '';
              final statusLabel = cr['status_label']?.toString() ?? '';
              if (crName.isEmpty || statusLabel == 'En cours') continue;

              // Find matching activity + criterion in activitiesForDay
              for (final activity in widget.activitiesForDay) {
                if (activity.title != activityName) continue;
                for (final criterion in activity.criteria) {
                  if (criterion != crName) continue;
                  final key = _activityCriterionKey(activity, criterion);
                  CompetencyLevel? level;
                  if (statusLabel == 'Acquise') {
                    level = CompetencyLevel.acquise;
                  } else if (statusLabel == '\u00c0 renforcer' ||
                      statusLabel == 'À renforcer') {
                    level = CompetencyLevel.aRenforcer;
                  }
                  if (level != null && mounted) {
                    setState(() {
                      _activityEvaluations[key] = level!;
                    });
                  }
                }
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[ChildProfile] Failed to load existing evaluations: $e');
    }
  }

  String _formatDateApi(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }

  String _activityCriterionKey(DailyClassActivity activity, String criterion) {
    return '${activity.key}|$criterion';
  }

  CompetencyLevel? _currentLevel(
    DailyClassActivity activity,
    String criterion,
  ) {
    return _activityEvaluations[_activityCriterionKey(activity, criterion)];
  }

  void _setActivityLevel(
    DailyClassActivity activity,
    String criterion,
    CompetencyLevel level,
  ) {
    setState(() {
      _activityEvaluations[_activityCriterionKey(activity, criterion)] = level;
    });
    widget.onEvaluationsChanged?.call(
      Map<String, CompetencyLevel>.from(_activityEvaluations),
    );
  }

  bool _isSaving = false;

  Future<void> _saveAllEvals() async {
    if (widget.classId == null || widget.teacherCin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Données manquantes (classId ou teacherCin)')),
      );
      return;
    }
    if (widget.selectedDate == null) return;
    final childId = int.tryParse(widget.child.id);
    if (childId == null) return;

    setState(() => _isSaving = true);

    try {
      final dateStr = _formatDateApi(widget.selectedDate!);
      final evaluations = <Map<String, dynamic>>[];

      for (final activity in widget.activitiesForDay) {
        final actId = _activityIdByTitle[activity.title] ?? activity.id;

        for (final criterion in activity.criteria) {
          final level = _currentLevel(activity, criterion);
          if (level == null || level == CompetencyLevel.enCours) continue;

          final crId = _criteriaIdByName[criterion];
          if (crId == null || crId == 0) continue;

          final statusLabel = level == CompetencyLevel.acquise
              ? 'Acquise'
              : 'À renforcer';

          evaluations.add({
            'child_id': childId,
            'activity_id': actId,
            'criteria_id': crId,
            'status_label': statusLabel,
          });
        }
      }

      final requestBody = {
        'teacher_id': widget.teacherCin,
        'evaluation_date': dateStr,
        'evaluations': evaluations,
      };

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/api/evaluations/bulk'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (widget.token != null && widget.token!.isNotEmpty)
            'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode(requestBody),
      );

      if (!mounted) return;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Toutes les évaluations ont été enregistrées ✓',
              style: TextStyle(fontFamily: TeacherTheme.fontName),
            ),
            backgroundColor: const Color(0xFF00C853),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur: ${response.statusCode}',
              style: TextStyle(fontFamily: AppTheme.fontName),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('[ChildProfile] Save all exception: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur réseau'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  int _totalCriteriaForDay() {
    var total = 0;
    for (final activity in widget.activitiesForDay) {
      total += activity.criteria.length;
    }
    return total;
  }

  int _ratedCriteriaCount() {
    var rated = 0;
    for (final activity in widget.activitiesForDay) {
      for (final criterion in activity.criteria) {
        if (_currentLevel(activity, criterion) != null) {
          rated++;
        }
      }
    }
    return rated;
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

  String _levelLabel(CompetencyLevel level) {
    switch (level) {
      case CompetencyLevel.enCours:
        return 'En cours';
      case CompetencyLevel.acquise:
        return 'Acquise';
      case CompetencyLevel.aRenforcer:
        return 'À renforcer';
    }
  }

  Color _levelColor(CompetencyLevel level) {
    switch (level) {
      case CompetencyLevel.enCours:
        return const Color(0xFFFFA726);
      case CompetencyLevel.acquise:
        return const Color(0xFF00C853);
      case CompetencyLevel.aRenforcer:
        return const Color(0xFFEF5350);
    }
  }

  IconData _levelIcon(CompetencyLevel level) {
    switch (level) {
      case CompetencyLevel.enCours:
        return Icons.timelapse;
      case CompetencyLevel.acquise:
        return Icons.check_circle;
      case CompetencyLevel.aRenforcer:
        return Icons.warning_amber_rounded;
    }
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
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppTheme.fontName,
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
              color: color.withValues(alpha: 0.78),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityEvaluation(DailyClassActivity activity) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: TeacherTheme.surfaceCard(borderRadius: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            activity.title,
            style: TextStyle(
              fontFamily: TeacherTheme.fontName,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: TeacherTheme.lightText,
            ),
          ),
          if (activity.timeLabel.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.schedule, size: 14, color: TeacherTheme.mutedText),
                const SizedBox(width: 4),
                Text(
                  activity.timeLabel,
                  style: TextStyle(
                    fontFamily: TeacherTheme.fontName,
                    fontSize: 12,
                    color: TeacherTheme.mutedText,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          ...activity.criteria.map(
            (criterion) => _buildCriterionLevelPicker(activity, criterion),
          ),
        ],
      ),
    );
  }

  Widget _buildCriterionLevelPicker(
    DailyClassActivity activity,
    String criterion,
  ) {
    final selected = _currentLevel(activity, criterion);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            criterion,
            style: TextStyle(
              fontFamily: TeacherTheme.fontName,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: TeacherTheme.lightText,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: CompetencyLevel.values
                .where((level) => level != CompetencyLevel.enCours)
                .toList()
                .asMap()
                .entries
                .map((entry) {
                  final idx = entry.key;
                  final level = entry.value;
                  final isSelected = selected == level;
                  final color = _levelColor(level);
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: idx < 1 ? 6 : 0),
                      child: GestureDetector(
                        onTap: () =>
                            _setActivityLevel(activity, criterion, level),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withValues(alpha: 0.15)
                                : TeacherTheme.baseDark,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? color
                                  : TeacherTheme.mutedText.withValues(
                                      alpha: 0.25,
                                    ),
                              width: isSelected ? 1.6 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _levelIcon(level),
                                size: 13,
                                color: isSelected
                                    ? color
                                    : TeacherTheme.mutedText,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  _levelLabel(level),
                                  style: TextStyle(
                                    fontFamily: TeacherTheme.fontName,
                                    fontSize: 10,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? color
                                        : TeacherTheme.mutedText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                })
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoActivityState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TeacherTheme.tealAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Aucune activité transmise pour cette vue. Ouvrez ce profil depuis Gérer les classes pour noter les compétences liées aux activités du jour.',
        style: TextStyle(
          fontFamily: TeacherTheme.fontName,
          fontSize: 12,
          color: TeacherTheme.tealAccent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    final child = widget.child;
    final fallbackClassName = '';
    final className = widget.className?.trim().isNotEmpty == true
        ? widget.className!.trim()
        : (fallbackClassName == 'Inconnue' && child.classId.isNotEmpty
              ? child.classId
              : fallbackClassName);
    final activitiesCount = widget.activitiesForDay.length;
    final totalCriteria = _totalCriteriaForDay();
    final ratedCount = _ratedCriteriaCount();
    final selectedDateLabel = widget.selectedDate != null
        ? _formatDate(widget.selectedDate!)
        : null;

    return Scaffold(
      backgroundColor: TeacherTheme.baseDark,
      appBar: AppBar(
        title: Text(
          child.fullName,
          style: TextStyle(
            fontFamily: TeacherTheme.fontName,
            fontWeight: FontWeight.bold,
            color: TeacherTheme.lightText,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: TeacherTheme.lightText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: (_idsLoaded && widget.activitiesForDay.isNotEmpty)
          ? FloatingActionButton.extended(
              onPressed: _isSaving ? null : _saveAllEvals,
              backgroundColor: TeacherTheme.tealAccent,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save, color: Colors.white),
              label: Text(
                _isSaving ? 'Enregistrement...' : 'Enregistrer',
                style: TextStyle(
                  fontFamily: TeacherTheme.fontName,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Today's signalement alert banner ──
            if (_todaySignalements.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.redAccent.withValues(alpha: 0.12),
                      Colors.orange.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.redAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.notification_important,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Signalements du jour',
                          style: TextStyle(
                            fontFamily: AppTheme.fontName,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.redAccent,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_todaySignalements.length}',
                            style: TextStyle(
                              fontFamily: AppTheme.fontName,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._todaySignalements.map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              _alertTypeIcon(s.alertType),
                              size: 16,
                              color: _alertTypeColor(s.alertType),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.alertType,
                                    style: TextStyle(
                                      fontFamily: AppTheme.fontName,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: _alertTypeColor(s.alertType),
                                    ),
                                  ),
                                  if (s.comment != null &&
                                      s.comment!.isNotEmpty)
                                    Text(
                                      s.comment!,
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontName,
                                        fontSize: 12,
                                        color: AppTheme.darkText,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Child info card ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: TeacherTheme.surfaceCard(borderRadius: 16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: TeacherTheme.tealAccent.withValues(
                      alpha: 0.1,
                    ),
                    child: Text(
                      '${child.firstName[0]}${child.lastName[0]}',
                      style: TextStyle(
                        fontFamily: TeacherTheme.fontName,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: TeacherTheme.tealAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    child.fullName,
                    style: TextStyle(
                      fontFamily: TeacherTheme.fontName,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: TeacherTheme.lightText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildInfoChip(Icons.class_, className),
                      const SizedBox(width: 8),
                      _buildInfoChip(Icons.cake, '${child.age} ans'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Activities + competencies section ──
            Row(
              children: [
                Icon(
                  Icons.assignment_turned_in,
                  color: TeacherTheme.tealAccent,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Activités & Compétences',
                  style: TextStyle(
                    fontFamily: TeacherTheme.fontName,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: TeacherTheme.lightText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              selectedDateLabel == null
                  ? 'Attribuez un niveau pour chaque critère des activités.'
                  : 'Date sélectionnée : $selectedDateLabel',
              style: TextStyle(
                fontFamily: TeacherTheme.fontName,
                fontSize: 13,
                color: TeacherTheme.mutedText,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _summaryChip(
                    icon: Icons.event_note,
                    label: 'Activités',
                    value: '$activitiesCount',
                    color: const Color(0xFF5C6BC0),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _summaryChip(
                    icon: Icons.rule,
                    label: 'Critères',
                    value: '$totalCriteria',
                    color: const Color(0xFF26A69A),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _summaryChip(
                    icon: Icons.check_circle_outline,
                    label: 'Évalués',
                    value: '$ratedCount',
                    color: TeacherTheme.tealAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (widget.activitiesForDay.isEmpty)
              _buildNoActivityState()
            else
              ...widget.activitiesForDay.map(_buildActivityEvaluation),

            const SizedBox(height: 24),

            // ── Résumé IA Section ──
            Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: const Color(0xFF8B5CF6),
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Résumé IA',
                  style: TextStyle(
                    fontFamily: TeacherTheme.fontName,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: TeacherTheme.lightText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Analyses générées par l\'intelligence artificielle à partir du dossier médical.',
              style: TextStyle(
                fontFamily: TeacherTheme.fontName,
                fontSize: 12,
                color: TeacherTheme.mutedText,
              ),
            ),
            const SizedBox(height: 14),
            if (_loadingAiSummaries)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: TeacherTheme.surfaceCard(borderRadius: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Chargement des résumés...',
                      style: TextStyle(
                        fontFamily: TeacherTheme.fontName,
                        fontSize: 13,
                        color: TeacherTheme.mutedText,
                      ),
                    ),
                  ],
                ),
              )
            else if (_dietaryComment == null && _healthComment == null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Aucun résumé IA disponible pour cet enfant.',
                  style: TextStyle(
                    fontFamily: TeacherTheme.fontName,
                    fontSize: 12,
                    color: const Color(0xFF8B5CF6),
                  ),
                ),
              )
            else ...[
              // Dietary summary card
              if (_dietaryComment != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: TeacherTheme.tealAccent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: TeacherTheme.tealAccent.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.restaurant,
                            size: 16,
                            color: Color(0xFF4CCEAC),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Restrictions alimentaires',
                            style: TextStyle(
                              fontFamily: TeacherTheme.fontName,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: const Color(0xFF4CCEAC),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _dietaryComment!,
                        style: TextStyle(
                          fontFamily: TeacherTheme.fontName,
                          fontSize: 13,
                          color: TeacherTheme.lightText,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              // Health summary card
              if (_healthComment != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF42A5F5).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF42A5F5).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.local_hospital,
                            size: 16,
                            color: Color(0xFF42A5F5),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Santé générale',
                            style: TextStyle(
                              fontFamily: TeacherTheme.fontName,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: const Color(0xFF42A5F5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _healthComment!,
                        style: TextStyle(
                          fontFamily: TeacherTheme.fontName,
                          fontSize: 13,
                          color: TeacherTheme.lightText,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
            ],

            // ── Signaler un comportement ──
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.redAccent,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Signaler un comportement',
                  style: TextStyle(
                    fontFamily: TeacherTheme.fontName,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: TeacherTheme.lightText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Signalez un comportement inhabituel pour déclencher une alerte pédagogique.',
              style: TextStyle(
                fontFamily: TeacherTheme.fontName,
                fontSize: 12,
                color: TeacherTheme.mutedText,
              ),
            ),
            const SizedBox(height: 12),
            _BehavioralSignalSection(
              childName: child.firstName,
              childId: int.tryParse(child.id),
              token: widget.token,
              teacherCin: widget.teacherCin,
              onSignalAdded: () {
                setState(() {});
                _loadTodaySignalements();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: TeacherTheme.tealAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: TeacherTheme.tealAccent),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: TeacherTheme.fontName,
              fontSize: 13,
              color: TeacherTheme.tealAccent,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _alertTypeIcon(String alertType) {
    switch (alertType) {
      case 'Humeur':
        return Icons.mood_bad;
      case 'Isolement':
        return Icons.person_off;
      case 'Pleurs':
        return Icons.water_drop;
      case 'Agressivité':
        return Icons.flash_on;
      default:
        return Icons.more_horiz;
    }
  }

  Color _alertTypeColor(String alertType) {
    switch (alertType) {
      case 'Humeur':
        return const Color(0xFFFFA726);
      case 'Isolement':
        return const Color(0xFF7E57C2);
      case 'Pleurs':
        return const Color(0xFF42A5F5);
      case 'Agressivité':
        return const Color(0xFFEF5350);
      default:
        return const Color(0xFF78909C);
    }
  }
}

// ───────────────────────────────────────────────────────────────
// Behavioral Signal Section — report mood/isolation/crying etc.
// ───────────────────────────────────────────────────────────────

class _BehavioralSignalSection extends StatefulWidget {
  final String childName;
  final int? childId;
  final String? token;
  final int? teacherCin;
  final VoidCallback onSignalAdded;

  const _BehavioralSignalSection({
    required this.childName,
    this.childId,
    this.token,
    this.teacherCin,
    required this.onSignalAdded,
  });

  @override
  State<_BehavioralSignalSection> createState() =>
      _BehavioralSignalSectionState();
}

class _BehavioralSignalSectionState extends State<_BehavioralSignalSection> {
  static const String _apiBaseUrl = ApiConstants.baseUrl;

  String? _selectedAlertType;
  final TextEditingController _descCtrl = TextEditingController();
  bool _isSending = false;

  // Real signals loaded from API
  List<Signalement> _recentSignals = [];
  bool _isLoadingSignals = true;

  static const _alertTypes = <String, Map<String, dynamic>>{
    'Humeur': {'icon': Icons.mood_bad, 'color': Color(0xFFFFA726)},
    'Isolement': {'icon': Icons.person_off, 'color': Color(0xFF7E57C2)},
    'Pleurs': {'icon': Icons.water_drop, 'color': Color(0xFF42A5F5)},
    'Agressivité': {'icon': Icons.flash_on, 'color': Color(0xFFEF5350)},
    'Autre': {'icon': Icons.more_horiz, 'color': Color(0xFF78909C)},
  };

  @override
  void initState() {
    super.initState();
    _loadRecentSignals();
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSignals() async {
    if (widget.childId == null) {
      setState(() => _isLoadingSignals = false);
      return;
    }
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/api/children/${widget.childId}/signalements'),
        headers: {
          'Accept': 'application/json',
          if (widget.token != null && widget.token!.isNotEmpty)
            'Authorization': 'Bearer ${widget.token}',
        },
      );
      if (!mounted) return;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'];
        if (data is List) {
          setState(() {
            _recentSignals = data
                .whereType<Map<String, dynamic>>()
                .map((e) => Signalement.fromJson(e))
                .toList();
            _isLoadingSignals = false;
          });
        } else {
          setState(() => _isLoadingSignals = false);
        }
      } else {
        setState(() => _isLoadingSignals = false);
      }
    } catch (e) {
      debugPrint('[Signal] Failed to load signals: $e');
      if (mounted) setState(() => _isLoadingSignals = false);
    }
  }

  Future<void> _submit() async {
    if (_selectedAlertType == null) return;
    if (widget.childId == null || widget.teacherCin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Données manquantes (childId ou teacherCin)',
            style: TextStyle(fontFamily: AppTheme.fontName),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    final requestBody = {
      'child_id': widget.childId,
      'teacher_id': widget.teacherCin,
      'alert_type': _selectedAlertType,
      'comment': _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      'incident_time': DateTime.now().toIso8601String(),
    };

    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/api/signalements'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (widget.token != null && widget.token!.isNotEmpty)
            'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode(requestBody),
      );

      if (!mounted) return;
      setState(() => _isSending = false);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _descCtrl.clear();
        setState(() => _selectedAlertType = null);
        widget.onSignalAdded();
        _loadRecentSignals();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Signalement enregistré pour ${widget.childName} ✓',
              style: TextStyle(fontFamily: AppTheme.fontName),
            ),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        debugPrint(
          '[Signal] POST failed: ${response.statusCode} ${response.body}',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur: ${response.statusCode}',
              style: TextStyle(fontFamily: AppTheme.fontName),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      debugPrint('[Signal] Exception: $e');
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur réseau',
              style: TextStyle(fontFamily: AppTheme.fontName),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: TeacherTheme.surfaceCard(borderRadius: 16).copyWith(
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Type de signalement :',
            style: TextStyle(
              fontFamily: TeacherTheme.fontName,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: TeacherTheme.lightText,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _alertTypes.entries.map((entry) {
              final alertType = entry.key;
              final meta = entry.value;
              final isSelected = _selectedAlertType == alertType;
              final color = meta['color'] as Color;
              return GestureDetector(
                onTap: () => setState(
                  () => _selectedAlertType = isSelected ? null : alertType,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withValues(alpha: 0.2)
                        : TeacherTheme.baseDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? color
                          : TeacherTheme.mutedText.withValues(alpha: 0.2),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        meta['icon'] as IconData,
                        size: 18,
                        color: isSelected
                            ? color
                            : TeacherTheme.mutedText.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        alertType,
                        style: TextStyle(
                          fontFamily: TeacherTheme.fontName,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          fontSize: 12,
                          color: isSelected ? color : TeacherTheme.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _descCtrl,
            maxLines: 2,
            style: TextStyle(
              fontFamily: TeacherTheme.fontName,
              fontSize: 14,
              color: TeacherTheme.lightText,
            ),
            decoration: InputDecoration(
              hintText: 'Description (optionnel)...',
              hintStyle: TextStyle(
                fontFamily: TeacherTheme.fontName,
                fontSize: 13,
                color: TeacherTheme.mutedText.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: TeacherTheme.surfaceDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (_selectedAlertType != null && !_isSending)
                  ? _submit
                  : null,
              icon: _isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.warning_amber_rounded, size: 18),
              label: Text(
                _isSending ? 'Envoi en cours...' : 'Envoyer le signalement',
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppTheme.grey.withValues(alpha: 0.15),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Recent signals from API
          if (_isLoadingSignals)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (_recentSignals.isNotEmpty) ...[
            const SizedBox(height: 18),
            Divider(color: ThemeColors.glassBorder),
            const SizedBox(height: 10),
            Text(
              'Signalements récents',
              style: TextStyle(
                fontFamily: TeacherTheme.fontName,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: TeacherTheme.lightText,
              ),
            ),
            const SizedBox(height: 8),
            ..._recentSignals.take(10).map((signal) {
              final meta = _alertTypes[signal.alertType];
              final color =
                  (meta?['color'] as Color?) ?? const Color(0xFF78909C);
              final icon = (meta?['icon'] as IconData?) ?? Icons.more_horiz;
              final dateStr =
                  '${signal.incidentTime.day.toString().padLeft(2, '0')}/${signal.incidentTime.month.toString().padLeft(2, '0')}/${signal.incidentTime.year}';
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: 0.15)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, size: 16, color: color),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                signal.alertType,
                                style: TextStyle(
                                  fontFamily: AppTheme.fontName,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: color,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                dateStr,
                                style: TextStyle(
                                  fontFamily: TeacherTheme.fontName,
                                  fontSize: 11,
                                  color: TeacherTheme.mutedText.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (signal.comment != null &&
                              signal.comment!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              signal.comment!,
                              style: TextStyle(
                                fontFamily: TeacherTheme.fontName,
                                fontSize: 12,
                                color: TeacherTheme.lightText,
                                height: 1.3,
                              ),
                            ),
                          ],
                          if (signal.teacher != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Par ${signal.teacher!.fullName}',
                              style: TextStyle(
                                fontFamily: TeacherTheme.fontName,
                                fontSize: 11,
                                color: TeacherTheme.mutedText,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
