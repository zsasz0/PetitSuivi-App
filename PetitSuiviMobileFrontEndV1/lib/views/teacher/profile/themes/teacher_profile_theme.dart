import 'package:flutter/material.dart';
import 'package:newv/views/teacher/teacher_theme.dart';

class TeacherProfileTheme {
  static Color get backgroundColor => TeacherTheme.baseDark;
  static Color get primaryColor => TeacherTheme.tealAccent;
  static Color get secondaryColor => TeacherTheme.indigoAccent;
  static Color get surfaceColor => TeacherTheme.surfaceDark;
  static Color get cardColor => TeacherTheme.cardDark;
  
  static Color get textColor => TeacherTheme.lightText;
  static Color get mutedTextColor => TeacherTheme.mutedText;
  
  static String get fontFamily => TeacherTheme.fontName;
  static String get fontName => TeacherTheme.fontName;

  static BoxDecoration surfaceCard({double borderRadius = 16}) {
    return TeacherTheme.surfaceCard(borderRadius: borderRadius);
  }

  static TextStyle titleStyle = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 20,
    color: textColor,
  );

  static TextStyle headerNameStyle = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 20,
    color: textColor,
  );

  static TextStyle headerRoleStyle = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: mutedTextColor,
  );

  static TextStyle labelStyle = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    color: mutedTextColor,
  );

  static TextStyle valueStyle = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: textColor,
  );
}
