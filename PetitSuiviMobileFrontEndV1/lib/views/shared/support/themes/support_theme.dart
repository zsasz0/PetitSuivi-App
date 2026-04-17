import 'package:flutter/material.dart';
import 'package:newv/views/themes/theme_manager.dart';

class SupportTheme {
  static bool get _isLight => ThemeManager.instance.isLightMode;

  static Color get baseBackground =>
      _isLight ? const Color(0xFFF8F9FA) : const Color(0xFF0F172A);

  static Color get surfaceBackground =>
      _isLight ? const Color(0xFFFFFFFF) : const Color(0xFF1E293B);

  static Color get tealAccent =>
      _isLight ? const Color(0xFF0D9488) : const Color(0xFF2DD4BF);

  static Color get indigoAccent =>
      _isLight ? const Color(0xFF4F46E5) : const Color(0xFF818CF8);

  static Color get primaryText =>
      _isLight ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);

  static Color get mutedText =>
      _isLight ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
      
  static Color get whatsappColor => const Color(0xFF10B981);
  static Color get facebookColor => const Color(0xFF3B82F6);
  static Color get instagramColor => const Color(0xFFEC4899);
}
