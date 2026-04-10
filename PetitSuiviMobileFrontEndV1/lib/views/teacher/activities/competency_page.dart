/// competency_page.dart
///
/// Multi-step interface for evaluating child competencies and adding
/// signalements (incident reports / behavioral observations).
/// The flow is: **Pick a Class → Pick a Child → Evaluate skills + Add notes**.
///
/// ## State Management
/// - [_CompetencyPageState] holds the selected class, child, activities,
///   evaluations, and signalements. Navigates between steps via back arrow.
/// - [_SkillEditorCard] is a collapsible card that auto-saves when the
///   teacher taps a competency level chip.
/// - [_CustomNoteSection] allows free-text incident reporting.
///
/// ## Backend API Endpoints (via [EvaluationService])
///
/// ### GET /api/classes/{classId}/activities/date/{date}
/// Retrieves activities scheduled for a class on a specific date.
/// - **Response 200:** `{ "data": [ { "activity_id": 1, "activity_name": "Atelier", "criteria": [...] } ] }`
///
/// ### GET /api/children/{childId}/evaluations/date/{date}
/// Retrieves existing evaluations for a child on a specific date.
/// - **Response 200:** `{ "data": [ { "activity_id": 1, "criteria": [ { "criteria_id": 3, "status_label": "Acquise", "comment": "..." } ] } ] }`
///
/// ### POST /api/evaluations
/// Saves a single criterion evaluation for a child.
/// - **Body:** `{ "child_id": 8, "activity_id": 1, "teacher_id": 88552233, "date": "2026-03-05", "criteria_id": 3, "status_label": "Acquise", "comment": "..." }`
///
/// ### GET /api/children/{childId}/signalements
/// Retrieves existing signalements (behavioral notes) for a child.
///
/// ### POST /api/signalements
/// Creates a new signalement entry.
/// - **Body:** `{ "child_id": 8, "teacher_id": 88552233, "activity_id": 1, "alert_type": "Humeur", "comment": "...", "incident_time": "2026-03-05T10:00:00" }`
///
/// ## Dependencies
/// [EvaluationService], [Signalement], [TeacherTheme], [AppTheme], [ThemeManager].

import 'package:flutter/material.dart';
import 'package:newv/app_theme.dart';
import 'package:newv/models/signalement.dart';
import 'package:newv/models/teacher_models.dart' as mock;
import 'package:newv/services/evaluation_service.dart';
import 'package:newv/theme_colors.dart';
import 'package:newv/theme_manager.dart';
import 'package:newv/views/teacher/teacher_theme.dart';
import 'package:provider/provider.dart';
class CompetencyPage extends StatefulWidget {
  const CompetencyPage({super.key});

  @override
  State<CompetencyPage> createState() => _CompetencyPageState();
}

class _CompetencyPageState extends State<CompetencyPage> {
  mock.ClassRoom? _selectedClass;
  mock.MockChild? _selectedChild;

  final EvaluationService _evaluationService = EvaluationService();
  bool _isLoading = false;
  List<dynamic> _classActivities = [];
  List<dynamic> _childEvaluations = [];
  List<Signalement> _signalements = [];

