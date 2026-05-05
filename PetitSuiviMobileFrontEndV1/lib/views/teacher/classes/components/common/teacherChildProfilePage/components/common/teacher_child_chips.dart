import 'package:flutter/material.dart';
import 'package:newv/views/teacher/teacher_theme.dart';
import 'package:newv/views/themes/app_theme.dart';

class TeacherChildInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const TeacherChildInfoChip({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
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
}

class TeacherChildSummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const TeacherChildSummaryChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
}
