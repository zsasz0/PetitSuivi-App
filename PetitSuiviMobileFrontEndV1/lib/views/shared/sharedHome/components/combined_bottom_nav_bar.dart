import 'package:provider/provider.dart';
import 'package:newv/views/themes/theme_manager.dart';
import 'package:newv/views/themes/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/views/teacher/teacher_theme.dart';

// File: combined_bottom_nav_bar.dart
// Purpose: Adaptive bottom navigation bar for Teachers and Parents.
// Usage: Displayed at the footer of CombinedHomeScreen.
// API Usage: No.
// Dependencies: TeacherTheme, AppTheme.

/// A unified bottom navigation bar that switches its items based on [userRole].
class CombinedBottomNavBar extends StatelessWidget {
  final int userRole;
  final int unreadCount;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CombinedBottomNavBar({
    super.key,
    required this.userRole,
    required this.unreadCount,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    if (userRole == 1) {
      return Container(
        decoration: BoxDecoration(
          color: TeacherTheme.surfaceDark,
          border: Border(
            top: BorderSide(color: ThemeColors.glassBorder, width: 1),
          ),
        ),
        child: Theme(
          data: Theme.of(
            context,
          ).copyWith(canvasColor: TeacherTheme.surfaceDark),
          child: BottomNavigationBar(
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Accueil',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_outlined),
                activeIcon: Icon(Icons.calendar_today),
                label: 'Activités',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.photo_camera_outlined),
                activeIcon: Icon(Icons.photo_camera),
                label: 'Photos',
              ),
              // notifications tab
              BottomNavigationBarItem(
                icon: Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text(
                    '$unreadCount',
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                  backgroundColor: Colors.redAccent,
                  child: const Icon(Icons.notifications_none),
                ),
                activeIcon: Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text(
                    '$unreadCount',
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                  backgroundColor: Colors.redAccent,
                  child: const Icon(Icons.notifications),
                ),
                label: 'Alertes',
              ),
              // profile tab
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
            currentIndex: currentIndex,
            selectedItemColor: TeacherTheme.tealAccent,
            unselectedItemColor: TeacherTheme.mutedText.withValues(alpha: 0.6),
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            backgroundColor: TeacherTheme.surfaceDark,
            elevation: 16,
            selectedFontSize: 12,
            unselectedFontSize: 11,
            selectedLabelStyle: const TextStyle(
              fontFamily: TeacherTheme.fontName,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: TeacherTheme.fontName,
              fontWeight: FontWeight.w500,
            ),
            onTap: onTap,
          ),
        ),
      );
    } else {
      // Parent section - use theme-aware colors from TeacherTheme
      return Container(
        decoration: BoxDecoration(
          color: TeacherTheme.surfaceDark,
          border: Border(
            top: BorderSide(color: ThemeColors.glassBorder, width: 1),
          ),
        ),
        child: Theme(
          data: Theme.of(
            context,
          ).copyWith(canvasColor: TeacherTheme.surfaceDark),
          child: BottomNavigationBar(
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Accueil',
              ),
              BottomNavigationBarItem(
                icon: Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text(
                    '$unreadCount',
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                  backgroundColor: Colors.redAccent,
                  child: const Icon(Icons.notifications_none),
                ),
                activeIcon: Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text(
                    '$unreadCount',
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                  backgroundColor: Colors.redAccent,
                  child: const Icon(Icons.notifications),
                ),
                label: 'Alertes',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.payment_outlined),
                activeIcon: Icon(Icons.payment),
                label: 'Paiements',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.photo_library_outlined),
                activeIcon: Icon(Icons.photo_library),
                label: 'Photos',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
            currentIndex: currentIndex,
            selectedItemColor: TeacherTheme.tealAccent,
            unselectedItemColor: TeacherTheme.mutedText.withValues(alpha: 0.6),
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            backgroundColor: TeacherTheme.surfaceDark,
            elevation: 16,
            selectedFontSize: 12,
            unselectedFontSize: 11,
            selectedLabelStyle: const TextStyle(
              fontFamily: AppTheme.fontName,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: AppTheme.fontName,
              fontWeight: FontWeight.w500,
            ),
            onTap: onTap,
          ),
        ),
      );
    }
  }
}
