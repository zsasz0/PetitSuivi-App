import 'package:flutter/material.dart';
import 'package:newv/views/teacher/notifications/themes/teacher_notifications_theme.dart';

class UnreadBadge extends StatelessWidget {
  final int count;

  const UnreadBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: TeacherNotificationsTheme.unreadBadgeDecoration,
            child: Text(
              '$count non lue(s)',
              style: TeacherNotificationsTheme.unreadBadgeStyle,
            ),
          ),
        ],
      ),
    );
  }
}
