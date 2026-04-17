import 'package:flutter/material.dart';
import 'package:newv/views/themes/theme_colors.dart';
import 'package:newv/views/themes/theme_manager.dart';

class RegisterTheme {
  static Color get baseDark => ThemeColors.baseDark;

  static Color get lightText => ThemeColors.textPrimary;

  static Color get mutedText => ThemeColors.textSecondary;

  static Color get tealAccent => ThemeManager.instance.isLightMode
      ? const Color(0xFF009688)
      : const Color(0xFF4CCEAC);

  static Color get glassBackground => ThemeColors.glassBackground;

  static Color get glassBorder => ThemeColors.glassBorder;

  static const Color accentColor = Color(0xFF6C63FF);
}
