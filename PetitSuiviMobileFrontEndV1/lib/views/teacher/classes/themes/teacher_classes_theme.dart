import 'package:flutter/material.dart';
import 'package:newv/views/teacher/teacher_theme.dart';

class TeacherClassesTheme {
  // Use existing TeacherTheme values but centralized for the feature
  static Color get baseDark => TeacherTheme.baseDark;
  static Color get surfaceDark => TeacherTheme.surfaceDark;
  static Color get cardDark => TeacherTheme.cardDark;
  static Color get tealAccent => TeacherTheme.tealAccent;
  static Color get lightText => TeacherTheme.lightText;
  static Color get mutedText => TeacherTheme.mutedText;
  static Color get indigoAccent => TeacherTheme.indigoAccent;
  
  static const String fontName = TeacherTheme.fontName;

  static BoxDecoration surfaceCard({double borderRadius = 16}) {
    return TeacherTheme.surfaceCard(borderRadius: borderRadius);
  }

  static TextStyle appBarTitleStyle = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w700,
    fontSize: 20,
    color: lightText,
  );

  static TextStyle tabLabelStyle = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w600,
    fontSize: 14,
  );

  static TextStyle summaryLabelStyle = TextStyle(
    fontFamily: fontName,
    fontSize: 11,
    color: mutedText,
  );

  static TextStyle summaryValueStyle = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 15,
    color: lightText,
  );
}
