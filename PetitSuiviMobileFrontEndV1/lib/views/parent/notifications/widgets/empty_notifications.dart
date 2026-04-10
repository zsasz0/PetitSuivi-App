import 'package:flutter/material.dart';
import 'package:newv/theme_manager.dart';

// File: empty_notifications.dart
// Purpose: Display an empty state placeholder when the parent has no notifications.
// Usage: Used within ParentNotificationsPage.

/// Displays a placeholder layout with an icon letting the user know they are caught up.
class EmptyNotifications extends StatelessWidget {
  const EmptyNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = ThemeManager.instance.isLightMode;
    final mutedText = isLight ? const Color(0xFF6C757D) : const Color(0xFFA1A4AB);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, color: mutedText, size: 64),
          const SizedBox(height: 16),
          Text(
            'Aucune notification.',
            style: TextStyle(color: mutedText, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
