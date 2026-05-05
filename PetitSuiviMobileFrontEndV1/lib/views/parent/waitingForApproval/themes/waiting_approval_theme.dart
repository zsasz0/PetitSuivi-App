import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';

/// Centralized style definitions for the Waiting Approval feature.
class WaitingApprovalTheme {
  // Backgrounds
  static Color get backgroundColor => AppTheme.background;
  static Color get cardColor => AppTheme.white;
  
  // Text Colors
  static Color get primaryTextColor => AppTheme.darkerText;
  static Color get secondaryTextColor => AppTheme.darkText;
  static Color get tertiaryTextColor => AppTheme.grey;
  
  // Action Colors
  static Color get primaryActionColor => AppTheme.nearlyDarkBlue;
  static Color get statusPendingColor => Colors.orange;
  
  // Style properties
  static double get cardRadius => 16.0;
  static double get largeCardRadius => 18.0;
  
  static TextStyle get titleStyle => TextStyle(
    fontFamily: AppTheme.fontName,
    fontWeight: FontWeight.bold,
    color: primaryTextColor,
    fontSize: 20,
  );
  
  static TextStyle get cardTitleStyle => TextStyle(
    fontFamily: AppTheme.fontName,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: primaryTextColor,
  );
  
  static TextStyle get statusTitleStyle => TextStyle(
    fontFamily: AppTheme.fontName,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: primaryTextColor,
  );
  
  static TextStyle get bodyStyle => TextStyle(
    fontFamily: AppTheme.fontName,
    fontSize: 14,
    color: tertiaryTextColor,
    height: 1.35,
  );
  
  static TextStyle get stepStyle => TextStyle(
    fontFamily: AppTheme.fontName,
    fontSize: 13,
    color: secondaryTextColor,
    height: 1.35,
  );
  
  static TextStyle get buttonStyle => TextStyle(
    fontFamily: AppTheme.fontName,
    fontWeight: FontWeight.w600,
  );
}
