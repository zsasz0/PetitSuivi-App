import 'package:flutter/material.dart';
import '../../theme_manager.dart';
import '../../theme_colors.dart';

// File: teacher_theme.dart
// Purpose: Centralized theme constants and UI helpers for the teacher interface.

class TeacherTheme {
  TeacherTheme._();

  static bool get _isLight => ThemeManager.instance.isLightMode;

  // ── Core Palette ──────────────────────────────────────────────────────────
  static Color get baseDark =>
      _isLight ? const Color(0xFFF0F2F5) : const Color(0xFF141B2D);
  static Color get surfaceDark =>
      _isLight ? const Color(0xFFFFFFFF) : const Color(0xFF1A2235);
  static Color get cardDark =>
      _isLight ? const Color(0xFFF9F9FB) : const Color(0xFF1F293D);

  // ── Accents ───────────────────────────────────────────────────────────────
  static Color get tealAccent =>
      _isLight ? const Color(0xFF009688) : const Color(0xFF4CCEAC);
  static Color get indigoAccent =>
      _isLight ? const Color(0xFF3F51B5) : const Color(0xFF6870FA);

  // ── Text ───────────────────────────────────────────────────────────────────
  static Color get lightText =>
      _isLight ? const Color(0xFF212529) : const Color(0xFFF2F0F0);
  static Color get mutedText =>
      _isLight ? const Color(0xFF6C757D) : const Color(0xFFA1A4AB);

  // ── Helpers ────────────────────────────────────────────────────────────────
  static const String fontName = 'WorkSans';

  /// Glassmorphism card decoration used across teacher pages.
  static BoxDecoration glassCard({double borderRadius = 16, Color? color}) {
    return BoxDecoration(
      color: color ?? ThemeColors.glassBackgroundSubtle,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: ThemeColors.glassBorderSubtle),
    );
  }

  /// Surface card decoration – a solid dark card.
  static BoxDecoration surfaceCard({double borderRadius = 16, Color? color}) {
    return BoxDecoration(
      color: color ?? surfaceDark,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: ThemeColors.glassBorderSubtle),
      boxShadow: [
        BoxShadow(
          color: ThemeColors.shadow,
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
