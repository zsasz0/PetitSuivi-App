import 'package:flutter/material.dart';
import 'package:newv/views/teacher/teacher_theme.dart';

class TeacherNotificationsTheme {
  static Color get backgroundColor => TeacherTheme.baseDark;
  static Color get surfaceColor => TeacherTheme.surfaceDark;
  static Color get accentColor => TeacherTheme.tealAccent;
  static Color get indigoAccent => TeacherTheme.indigoAccent;
  static Color get lightText => TeacherTheme.lightText;
  static Color get mutedText => TeacherTheme.mutedText;

  static TextStyle get titleStyle => TextStyle(
        fontFamily: TeacherTheme.fontName,
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: lightText,
      );

  static TextStyle get emptyStateStyle => TextStyle(
        fontFamily: TeacherTheme.fontName,
        fontSize: 15,
        color: mutedText,
      );

  static TextStyle get unreadBadgeStyle => TextStyle(
        fontFamily: TeacherTheme.fontName,
        color: indigoAccent,
        fontWeight: FontWeight.bold,
        fontSize: 13,
      );

  static BoxDecoration get unreadBadgeDecoration => BoxDecoration(
        color: indigoAccent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: indigoAccent.withValues(alpha: 0.3),
        ),
      );

  static BoxDecoration notificationCardDecoration({required double borderRadius}) {
    return TeacherTheme.surfaceCard(borderRadius: borderRadius);
  }

  static Color colorForType(String type) {
    switch (type.toLowerCase()) {
      case 'pickup':
        return Colors.greenAccent;
      case 'signalement':
        return Colors.redAccent;
      case 'payment':
        return Colors.orangeAccent;
      case 'event':
      case 'upcomingevent':
        return Colors.purpleAccent;
      default:
        return indigoAccent;
    }
  }

  static IconData iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'pickup':
        return Icons.emoji_people_rounded;
      case 'signalement':
        return Icons.psychology_alt_outlined;
      case 'payment':
        return Icons.account_balance_wallet_outlined;
      case 'event':
      case 'upcomingevent':
        return Icons.event;
      default:
        return Icons.notifications;
    }
  }
}
