import 'package:flutter/material.dart';
import 'package:newv/views/teacher/classes/components/students/student_activity_models.dart';
import 'package:newv/models/teacher_models.dart';
import 'package:newv/views/teacher/teacher_theme.dart';
import 'package:newv/views/teacher/classes/components/common/teacherChildProfilePage/themes/teacher_child_theme.dart';

class TeacherChildCriterionPicker extends StatelessWidget {
  final DailyClassActivity activity;
  final String criterion;
  final CompetencyLevel? selectedLevel;
  final Function(CompetencyLevel) onLevelSelected;

  const TeacherChildCriterionPicker({
    super.key,
    required this.activity,
    required this.criterion,
    required this.selectedLevel,
    required this.onLevelSelected,
  });

  @override
  Widget build(BuildContext context) {
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
              final isSelected = selectedLevel == level;
              final color = _levelColor(level);
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: idx < 1 ? 6 : 0),
                  child: GestureDetector(
                    onTap: () => onLevelSelected(level),
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
                            color: isSelected ? color : TeacherTheme.mutedText,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              _levelLabel(level),
                              style: TextStyle(
                                fontFamily: TeacherTheme.fontName,
                                fontSize: 10,
                                fontWeight:
                                    isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? color : TeacherTheme.mutedText,
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
            }).toList(),
          ),
        ],
      ),
    );
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
        return TeacherChildTheme.enCoursColor;
      case CompetencyLevel.acquise:
        return TeacherChildTheme.acquiseColor;
      case CompetencyLevel.aRenforcer:
        return TeacherChildTheme.aRenforcerColor;
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
}
