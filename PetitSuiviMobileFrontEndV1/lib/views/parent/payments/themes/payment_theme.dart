import 'package:flutter/material.dart';
import 'package:newv/views/themes/theme_manager.dart';

class PaymentTheme {
  static Color get baseDark => ThemeManager.instance.isLightMode
      ? const Color(0xFFF0F2F5)
      : const Color(0xFF141B2D);

  static Color get tealAccent => ThemeManager.instance.isLightMode
      ? const Color(0xFF009688)
      : const Color(0xFF4CCEAC);

  static Color get lightText => ThemeManager.instance.isLightMode
      ? const Color(0xFF212529)
      : const Color(0xFFF2F0F0);

  static Color get mutedText => ThemeManager.instance.isLightMode
      ? const Color(0xFF6C757D)
      : const Color(0xFFA1A4AB);

  static const List<Color> childColors = [
    Color(0xFF6870FA), // Indigo
    Color(0xFF4CCEAC), // Teal
    Color(0xFFFF94A3), // Light Pink/Coral
    Color(0xFFFFCC70), // Warm Yellow
    Color(0xFF8B93FF), // Soft Blue
    Color(0xFFFF7ED4), // Vibrant Pink
  ];

  static Color getChildColor(int index) {
    return childColors[index % childColors.length];
  }
}
