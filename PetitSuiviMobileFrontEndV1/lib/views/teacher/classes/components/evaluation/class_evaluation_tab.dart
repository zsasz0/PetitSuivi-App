import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:newv/views/themes/theme_manager.dart';
import 'package:newv/views/themes/theme_colors.dart';
import 'package:newv/models/teacher_models.dart';
import 'package:newv/views/teacher/classes/components/common/teacherChildProfilePage/teacher_child_profile_page.dart';
import 'package:newv/views/teacher/classes/components/students/student_activity_models.dart';
import 'package:newv/views/teacher/classes/controllers/class_evaluation_controller.dart';
import 'package:newv/views/teacher/classes/themes/teacher_classes_theme.dart';

class ClassEvaluationTab extends StatefulWidget {
  final int classId;
  final DateTime selectedDate;
  final Future<void> Function() onPickDate;
  final String token;
  final int teacherCin;

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
  final ClassEvaluationController _controller = ClassEvaluationController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(ClassEvaluationTab old) {
    super.didUpdateWidget(old);
    if (old.selectedDate != widget.selectedDate ||
        old.classId != widget.classId) {
      _loadData();
    }
  }

  void _loadData() {
    _controller.loadAll(
      context: context,
      classId: widget.classId,
      selectedDate: widget.selectedDate,
      token: widget.token,
      setState: setState,
      isMounted: () => mounted,
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    final isLoading =
        _controller.isLoadingActivities || _controller.isLoadingStudents;
    final int activitiesCount = _controller.activities.length;
    final int totalCriteria = _controller.activities.fold(
      0,
      (sum, a) => sum + a.criteria.length,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildDateHeader(),
          if (!isLoading &&
              _controller.students.isNotEmpty &&
              _controller.activities.isNotEmpty)
            _buildSummaryStats(activitiesCount, totalCriteria),
          if (isLoading) _buildLoadingIndicator(),
          if (!isLoading &&
              _controller.activitiesError == null &&
              _controller.studentsError == null)
            _buildLayoutToggle(),
          if (_controller.activitiesError != null)
            _errorBanner(
              _controller.activitiesError!,
              () => _controller.loadActivities(
                context: context,
                classId: widget.classId,
                selectedDate: widget.selectedDate,
                token: widget.token,
                setState: setState,
                isMounted: () => mounted,
              ),
            ),
          if (_controller.studentsError != null)
            _errorBanner(
              _controller.studentsError!,
              () => _controller.loadStudents(
                context: context,
                classId: widget.classId,
                token: widget.token,
                setState: setState,
                isMounted: () => mounted,
              ),
            ),
          _buildMainList(isLoading),
        ],
      ),
      floatingActionButton:
          (widget.selectedDate.year == DateTime.now().year &&
              widget.selectedDate.month == DateTime.now().month &&
              widget.selectedDate.day == DateTime.now().day)
          ? FloatingActionButton.extended(
              onPressed: () => _controller.saveAllEvals(
                context: context,
                selectedDate: widget.selectedDate,
                token: widget.token,
                teacherCin: widget.teacherCin,
                setState: setState,
                isMounted: () => mounted,
              ),
              backgroundColor: TeacherClassesTheme.tealAccent,
              foregroundColor: TeacherClassesTheme.baseDark,
              icon: const Icon(Icons.save),
              label: const Text(
                'Enregistrer',
                style: TextStyle(
                  fontFamily: TeacherClassesTheme.fontName,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildDateHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: widget.onPickDate,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: TeacherClassesTheme.surfaceCard(borderRadius: 12),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: TeacherClassesTheme.tealAccent,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _formatDate(widget.selectedDate),
                  style: TextStyle(
                    fontFamily: TeacherClassesTheme.fontName,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: TeacherClassesTheme.lightText,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: TeacherClassesTheme.mutedText.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryStats(int activitiesCount, int totalCriteria) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _summaryChip(
              icon: Icons.child_care,
              label: 'Élèves',
              value: '${_controller.students.length}',
              color: TeacherClassesTheme.indigoAccent,
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
              color: TeacherClassesTheme.tealAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: LinearProgressIndicator(
        minHeight: 2,
        color: TeacherClassesTheme.tealAccent,
      ),
    );
  }

  Widget _buildLayoutToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: ThemeColors.glassBorderSubtle,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            _toggleItem(
              'Par Élève',
              _controller.isStudentLayout,
              () => setState(() => _controller.isStudentLayout = true),
            ),
            _toggleItem(
              'Par Activité',
              !_controller.isStudentLayout,
              () => setState(() => _controller.isStudentLayout = false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleItem(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: active
                ? TeacherClassesTheme.surfaceDark
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: active
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
            label,
            style: TextStyle(
              fontFamily: TeacherClassesTheme.fontName,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
              color: active
                  ? TeacherClassesTheme.tealAccent
                  : TeacherClassesTheme.mutedText,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainList(bool isLoading) {
    if (!isLoading &&
        _controller.activitiesError == null &&
        _controller.studentsError == null &&
        _controller.activities.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: TeacherClassesTheme.indigoAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _controller.isStudentLayout
                ? 'Aucun élève trouvé.'
                : 'Aucune activité prévue pour cette date.',
            style: TextStyle(
              fontFamily: TeacherClassesTheme.fontName,
              fontSize: 13,
              color: TeacherClassesTheme.lightText,
            ),
          ),
        ),
      );
    }

    if (_controller.isStudentLayout) {
      return Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          itemCount: _controller.students.length,
          itemBuilder: (context, i) =>
              _buildChildCard(context, _controller.students[i]),
        ),
      );
    } else {
      return Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          itemCount: _controller.activities.length,
          itemBuilder: (context, i) =>
              _buildActivityCard(_controller.activities[i]),
        ),
      );
    }
  }

  Widget _buildChildCard(BuildContext context, ClassStudent child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: TeacherClassesTheme.surfaceCard(borderRadius: 16),
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
                      backgroundColor: TeacherClassesTheme.tealAccent
                          .withValues(alpha: 0.15),
                      child: Text(
                        '${child.firstName[0]}${child.lastName[0]}',
                        style: TextStyle(
                          fontFamily: TeacherClassesTheme.fontName,
                          fontWeight: FontWeight.bold,
                          color: TeacherClassesTheme.tealAccent,
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
                              fontFamily: TeacherClassesTheme.fontName,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: TeacherClassesTheme.lightText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '5 ans',
                            style: TextStyle(
                              fontFamily: TeacherClassesTheme.fontName,
                              fontSize: 12,
                              color: TeacherClassesTheme.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: TeacherClassesTheme.mutedText.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Touchez pour voir les activités et évaluer les compétences.',
                  style: TextStyle(
                    fontFamily: TeacherClassesTheme.fontName,
                    fontSize: 12,
                    color: TeacherClassesTheme.mutedText,
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
      decoration: TeacherClassesTheme.surfaceCard(borderRadius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: TeacherClassesTheme.indigoAccent.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event_note,
                  color: TeacherClassesTheme.indigoAccent,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    activity.activityName,
                    style: TextStyle(
                      fontFamily: TeacherClassesTheme.fontName,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: TeacherClassesTheme.lightText,
                    ),
                  ),
                ),
                _miniChip(
                  '${activity.criteria.length} critère(s)',
                  TeacherClassesTheme.tealAccent,
                ),
              ],
            ),
          ),
          if (activity.criteria.isEmpty)
            Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                'Aucun critère défini pour cette activité.',
                style: TextStyle(
                  fontFamily: TeacherClassesTheme.fontName,
                  fontSize: 12,
                  color: TeacherClassesTheme.mutedText,
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
    final isExpanded = _controller.expandedCriteria.contains(criterionKey);

    int evaluatedCount = 0;
    for (final s in _controller.students) {
      final key = _controller.evalKey(
        s.id,
        activity.activityId,
        criterion.criteriaId,
      );
      if (_controller.pending[key] != null) evaluatedCount++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () =>
              _controller.toggleCriteriaExpansion(criterionKey, setState),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Icon(
                  Icons.rule,
                  size: 15,
                  color: TeacherClassesTheme.tealAccent,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    criterion.criteriaName,
                    style: TextStyle(
                      fontFamily: TeacherClassesTheme.fontName,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: TeacherClassesTheme.lightText,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: TeacherClassesTheme.indigoAccent.withValues(
                      alpha: 0.15,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$evaluatedCount/${_controller.students.length}',
                    style: TextStyle(
                      fontFamily: TeacherClassesTheme.fontName,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: TeacherClassesTheme.indigoAccent,
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
                    color: TeacherClassesTheme.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: _controller.students
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
    final key = _controller.evalKey(
      student.id,
      activity.activityId,
      criterion.criteriaId,
    );
    final status = _controller.pending[key];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _openStudentProfile(context, student),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: TeacherClassesTheme.indigoAccent
                            .withValues(alpha: 0.15),
                        child: Text(
                          '${student.firstName[0]}${student.lastName[0]}',
                          style: TextStyle(
                            fontFamily: TeacherClassesTheme.fontName,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: TeacherClassesTheme.indigoAccent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          student.fullName,
                          style: TextStyle(
                            fontFamily: TeacherClassesTheme.fontName,
                            fontSize: 13,
                            color: TeacherClassesTheme.lightText,
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
            onTap: () => _controller.toggleStatus(
              student.id,
              activity.activityId,
              criterion.criteriaId,
              CriteriaEvalStatus.acquise,
              setState,
              widget.selectedDate,
              context,
            ),
          ),
          const SizedBox(width: 6),
          _evalChip(
            label: 'À renforcer',
            icon: Icons.warning_amber_rounded,
            color: Colors.redAccent,
            isSelected: status == CriteriaEvalStatus.aRenforcer,
            onTap: () => _controller.toggleStatus(
              student.id,
              activity.activityId,
              criterion.criteriaId,
              CriteriaEvalStatus.aRenforcer,
              setState,
              widget.selectedDate,
              context,
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
              : TeacherClassesTheme.cardDark,
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
              color: isSelected ? color : TeacherClassesTheme.mutedText,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: TeacherClassesTheme.fontName,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? color : TeacherClassesTheme.mutedText,
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
          fontFamily: TeacherClassesTheme.fontName,
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
                style: TextStyle(
                  fontFamily: TeacherClassesTheme.fontName,
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
            style: TeacherClassesTheme.summaryValueStyle.copyWith(color: color),
          ),
          Text(
            label,
            style: TeacherClassesTheme.summaryLabelStyle.copyWith(
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
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

    final dailyActivities = _controller.activities
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
          onEvaluationsChanged: (updatedLevels) async {
            await _controller.loadExistingEvals(
              selectedDate: widget.selectedDate,
              token: widget.token,
              setState: setState,
              isMounted: () => mounted,
            );
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
}
