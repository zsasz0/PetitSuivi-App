import 'package:flutter/material.dart';
import 'package:newv/models/teacher_models.dart' as mock;
import 'package:newv/views/teacher/teacher_theme.dart';

class CompetencyChildCard extends StatelessWidget {
  final mock.MockChild child;
  final VoidCallback onTap;

  const CompetencyChildCard({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: TeacherTheme.surfaceCard(borderRadius: 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8B500).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.child_care,
                    color: Color(0xFFF8B500),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
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
                      const SizedBox(height: 4),
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
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: TeacherTheme.mutedText.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
