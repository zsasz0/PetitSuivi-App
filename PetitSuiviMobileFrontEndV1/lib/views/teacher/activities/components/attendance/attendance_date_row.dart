import 'package:flutter/material.dart';
import 'package:newv/views/teacher/teacher_theme.dart';
import 'package:newv/views/teacher/activities/themes/activities_theme.dart';

class AttendanceDateRow extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onTap;

  const AttendanceDateRow({
    super.key,
    required this.selectedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final months = [
      '', 'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
    ];
    final days = [
      '', 'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche',
    ];
    final dayName = days[selectedDate.weekday];
    final formattedDate =
        '$dayName ${selectedDate.day} ${months[selectedDate.month]} ${selectedDate.year}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: TeacherTheme.surfaceCard(borderRadius: 12),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: ActivitiesTheme.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                formattedDate,
                style: TextStyle(
                  fontFamily: TeacherTheme.fontName,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: TeacherTheme.lightText,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_drop_down,
                color: TeacherTheme.mutedText.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
