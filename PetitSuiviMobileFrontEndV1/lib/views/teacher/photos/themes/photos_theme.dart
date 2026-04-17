import 'package:flutter/material.dart';
import 'package:newv/views/teacher/teacher_theme.dart';

class PhotosTheme {
  static Color get primary => TeacherTheme.tealAccent;
  static Color get background => TeacherTheme.baseDark;
  static Color get surface => TeacherTheme.surfaceDark;
  static Color get card => TeacherTheme.cardDark;
  static Color get text => TeacherTheme.lightText;
  static Color get textMuted => TeacherTheme.mutedText;
  static Color get accentRed => Colors.redAccent;
  static Color get accentGreen => Colors.green;
  static Color get accentIndigo => TeacherTheme.indigoAccent;

  static TextStyle get titleStyle => TextStyle(
        color: text,
        fontFamily: TeacherTheme.fontName,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get labelStyle => TextStyle(
        color: textMuted,
        fontFamily: TeacherTheme.fontName,
      );

  static BoxDecoration sectionDecoration = TeacherTheme.surfaceCard(borderRadius: 14);
}
