import 'package:flutter/material.dart';
import 'package:newv/views/teacher/classes/components/students/student_activity_models.dart';
import 'package:newv/models/teacher_models.dart';
import 'package:newv/views/teacher/teacher_theme.dart';
import 'package:newv/views/teacher/classes/components/common/teacherChildProfilePage/components/teacher_child_profile/teacher_child_criterion_picker.dart';

class TeacherChildActivityCard extends StatelessWidget {
  final DailyClassActivity activity;
  final CompetencyLevel? Function(DailyClassActivity, String) getCurrentLevel;
  final Function(DailyClassActivity, String, CompetencyLevel) onLevelSelected;

  const TeacherChildActivityCard({
    super.key,
    required this.activity,
    required this.getCurrentLevel,
    required this.onLevelSelected,
  });

  @override
  Widget build(BuildContext context) {
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
            (criterion) => TeacherChildCriterionPicker(
              activity: activity,
              criterion: criterion,
              selectedLevel: getCurrentLevel(activity, criterion),
              onLevelSelected: (level) => onLevelSelected(activity, criterion, level),
            ),
          ),
        ],
      ),
    );
  }
}
