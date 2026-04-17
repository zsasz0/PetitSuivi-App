import 'package:flutter/material.dart';
import 'package:newv/views/themes/theme_manager.dart';

class HomeTheme {
  static Color get baseDark => ThemeManager.instance.isLightMode
      ? const Color(0xFFF0F2F5)
      : const Color(0xFF141B2D);

  static Color get surfaceDark => ThemeManager.instance.isLightMode
      ? const Color(0xFFFFFFFF)
      : const Color(0xFF1A2235);

  static Color get tealAccent => ThemeManager.instance.isLightMode
      ? const Color(0xFF009688)
      : const Color(0xFF4CCEAC);

  static Color get indigoAccent => ThemeManager.instance.isLightMode
      ? const Color(0xFF3F51B5)
      : const Color(0xFF6870FA);

  static Color get mutedText => ThemeManager.instance.isLightMode
      ? const Color(0xFF6C757D)
      : const Color(0xFFA1A4AB);
}
