import 'package:flutter/material.dart';
import 'package:newv/views/themes/theme_manager.dart';

class ChildTrackingTheme {
  static bool get isLight => ThemeManager.instance.isLightMode;

  static Color get baseDark => isLight
      ? const Color(0xFFF0F2F5)
      : const Color(0xFF141B2D);

  static Color get tealAccent => isLight
      ? const Color(0xFF009688)
      : const Color(0xFF4CCEAC);

  static Color get indigoAccent => isLight
      ? const Color(0xFF3F51B5)
      : const Color(0xFF6870FA);

  static Color get lightText => isLight
      ? const Color(0xFF212529)
      : const Color(0xFFF2F0F0);

  static Color get mutedText => isLight
      ? const Color(0xFF6C757D)
      : const Color(0xFFA1A4AB);

  // Alert colors from child_details_page
  static Color alertTypeColor(String alertType) {
    switch (alertType) {
      case 'Humeur':
        return const Color(0xFFFFA726);
      case 'Isolement':
        return const Color(0xFF7E57C2);
      case 'Pleurs':
        return const Color(0xFF42A5F5);
      case 'Agressivité':
        return const Color(0xFFEF5350);
      default:
        return const Color(0xFF78909C);
    }
  }
}
