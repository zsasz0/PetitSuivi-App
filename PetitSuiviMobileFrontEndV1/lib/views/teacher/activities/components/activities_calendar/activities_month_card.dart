import 'package:flutter/material.dart';
import 'package:newv/views/teacher/teacher_theme.dart';
import 'package:newv/views/teacher/activities/themes/activities_theme.dart';

class ActivitiesMonthCard extends StatelessWidget {
  final int year;
  final int month;
  final bool isExpanded;
  final int activityCount;
  final VoidCallback onTap;
  final Widget child;

  const ActivitiesMonthCard({
    super.key,
    required this.year,
    required this.month,
    required this.isExpanded,
    required this.activityCount,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: TeacherTheme.surfaceCard(borderRadius: 16).copyWith(
        border: isExpanded
            ? Border.all(color: ActivitiesTheme.primaryBlue.withValues(alpha: 0.4), width: 1.5)
            : null,
      ),
      child: Column(
        children: [
          ListTile(
            onTap: onTap,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ActivitiesTheme.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                ActivitiesTheme.monthIcons[month - 1],
                color: ActivitiesTheme.primaryBlue,
                size: 20,
              ),
            ),
            title: Text(
              ActivitiesTheme.monthsFr[month - 1],
              style: TextStyle(
                fontFamily: TeacherTheme.fontName,
                fontWeight: FontWeight.bold,
                color: TeacherTheme.lightText,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (activityCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isExpanded ? ActivitiesTheme.primaryBlue : ActivitiesTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$activityCount act.',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isExpanded ? TeacherTheme.baseDark : TeacherTheme.mutedText,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: TeacherTheme.mutedText,
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: child,
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}
