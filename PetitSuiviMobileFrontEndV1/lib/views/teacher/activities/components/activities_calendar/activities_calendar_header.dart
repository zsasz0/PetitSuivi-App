import 'package:flutter/material.dart';
import 'package:newv/views/teacher/teacher_theme.dart';
import 'package:newv/views/teacher/activities/themes/activities_theme.dart';

class ActivitiesCalendarHeader extends StatelessWidget {
  final int visibleYear;
  final bool canGoPrev;
  final bool canGoNext;
  final Function(int) onYearChanged;

  const ActivitiesCalendarHeader({
    super.key,
    required this.visibleYear,
    required this.canGoPrev,
    required this.canGoNext,
    required this.onYearChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: canGoPrev ? TeacherTheme.lightText : TeacherTheme.mutedText,
            ),
            onPressed: canGoPrev ? () => onYearChanged(visibleYear - 1) : null,
          ),
          Text(
            '$visibleYear',
            style: TextStyle(
              fontFamily: TeacherTheme.fontName,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ActivitiesTheme.primaryBlue,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: canGoNext ? TeacherTheme.lightText : TeacherTheme.mutedText,
            ),
            onPressed: canGoNext ? () => onYearChanged(visibleYear + 1) : null,
          ),
        ],
      ),
    );
  }
}
