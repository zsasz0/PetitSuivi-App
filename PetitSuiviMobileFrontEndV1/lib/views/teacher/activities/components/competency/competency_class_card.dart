import 'package:flutter/material.dart';
import 'package:newv/models/teacher_models.dart' as mock;
import 'package:newv/views/teacher/teacher_theme.dart';
import 'package:newv/views/teacher/activities/themes/activities_theme.dart';

class CompetencyClassCard extends StatelessWidget {
  final mock.ClassRoom cls;
  final VoidCallback onTap;

  const CompetencyClassCard({
    super.key,
    required this.cls,
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
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ActivitiesTheme.primaryBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.class_,
                    color: ActivitiesTheme.primaryBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cls.name,
                        style: TextStyle(
                          fontFamily: TeacherTheme.fontName,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: TeacherTheme.lightText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${cls.children.length} enfants',
                        style: TextStyle(
                          fontFamily: TeacherTheme.fontName,
                          fontSize: 13,
                          color: TeacherTheme.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
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
