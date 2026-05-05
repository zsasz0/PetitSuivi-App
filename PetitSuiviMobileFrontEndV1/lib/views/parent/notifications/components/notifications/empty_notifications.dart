import 'package:flutter/material.dart';
import 'package:newv/views/parent/notifications/themes/notification_theme.dart';

class EmptyNotifications extends StatelessWidget {
  const EmptyNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, color: NotificationTheme.lightText.withValues(alpha: 0.6), size: 64),
          const SizedBox(height: 16),
          Text(
            'Aucune notification.',
            style: TextStyle(
              color: NotificationTheme.lightText.withValues(alpha: 0.6),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
