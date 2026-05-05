import 'package:flutter/material.dart';
import 'package:newv/views/teacher/teacher_theme.dart';
import 'package:newv/views/teacher/activities/themes/activities_theme.dart';

class AttendanceStatsBanner extends StatelessWidget {
  final int total;
  final int presents;
  final int absents;

  const AttendanceStatsBanner({
    super.key,
    required this.total,
    required this.presents,
    required this.absents,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _statChip(
            icon: Icons.people,
            label: 'Total',
            value: '$total',
            color: ActivitiesTheme.primaryBlue,
          ),
          const SizedBox(width: 10),
          _statChip(
            icon: Icons.check_circle,
            label: 'Présents',
            value: '$presents',
            color: Colors.green,
          ),
          const SizedBox(width: 10),
          _statChip(
            icon: Icons.cancel,
            label: 'Absents',
            value: '$absents',
            color: Colors.redAccent,
          ),
        ],
      ),
    );
  }

  Widget _statChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontFamily: TeacherTheme.fontName,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: TeacherTheme.fontName,
                fontSize: 11,
                color: color.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
