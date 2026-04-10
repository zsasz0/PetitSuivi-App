import 'package:flutter/material.dart';
import 'theme_manager.dart';

/// Defines the global visual theme and typography for the SmartKids application.
class AppTheme {
  AppTheme._();

  static bool get _isLight => ThemeManager.instance.isLightMode;

  // Core color palette
  static Color get notWhite => _isLight ? const Color(0xFFEDF0F2) : const Color(0xFF1E2124);
  static Color get nearlyWhite => _isLight ? const Color(0xFFFEFEFE) : const Color(0xFF181A1B);
  static Color get white => _isLight ? const Color(0xFFFFFFFF) : const Color(0xFF121212);
  static Color get nearlyBlack => _isLight ? const Color(0xFF213333) : const Color(0xFFE0E6ED);
  static Color get grey => _isLight ? const Color(0xFF3A5160) : const Color(0xFF8B9EB0);
  static Color get darkGrey => _isLight ? const Color(0xFF313A44) : const Color(0xFFA1AFBD);

  // Text colors
  static Color get darkText => _isLight ? const Color(0xFF253840) : const Color(0xFFE8ECEF);
  static Color get darkerText => _isLight ? const Color(0xFF17262A) : const Color(0xFFFFFFFF);
  static Color get lightText => _isLight ? const Color(0xFF4A6572) : const Color(0xFFAABBD0);
  static Color get deactivatedText => _isLight ? const Color(0xFF767676) : const Color(0xFF767676);

  // UI Component colors
  static Color get dismissibleBackground => _isLight ? const Color(0xFF364A54) : const Color(0xFF364A54);
  static Color get chipBackground => _isLight ? const Color(0xFFEEF1F3) : const Color(0xFF2C3136);
  static Color get spacer => _isLight ? const Color(0xFFF2F2F2) : const Color(0xFF282B30);

  /// The primary font used across the application.
  static const String fontName = 'WorkSans';

  static Color get background => _isLight ? const Color(0xFFF2F3F8) : const Color(0xFF14171A);
  static Color get nearlyDarkBlue => _isLight ? const Color(0xFF2633C5) : const Color(0xFF7A8EFF);

  /// The global [TextTheme] mapped to specific SmartKids style tokens.
  static TextTheme get textTheme => TextTheme(
    headlineMedium: display1,
    headlineSmall: headline,
    titleLarge: title,
    titleSmall: subtitle,
    bodyMedium: body2,
    bodyLarge: body1,
    bodySmall: caption,
  );

  static TextStyle get display1 => TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 36,
    letterSpacing: 0.4,
    height: 0.9,
    color: darkerText,
  );

  static TextStyle get headline => TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 24,
    letterSpacing: 0.27,
    color: darkerText,
  );

  static TextStyle get title => TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 16,
    letterSpacing: 0.18,
    color: darkerText,
  );

  static TextStyle get subtitle => TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: -0.04,
    color: darkText,
  );

  static TextStyle get body2 => TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: 0.2,
    color: darkText,
  );

  static TextStyle get body1 => TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    letterSpacing: -0.05,
    color: darkText,
  );

  static TextStyle get caption => TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    letterSpacing: 0.2,
    color: lightText,
  );
}
