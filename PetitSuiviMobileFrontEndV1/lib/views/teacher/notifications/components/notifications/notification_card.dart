import 'package:flutter/material.dart';
import 'package:newv/views/teacher/notifications/controllers/teacher_notifications_controller.dart';
import 'package:newv/views/teacher/notifications/themes/teacher_notifications_theme.dart';

class NotificationCard extends StatelessWidget {
  final CombinedNotification notification;
  final VoidCallback onTap;
  final VoidCallback onAction;
  final String timeAgo;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onAction,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = TeacherNotificationsTheme.colorForType(notification.type);
    final icon = TeacherNotificationsTheme.iconForType(notification.type);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      child: Container(
        decoration: TeacherNotificationsTheme.notificationCardDecoration(borderRadius: 14),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: typeColor,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  notification.title,
                  style: TextStyle(
                    fontFamily: 'Outfit', // Match TeacherTheme
                    fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                    fontSize: 16,
                    color: notification.isRead
                        ? TeacherNotificationsTheme.mutedText
                        : TeacherNotificationsTheme.lightText,
                  ),
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: typeColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: typeColor.withValues(alpha: 0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.message,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 13,
                    color: TeacherNotificationsTheme.mutedText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeAgo,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 11,
                    color: TeacherNotificationsTheme.mutedText.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
              ],
            ),
          ),
          trailing: notification.isRead
              ? null
              : IconButton(
                  icon: Icon(
                    notification.type == 'pickup' ? Icons.check_circle_outline : Icons.done,
                    color: TeacherNotificationsTheme.accentColor,
                  ),
                  onPressed: onAction,
                  tooltip: notification.type == 'pickup' ? 'Confirmer récupération' : 'Marquer comme lu',
                ),
        ),
      ),
    );
  }
}
