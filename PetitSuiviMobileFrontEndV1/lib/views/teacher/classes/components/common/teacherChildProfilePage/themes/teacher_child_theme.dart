import 'package:flutter/material.dart';
import 'package:newv/views/teacher/teacher_theme.dart';

class TeacherChildTheme {
  // Common Colors
  static const Color enCoursColor = Color(0xFFFFA726);
  static const Color acquiseColor = Color(0xFF00C853);
  static const Color aRenforcerColor = Color(0xFFEF5350);
  
  static const Color aiSummaryPurple = Color(0xFF8B5CF6);
  static const Color dietaryTeal = Color(0xFF4CCEAC);
  static const Color healthBlue = Color(0xFF42A5F5);

  static const Color activityBlue = Color(0xFF5C6BC0);
  static const Color criteriaTeal = Color(0xFF26A69A);

  // Alert Types Colors
  static const Color humeurColor = Color(0xFFFFA726);
  static const Color isolementColor = Color(0xFF7E57C2);
  static const Color pleursColor = Color(0xFF42A5F5);
  static const Color agressiviteColor = Color(0xFFEF5350);
  static const Color autreColor = Color(0xFF78909C);

  // Styles
  static TextStyle sectionTitleStyle = TextStyle(
    fontFamily: TeacherTheme.fontName,
    fontWeight: FontWeight.bold,
    fontSize: 18,
    color: TeacherTheme.lightText,
  );

  static TextStyle sectionSubtitleStyle = TextStyle(
    fontFamily: TeacherTheme.fontName,
    fontSize: 12,
    color: TeacherTheme.mutedText,
  );

  static BoxDecoration signalBannerDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Colors.redAccent.withValues(alpha: 0.12),
        Colors.orange.withValues(alpha: 0.08),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(14),
    border: Border.all(
      color: Colors.redAccent.withValues(alpha: 0.3),
    ),
  );

  static BoxDecoration aiCardDecoration(Color color) => BoxDecoration(
    color: color.withValues(alpha: 0.08),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: color.withValues(alpha: 0.2),
    ),
  );
}
