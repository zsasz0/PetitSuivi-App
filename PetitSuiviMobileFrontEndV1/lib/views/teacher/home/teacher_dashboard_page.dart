import 'package:provider/provider.dart';
import 'package:newv/views/themes/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:newv/views/teacher/home/themes/home_theme.dart';
import 'package:newv/views/teacher/home/components/home/dashboard_header.dart';
import 'package:newv/views/teacher/home/components/home/dashboard_grid.dart';

/// File: teacher_dashboard_page.dart
/// Purpose: Primary navigation hub for Teacher users, providing quick access to classes, activities, and photos.
/// Usage: Main screen when a teacher logs in.
/// API Usage: No direct backend API is called from this view (navigation only).
/// Dependencies: HomeTheme, HomeController, DashboardHeader, DashboardGrid.

/// A grid-based dashboard for teachers to navigate between their core responsibilities.
class TeacherDashboardPage extends StatefulWidget {
  /// Callback to switch the bottom navigation tab index.
  /// Options: Activités=1, Photos=2, Notifications=3, Profil=4
  final void Function(int tabIndex)? onTabSwitch;

  const TeacherDashboardPage({super.key, this.onTabSwitch});

  @override
  State<TeacherDashboardPage> createState() => _TeacherDashboardPageState();
}

class _TeacherDashboardPageState extends State<TeacherDashboardPage>
    with SingleTickerProviderStateMixin {

  // ===========================================================================
  // STATE VARIABLES & CONTROLLERS
  // AnimationController must live here to be properly disposed.
  // ===========================================================================

  late AnimationController _animController;

  // ===========================================================================
  // INIT & DISPOSE
  // ===========================================================================

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return Container(
      color: HomeTheme.baseDark,
      child: ListView(
        padding: EdgeInsets.only(
          top: AppBar().preferredSize.height +
              MediaQuery.of(context).padding.top +
              24,
          bottom: 100 + MediaQuery.of(context).padding.bottom,
        ),
        children: [
          const DashboardHeader(),
          const SizedBox(height: 16),
          DashboardGrid(
            animController: _animController,
            onTabSwitch: widget.onTabSwitch,
          ),
        ],
      ),
    );
  }
}
