import 'package:flutter/material.dart';
import 'package:newv/views/teacher/notifications/themes/teacher_notifications_theme.dart';

class EmptyNotifications extends StatelessWidget {
  const EmptyNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 48,
            color: TeacherNotificationsTheme.mutedText.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Aucune notification.',
            style: TeacherNotificationsTheme.emptyStateStyle,
          ),
        ],
      ),
    );
  }
}