  // Temporary demo date and IDs
  final String _demoDate = "2026-03-05";
  final int _currentTeacherId = 88552233;

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return Scaffold(
      backgroundColor: TeacherTheme.baseDark,
      appBar: AppBar(
        title: Text(
          'Suivi des Compétences',
          style: TextStyle(
            fontFamily: TeacherTheme.fontName,
            fontWeight: FontWeight.bold,
            color: TeacherTheme.lightText,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: TeacherTheme.lightText),
          onPressed: () {
            if (_selectedChild != null) {
              setState(() {
                _selectedChild = null;
                _classActivities = [];
                _childEvaluations = [];
                _signalements = [];
              });
            } else if (_selectedClass != null) {
              setState(() => _selectedClass = null);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: TeacherTheme.tealAccent),
            )
          : _selectedChild != null
          ? _buildCompetencyEditor()
          : _selectedClass != null
          ? _buildChildPicker()
          : _buildClassPicker(),
    );
  }

  // ─────────────────────────────────────────────────────
  // Step 1 — Pick a class
  // ─────────────────────────────────────────────────────
  Widget _buildClassPicker() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Choisir une classe',
          style: TextStyle(
            fontFamily: TeacherTheme.fontName,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: TeacherTheme.lightText,
          ),
        ),
        const SizedBox(height: 16),
        ...<mock.ClassRoom>[].map((cls) => _classCard(cls)),
      ],
    );
  }

  Widget _classCard(mock.ClassRoom cls) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: TeacherTheme.surfaceCard(borderRadius: 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(() => _selectedClass = cls),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: TeacherTheme.tealAccent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.class_,
                    color: TeacherTheme.tealAccent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cls.name,
                        style: TextStyle(
                          fontFamily: TeacherTheme.fontName,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: TeacherTheme.lightText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${cls.children.length} enfants',
                        style: TextStyle(
                          fontFamily: TeacherTheme.fontName,
                          fontSize: 13,
                          color: TeacherTheme.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: TeacherTheme.mutedText.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // Step 2 — Pick a child
  // ─────────────────────────────────────────────────────
  Widget _buildChildPicker() {
    return Column(
      children: [
        // Back to class picker
        InkWell(
          onTap: () => setState(() => _selectedClass = null),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: TeacherTheme.surfaceDark,
              border: Border(
                bottom: BorderSide(color: ThemeColors.glassBorderSubtle),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.arrow_back,
                  size: 18,
                  color: TeacherTheme.tealAccent,
                ),
                const SizedBox(width: 8),
                Text(
                  _selectedClass!.name,
                  style: TextStyle(
                    fontFamily: TeacherTheme.fontName,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: TeacherTheme.tealAccent,
                  ),
                ),
                const Spacer(),
                Text(
                  'Changer de classe',
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
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Choisir un enfant',
                style: TextStyle(
                  fontFamily: TeacherTheme.fontName,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: TeacherTheme.lightText,
                ),
              ),
              const SizedBox(height: 16),
              ..._selectedClass!.children.map((child) => _childCard(child)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _childCard(mock.MockChild child) {
    // For now we assume if they are in the mock data we don't know their real evaluated status until we fetch.
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: TeacherTheme.surfaceCard(borderRadius: 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            setState(() {
              _isLoading = true;
              _selectedChild = child;
            });
            try {
              // Real child & class IDs
              int currentClassId = 3; // Demo: Sami's class
              int currentChildId = child.firstName == "Sami" ? 8 : 999;

              final activities = await _evaluationService.getClassActivities(
                currentClassId,
                _demoDate,
              );
              final evals = await _evaluationService.getChildEvaluations(
                currentChildId,
                _demoDate,
              );
              final signals = await _evaluationService.getSignalementsForChild(
                currentChildId,
              );

              setState(() {
                _classActivities = activities;
                _childEvaluations = evals;
                _signalements = signals;
                _isLoading = false;
              });
            } catch (e) {
              setState(() {
                _isLoading = false;
              });
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8B500).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.child_care,
                    color: Color(0xFFF8B500),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
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
                      const SizedBox(height: 4),
                      Text(
                        '${child.age} ans',
                        style: TextStyle(
                          fontFamily: TeacherTheme.fontName,
                          fontSize: 12,
                          color: TeacherTheme.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: TeacherTheme.mutedText.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // Step 3 — Edit competencies for selected child
  // ─────────────────────────────────────────────────────
  Widget _buildCompetencyEditor() {
    final child = _selectedChild!;

    if (_classActivities.isEmpty) {
      return _buildEmptyState(child);
    }

    return Column(
      children: [
        // Header with back button
        InkWell(
          onTap: () => setState(() {
            _selectedChild = null;
            _classActivities = [];
            _childEvaluations = [];
            _signalements = [];
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: TeacherTheme.surfaceDark,
              border: Border(
                bottom: BorderSide(color: ThemeColors.glassBorderSubtle),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.arrow_back,
                  size: 18,
                  color: TeacherTheme.tealAccent,
                ),
                const SizedBox(width: 8),
                Text(
                  child.fullName,
                  style: TextStyle(
                    fontFamily: TeacherTheme.fontName,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: TeacherTheme.tealAccent,
                  ),
                ),
                const Spacer(),
                Text(
                  'Changer d\'enfant',
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
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Évaluations de ${child.firstName}',
                style: TextStyle(
                  fontFamily: TeacherTheme.fontName,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: TeacherTheme.lightText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Les évaluations sont automatiquement sauvegardées lors de la sélection.',
                style: TextStyle(
                  fontFamily: TeacherTheme.fontName,
                  fontSize: 13,
                  color: TeacherTheme.mutedText,
                ),
              ),
              const SizedBox(height: 20),

              // Activity Cards
              ..._classActivities.map((activity) {
                return _buildActivityEvaluationSection(
                  activity,
                  _childEvaluations,
                );
              }),

              const SizedBox(height: 24),

              // Signalements Section
              _CustomNoteSection(
                childName: child.firstName,
                existingNotes: _signalements,
                onAddNote: (text) async {
                  final signalement = Signalement(
                    id: 0,
                    childId: child.firstName == "Sami"
                        ? 8
                        : 999, // Hack for demo
                    teacherId: _currentTeacherId,
                    activityId: _classActivities.isNotEmpty
                        ? _classActivities.first['activity_id']
                        : null,
                    alertType: 'Humeur',
                    comment: text,
                    incidentTime: DateTime.now(),
                  );

                  try {
                    await _evaluationService.saveSignalement(signalement);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Note ajoutée pour ${child.firstName}'),
                          backgroundColor: AppTheme.nearlyDarkBlue,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                    // Refetch just to update notes
                    final currentChildId = child.firstName == "Sami" ? 8 : 999;
                    final signals = await _evaluationService
                        .getSignalementsForChild(currentChildId);
                    setState(() {
                      _signalements = signals;
                    });
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erreur: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(mock.MockChild child) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() {
            _selectedChild = null;
            _classActivities = [];
            _childEvaluations = [];
            _signalements = [];
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: TeacherTheme.surfaceDark,
              border: Border(
                bottom: BorderSide(color: ThemeColors.glassBorderSubtle),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.arrow_back,
                  size: 18,
                  color: TeacherTheme.tealAccent,
                ),
                const SizedBox(width: 8),
                Text(
                  child.fullName,
                  style: TextStyle(
                    fontFamily: TeacherTheme.fontName,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: TeacherTheme.tealAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              'Aucune activité prévue pour aujourd\'hui.',
              style: TextStyle(
                fontFamily: TeacherTheme.fontName,
                color: TeacherTheme.lightText,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityEvaluationSection(
    dynamic activityData,
    List<dynamic> childEvaluations,
  ) {
    final existingEval = childEvaluations.firstWhere(
      (e) => e['activity_id'] == activityData['activity_id'],
      orElse: () => null,
    );
    final existingCriteria = existingEval != null
        ? existingEval['criteria'] as List<dynamic>
        : [];

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TeacherTheme.tealAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_activity,
                  color: TeacherTheme.tealAccent,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    activityData['activity_name'] ?? 'Activité',
                    style: TextStyle(
                      fontFamily: TeacherTheme.fontName,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: TeacherTheme.tealAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...((activityData['criteria'] as List<dynamic>).map((criterion) {
            final savedCrit = existingCriteria.firstWhere(
              (c) => c['criteria_id'] == criterion['criteria_id'],
              orElse: () => null,
            );
            final initialLevelStr = savedCrit != null
                ? savedCrit['status_label']
                : 'En cours';
            final initialComment = savedCrit != null
                ? savedCrit['comment']
                : null;

            return _SkillEditorCard(
              key: ValueKey(
                '${_selectedChild!.firstName}_${activityData['activity_id']}_${criterion['criteria_id']}',
              ),
              criterionName: criterion['criteria_name'] ?? 'Compétence',
              initialLevelStr: initialLevelStr,
              currentComment: initialComment,
              onChanged: (newLevelStr, newComment) async {
                try {
                  await _evaluationService.evaluateCriteria(
                    childId: _selectedChild!.firstName == "Sami" ? 8 : 999,
                    activityId: activityData['activity_id'],
                    teacherId: _currentTeacherId,
                    date: _demoDate,
                    criteriaId: criterion['criteria_id'],
                    statusLabel: newLevelStr,
                    comment: newComment,
                  );

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Sauvegardé.'),
                        backgroundColor: const Color(0xFF00C853),
                        duration: const Duration(milliseconds: 1500),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            );
          })),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Skill Editor Card — lets teacher pick a level for a single skill
// ─────────────────────────────────────────────────────────────────

class _SkillEditorCard extends StatefulWidget {
  final String criterionName;
  final String initialLevelStr;
  final String? currentComment;
  // We remove the explicit save button. It auto triggers on tap.
  final void Function(String levelStr, String? comment) onChanged;

  const _SkillEditorCard({
    super.key,
    required this.criterionName,
    required this.initialLevelStr,
    this.currentComment,
    required this.onChanged,
  });

  @override
  State<_SkillEditorCard> createState() => _SkillEditorCardState();
}

class _SkillEditorCardState extends State<_SkillEditorCard> {
  late String _levelStr;
  late TextEditingController _commentCtrl;
  bool _expanded = false;

  final List<String> availableLevels = ['Acquise', 'En cours', 'À renforcer'];

  @override
  void initState() {
    super.initState();
    _levelStr = widget.initialLevelStr;
    _commentCtrl = TextEditingController(text: widget.currentComment ?? '');
  }

  @override
  void didUpdateWidget(_SkillEditorCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialLevelStr != oldWidget.initialLevelStr) {
      _levelStr = widget.initialLevelStr;
    }
    if (widget.currentComment != oldWidget.currentComment) {
      _commentCtrl.text = widget.currentComment ?? '';
    }
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Color _levelColor(String levelStr) {
    switch (levelStr) {
      case 'Acquise':
        return const Color(0xFF00C853);
      case 'En cours':
        return const Color(0xFFFFA726);
      case 'À renforcer':
        return const Color(0xFFEF5350);
      default:
        return TeacherTheme.mutedText;
    }
  }

  IconData _levelIcon(String levelStr) {
    switch (levelStr) {
      case 'Acquise':
        return Icons.check_circle;
      case 'En cours':
        return Icons.timelapse;
      case 'À renforcer':
        return Icons.warning_amber_rounded;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    final color = _levelColor(_levelStr);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: TeacherTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header (always visible)
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.star, color: color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.criterionName,
                      style: TextStyle(
                        fontFamily: TeacherTheme.fontName,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: TeacherTheme.lightText,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_levelIcon(_levelStr), size: 14, color: color),
                        const SizedBox(width: 4),
                        Text(
                          _levelStr,
                          style: TextStyle(
                            fontFamily: TeacherTheme.fontName,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: TeacherTheme.mutedText,
                  ),
                ],
              ),
            ),
          ),

          // Expanded editor
          if (_expanded) ...[
            Divider(height: 1, color: ThemeColors.glassBorder),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attribuer un niveau :',
                    style: TextStyle(
                      fontFamily: TeacherTheme.fontName,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: TeacherTheme.lightText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Level selection chips (AUTO SAVE ON TAP)
                  Row(
                    children: availableLevels.map((lvl) {
                      final isSelected = _levelStr == lvl;
                      final c = _levelColor(lvl);
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _levelStr = lvl);
                            widget.onChanged(
                              lvl,
                              _commentCtrl.text.isEmpty
                                  ? null
                                  : _commentCtrl.text,
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? c.withValues(alpha: 0.2)
                                  : TeacherTheme.baseDark,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? c
                                    : TeacherTheme.mutedText.withValues(
                                        alpha: 0.2,
                                      ),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  _levelIcon(lvl),
                                  size: 22,
                                  color: isSelected
                                      ? c
                                      : AppTheme.grey.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  lvl,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: TeacherTheme.fontName,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    fontSize: 10,
                                    color: isSelected
                                        ? c
                                        : TeacherTheme.mutedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Comment field
                  Text(
                    'Commentaire (optionnel) :',
                    style: TextStyle(
                      fontFamily: TeacherTheme.fontName,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: TeacherTheme.lightText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _commentCtrl,
                    maxLines: 2,
                    style: TextStyle(
                      fontFamily: TeacherTheme.fontName,
                      fontSize: 14,
                      color: TeacherTheme.lightText,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ex: Bon progrès cette semaine...',
                      hintStyle: TextStyle(
                        fontFamily: TeacherTheme.fontName,
                        fontSize: 13,
                        color: TeacherTheme.mutedText.withValues(alpha: 0.5),
                      ),
                      filled: true,
                      fillColor: TeacherTheme.baseDark,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                    onSubmitted: (value) {
                      widget.onChanged(_levelStr, value.isEmpty ? null : value);
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Custom Note Section — teacher can add free-form observations
// ─────────────────────────────────────────────────────────────

class _CustomNoteSection extends StatefulWidget {
  final String childName;
  final List<Signalement> existingNotes;
  final void Function(String text) onAddNote;

  const _CustomNoteSection({
    required this.childName,
    required this.existingNotes,
    required this.onAddNote,
  });

  @override
  State<_CustomNoteSection> createState() => _CustomNoteSectionState();
}

class _CustomNoteSectionState extends State<_CustomNoteSection> {
  final TextEditingController _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: TeacherTheme.surfaceCard(borderRadius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note_add, color: TeacherTheme.tealAccent, size: 22),
              const SizedBox(width: 8),
              Text(
                'Notes & Signalements',
                style: TextStyle(
                  fontFamily: TeacherTheme.fontName,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: TeacherTheme.lightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Ajoutez une observation ou signalez un incident (Humeur, Isolement, etc).',
            style: TextStyle(
              fontFamily: TeacherTheme.fontName,
              fontSize: 12,
              color: TeacherTheme.mutedText,
            ),
          ),
          const SizedBox(height: 14),

          // Input field
          TextField(
            controller: _noteCtrl,
            maxLines: 3,
            style: TextStyle(
              fontFamily: TeacherTheme.fontName,
              fontSize: 14,
              color: TeacherTheme.lightText,
            ),
            decoration: InputDecoration(
              hintText: 'Ex: L\'enfant semblait fatigué aujourd\'hui...',
              hintStyle: TextStyle(
                fontFamily: TeacherTheme.fontName,
                fontSize: 13,
                color: TeacherTheme.mutedText.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: TeacherTheme.baseDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (_noteCtrl.text.trim().isEmpty) return;
                widget.onAddNote(_noteCtrl.text.trim());
                _noteCtrl.clear();
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                'Ajouter la note',
                style: TextStyle(
                  fontFamily: TeacherTheme.fontName,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: TeacherTheme.tealAccent,
                foregroundColor: TeacherTheme.baseDark,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Existing notes
          if (widget.existingNotes.isNotEmpty) ...[
            const SizedBox(height: 20),
            Divider(color: ThemeColors.glassBorder),
            const SizedBox(height: 12),
            Text(
              'Notes précédentes',
              style: TextStyle(
                fontFamily: TeacherTheme.fontName,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: TeacherTheme.lightText,
              ),
            ),
            const SizedBox(height: 10),
            ...widget.existingNotes.map((note) {
              final dateStr =
                  '${note.incidentTime.day.toString().padLeft(2, '0')}/${note.incidentTime.month.toString().padLeft(2, '0')}/${note.incidentTime.year}';
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: TeacherTheme.baseDark,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: ThemeColors.glassBorderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '[${note.alertType}]',
                          style: TextStyle(
                            fontFamily: AppTheme.fontName,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[800],
                          ),
                        ),
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontFamily: TeacherTheme.fontName,
                            fontSize: 11,
                            color: TeacherTheme.mutedText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      note.comment ?? '',
                      style: TextStyle(
                        fontFamily: TeacherTheme.fontName,
                        fontSize: 13,
                        color: TeacherTheme.lightText,
                        height: 1.4,
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
