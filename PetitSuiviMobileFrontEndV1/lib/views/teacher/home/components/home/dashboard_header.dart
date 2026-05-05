import 'package:flutter/material.dart';
import 'package:newv/views/teacher/home/themes/home_theme.dart';
import 'package:newv/views/teacher/teacher_theme.dart';

// File: dashboard_header.dart
// Purpose: Displays the 'Tableau de Bord' title at the top of the teacher dashboard.

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'Tableau de Bord',
        style: TextStyle(
          fontFamily: TeacherTheme.fontName,
          fontWeight: FontWeight.w700,
          fontSize: 22,
          letterSpacing: 1.2,
          color: HomeTheme.lightText,
        ),
      ),
    );
  }
}
