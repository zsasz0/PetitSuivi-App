import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:newv/views/themes/theme_manager.dart';
import 'package:newv/views/teacher/teacher_theme.dart';
import 'package:newv/models/teacher_models.dart';
import 'package:newv/views/teacher/classes/components/students/student_activity_models.dart';
import 'package:newv/views/teacher/classes/components/common/teacherChildProfilePage/controllers/teacher_child_controller.dart';
import 'package:newv/views/teacher/classes/components/common/teacherChildProfilePage/components/teacher_child_profile/teacher_child_profile_header.dart';
import 'package:newv/views/teacher/classes/components/common/teacherChildProfilePage/components/teacher_child_profile/teacher_child_evaluation_section.dart';
import 'package:newv/views/teacher/classes/components/common/teacherChildProfilePage/components/teacher_child_profile/teacher_child_ai_summary_section.dart';
import 'package:newv/views/teacher/classes/components/common/teacherChildProfilePage/components/teacher_child_profile/teacher_child_behavioral_signal_section.dart';
import 'package:newv/views/teacher/classes/components/common/teacherChildProfilePage/components/teacher_child_profile/teacher_child_signalement_banner.dart';

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
  late TeacherChildController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TeacherChildController(
      child: widget.child,
      classId: widget.classId,
      selectedDate: widget.selectedDate,
      token: widget.token,
      teacherCin: widget.teacherCin,
      activitiesForDay: widget.activitiesForDay,
      initialEvaluations: widget.initialEvaluations,
      onEvaluationsChanged: widget.onEvaluationsChanged,
      setState: setState,
      context: context,
    );
    _controller.init();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();

    final className = widget.className?.trim().isNotEmpty == true
        ? widget.className!.trim()
        : (widget.child.classId.isNotEmpty ? widget.child.classId : '');

    final selectedDateLabel = widget.selectedDate != null
        ? _formatDate(widget.selectedDate!)
        : null;

    return Scaffold(
      backgroundColor: TeacherTheme.baseDark,
      appBar: AppBar(
        title: Text(
          widget.child.fullName,
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
      floatingActionButton:
          (_controller.idsLoaded &&
              widget.activitiesForDay.isNotEmpty &&
              widget.selectedDate != null &&
              widget.selectedDate!.year == DateTime.now().year &&
              widget.selectedDate!.month == DateTime.now().month &&
              widget.selectedDate!.day == DateTime.now().day)
          ? FloatingActionButton.extended(
              onPressed: _controller.isSaving ? null : _controller.saveAllEvals,
              backgroundColor: TeacherTheme.tealAccent,
              icon: _controller.isSaving
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
                _controller.isSaving ? 'Enregistrement...' : 'Enregistrer',
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
            TeacherChildSignalementBanner(
              signalements: _controller.todaySignalements,
            ),
            TeacherChildProfileHeader(
              child: widget.child,
              className: className,
            ),
            const SizedBox(height: 24),
            TeacherChildEvaluationSection(
              activities: widget.activitiesForDay,
              selectedDateLabel: selectedDateLabel,
              totalCriteria: _controller.getTotalCriteriaCount(),
              ratedCount: _controller.getRatedCriteriaCount(),
              getCurrentLevel: _controller.getCurrentLevel,
              onLevelSelected: _controller.setActivityLevel,
              isEditable:
                  widget.selectedDate != null &&
                  widget.selectedDate!.year == DateTime.now().year &&
                  widget.selectedDate!.month == DateTime.now().month &&
                  widget.selectedDate!.day == DateTime.now().day,
            ),
            const SizedBox(height: 24),
            TeacherChildAiSummarySection(
              isLoading: _controller.loadingAiSummaries,
              dietaryComment: _controller.dietaryComment,
              healthComment: _controller.healthComment,
            ),
            const SizedBox(height: 24),
            TeacherChildBehavioralSignalSection(
              isSending: _controller.isSendingSignal,
              onSignalSubmit: _controller.submitSignalement,
            ),
          ],
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
}
