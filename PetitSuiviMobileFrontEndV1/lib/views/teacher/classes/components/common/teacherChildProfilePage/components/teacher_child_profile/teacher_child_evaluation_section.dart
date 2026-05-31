import 'package:flutter/material.dart';
import 'package:newv/views/teacher/classes/components/students/student_activity_models.dart';
import 'package:newv/models/teacher_models.dart';
import 'package:newv/views/teacher/teacher_theme.dart';
import 'package:newv/views/teacher/classes/components/common/teacherChildProfilePage/themes/teacher_child_theme.dart';
import 'package:newv/views/teacher/classes/components/common/teacherChildProfilePage/components/common/teacher_child_chips.dart';
import 'package:newv/views/teacher/classes/components/common/teacherChildProfilePage/components/teacher_child_profile/teacher_child_activity_card.dart';

class TeacherChildEvaluationSection extends StatelessWidget {
  final List<DailyClassActivity> activities;
  final String? selectedDateLabel;
  final int totalCriteria;
  final int ratedCount;
  final CompetencyLevel? Function(DailyClassActivity, String) getCurrentLevel;
  final Function(DailyClassActivity, String, CompetencyLevel) onLevelSelected;
  final bool isEditable;

  const TeacherChildEvaluationSection({
    super.key,
    required this.activities,
    this.selectedDateLabel,
    required this.totalCriteria,
    required this.ratedCount,
    required this.getCurrentLevel,
    required this.onLevelSelected,
    this.isEditable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              style: TeacherChildTheme.sectionTitleStyle,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          selectedDateLabel == null
              ? 'Attribuez un niveau pour chaque critère des activités.'
              : 'Date sélectionnée : $selectedDateLabel',
          style: TeacherChildTheme.sectionSubtitleStyle,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TeacherChildSummaryChip(
                icon: Icons.event_note,
                label: 'Activités',
                value: '${activities.length}',
                color: TeacherChildTheme.activityBlue,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TeacherChildSummaryChip(
                icon: Icons.rule,
                label: 'Critères',
                value: '$totalCriteria',
                color: TeacherChildTheme.criteriaTeal,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TeacherChildSummaryChip(
                icon: Icons.check_circle_outline,
                label: 'Évalués',
                value: '$ratedCount',
                color: TeacherTheme.tealAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (activities.isEmpty)
          _buildNoActivityState()
        else
          ...activities.map(
            (a) => TeacherChildActivityCard(
              activity: a,
              getCurrentLevel: getCurrentLevel,
              onLevelSelected: isEditable ? onLevelSelected : (a, c, l) {},
            ),
          ),
      ],
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
}
