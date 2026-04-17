import 'package:flutter/material.dart';
import 'package:newv/views/teacher/teacher_theme.dart';

// File: home_theme.dart
// Purpose: Feature-specific color aliases for the Teacher Home/Dashboard view.
//          Delegates to global TeacherTheme; add overrides here if needed.

class HomeTheme {
  HomeTheme._();

  /// Card accent for the Notifications tile.
  static const Color notificationsAccent = Color(0xFFFF6B6B);

  /// Card accent for the Photos tile.
  static const Color photosAccent = Color(0xFFFFA726);

  /// Card accent for the Help tile.
  static const Color helpAccent = Color(0xFF29B6F6);

  // Re-exports for convenience inside home components.
  static Color get baseDark => TeacherTheme.baseDark;
  static Color get lightText => TeacherTheme.lightText;
  static Color get mutedText => TeacherTheme.mutedText;
  static Color get tealAccent => TeacherTheme.tealAccent;
  static Color get indigoAccent => TeacherTheme.indigoAccent;
}
