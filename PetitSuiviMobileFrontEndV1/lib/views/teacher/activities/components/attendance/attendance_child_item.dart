import 'package:flutter/material.dart';
import 'package:newv/models/teacher_models.dart';
import 'package:newv/views/teacher/teacher_theme.dart';

class AttendanceChildItem extends StatelessWidget {
  final MockChild child;
  final bool isPresent;
  final VoidCallback onTap;

  const AttendanceChildItem({
    super.key,
    required this.child,
    required this.isPresent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: TeacherTheme.surfaceCard(borderRadius: 14).copyWith(
        border: Border.all(
          color: isPresent
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.redAccent.withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: isPresent
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.redAccent.withValues(alpha: 0.1),
                  child: Text(
                    '${child.firstName[0]}${child.lastName[0]}',
                    style: TextStyle(
                      fontFamily: TeacherTheme.fontName,
                      fontWeight: FontWeight.bold,
                      color: isPresent ? Colors.green : Colors.redAccent,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Name
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
                      const SizedBox(height: 2),
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
                // Status chip
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPresent
                        ? Colors.green.withValues(alpha: 0.12)
                        : Colors.redAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPresent ? Icons.check_circle : Icons.cancel,
                        size: 18,
                        color: isPresent ? Colors.green : Colors.redAccent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isPresent ? 'Présent' : 'Absent',
                        style: TextStyle(
                          fontFamily: TeacherTheme.fontName,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isPresent ? Colors.green : Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
