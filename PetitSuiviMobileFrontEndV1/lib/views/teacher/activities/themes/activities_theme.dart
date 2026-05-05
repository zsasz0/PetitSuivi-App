import 'package:flutter/material.dart';
import 'package:newv/views/teacher/teacher_theme.dart';
import 'package:newv/views/themes/theme_manager.dart';

class ActivitiesTheme {
  // Common Colors
  static Color get primaryBlue => TeacherTheme.tealAccent;
  static Color get surfaceDark => TeacherTheme.surfaceDark;
  
  static Color get mutedBlue => ThemeManager.instance.isLightMode
      ? const Color(0xFFE0E4EB)
      : const Color(0xFF2B364E);

  static Color get glassBorder => const Color(0x33FFFFFF);
  
  static Color get statusEnCours => Colors.blue;
  static Color get statusApproved => Colors.green;
  static Color get statusRejected => Colors.red;
  static Color get statusExecuted => Colors.green;
  static Color get statusNotExecuted => Colors.red[700]!;

  // Month Icons
  static const List<IconData> monthIcons = [
    Icons.ac_unit,
    Icons.favorite,
    Icons.eco,
    Icons.local_florist,
    Icons.wb_sunny,
    Icons.beach_access,
    Icons.wb_sunny,
    Icons.park,
    Icons.school,
    Icons.park,
    Icons.cloud,
    Icons.star,
  ];

  // Month Names (French)
  static const List<String> monthsFr = [
    'Janvier',
    'Février',
    'Mars',
    'Avril',
    'Mai',
    'Juin',
    'Juillet',
    'Août',
    'Septembre',
    'Octobre',
    'Novembre',
    'Décembre',
  ];

  // Weekday Names (French)
  static const List<String> weekdaysFr = [
    'Lun',
    'Mar',
    'Mer',
    'Jeu',
    'Ven',
    'Sam',
    'Dim',
  ];
}
