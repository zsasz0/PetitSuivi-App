import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:newv/app_theme.dart';
import 'package:newv/services/notification_service.dart';
import 'package:newv/theme_manager.dart';
import 'package:newv/theme_colors.dart';
import 'package:newv/views/shared/event_detail_page.dart';

// File: notification_card.dart
// Purpose: Displays a single notification item with dynamic styling based on its type.
// Usage: Used within ParentNotificationsPage.

/// A decorative card displaying a singular notification alert with an icon and time ago.
class NotificationCard extends StatelessWidget {
  final NotificationModel alert;
  final VoidCallback onMarkAsRead;

  const NotificationCard({
    super.key,
    required this.alert,
    required this.onMarkAsRead,
  });

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'payment':
        return Icons.account_balance_wallet_outlined;
      case 'signalement':
      case 'behavior':
        return Icons.psychology_alt_outlined;
      case 'event':
      case 'upcomingevent':
        return Icons.event_outlined;
      case 'pickup':
        return Icons.emoji_people_rounded;
      case 'photo':
        return Icons.photo_camera_outlined;
      default:
        return Icons.info_outline_rounded;
    }
  }

  Color _colorForType(String type) {
    final isLight = ThemeManager.instance.isLightMode;
    switch (type.toLowerCase()) {
      case 'payment':
        return const Color(0xFFF39C12); // Warning Orange/Gold
      case 'signalement':
      case 'behavior':
        return const Color(0xFFE74C3C); // Alert Red
      case 'event':
      case 'upcomingevent':
        return isLight
            ? const Color(0xFF009688)
            : const Color(0xFF4CCEAC); // Teal accent
      case 'pickup':
        return Colors.greenAccent;
      case 'photo':
        return const Color(0xFF9B59B6); // Purple for photos
      default:
        return isLight
            ? const Color(0xFF3F51B5)
            : const Color(0xFF6870FA); // Indigo accent
    }
  }

  String _labelForType(String type) {
    switch (type.toLowerCase()) {
      case 'payment':
        return 'Paiement';
      case 'signalement':
      case 'behavior':
        return 'Comportement';
      case 'photo':
        return 'Photo';
      case 'event':
      case 'upcomingevent':
        return 'Événement';
      default:
        return 'Info';
    }
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    return 'Il y a ${diff.inDays} j';
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _colorForType(alert.type);
    final isLight = ThemeManager.instance.isLightMode;
    final mutedText = isLight
        ? const Color(0xFF6C757D)
        : const Color(0xFFA1A4AB);
    final lightText = isLight
        ? const Color(0xFF212529)
        : const Color(0xFFF2F0F0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (!alert.isRead) onMarkAsRead();
              if (alert.type.toLowerCase() == 'event' ||
                  alert.type.toLowerCase() == 'upcomingevent') {
                Map<String, dynamic> parsedData = {};
                if (alert.data is Map) {
                  parsedData = Map<String, dynamic>.from(alert.data as Map);
                } else if (alert.data is String) {
                  try {
                    parsedData = jsonDecode(alert.data as String);
                  } catch (_) {}
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EventDetailPage(eventData: parsedData),
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: alert.isRead
                    ? ThemeColors.glassBackgroundSubtle
                    : typeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: alert.isRead
                      ? ThemeColors.glassBorderSubtle
                      : typeColor.withValues(alpha: 0.3),
                  width: alert.isRead ? 1.0 : 1.5,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: alert.isRead
                          ? ThemeColors.glassBorderSubtle
                          : typeColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _iconForType(alert.type),
                      color: alert.isRead ? mutedText : typeColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                alert.title,
                                style: TextStyle(
                                  fontFamily: AppTheme.fontName,
                                  fontSize: 16,
                                  fontWeight: alert.isRead
                                      ? FontWeight.w600
                                      : FontWeight.w800,
                                  color: alert.isRead ? mutedText : lightText,
                                ),
                              ),
                            ),
                            if (!alert.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(top: 6, left: 8),
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
                        const SizedBox(height: 6),
                        Text(
                          alert.message,
                          style: TextStyle(
                            fontFamily: AppTheme.fontName,
                            fontSize: 14,
                            color: alert.isRead
                                ? mutedText.withValues(alpha: 0.6)
                                : lightText.withValues(alpha: 0.9),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: alert.isRead
                                    ? Colors.transparent
                                    : typeColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: alert.isRead
                                      ? ThemeColors.glassBorder
                                      : Colors.transparent,
                                ),
                              ),
                              child: Text(
                                _labelForType(alert.type),
                                style: TextStyle(
                                  fontFamily: AppTheme.fontName,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: alert.isRead ? mutedText : typeColor,
                                ),
                              ),
                            ),
                            Text(
                              _timeAgo(alert.createdAt),
                              style: TextStyle(
                                fontFamily: AppTheme.fontName,
                                fontSize: 12,
                                color: mutedText.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
