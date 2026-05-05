import 'package:flutter/material.dart';
import 'package:newv/views/teacher/classes/manage_classes_page.dart';
import 'package:newv/views/shared/support/support_page.dart';

// File: home_controller.dart
// Purpose: Bridges UI events (card taps) to navigation/routing logic for the Teacher Dashboard.
//          No backend API calls are needed; navigation is the sole concern here.

class HomeController {
  HomeController._();

  /// Handles a dashboard card tap.
  ///
  /// If the card carries a [tabIndex], the [onTabSwitch] callback is invoked
  /// to switch the bottom navigation bar. Otherwise the associated page is
  /// pushed onto the navigator stack.
  static void handleCardTap({
    required BuildContext context,
    required Map<String, dynamic> item,
    required void Function(int)? onTabSwitch,
  }) {
    final tabIndex = item['tabIndex'] as int?;
    if (tabIndex != null && onTabSwitch != null) {
      onTabSwitch(tabIndex);
    } else if (item['page'] != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => item['page'] as Widget),
      );
    }
  }

  /// Returns the list of dashboard menu items.
  ///
  /// Using a factory method lets the controller (not the UI) own the data.
  static List<Map<String, dynamic>> buildMenuItems() {
    return [
      {
        'title': 'Gestion des Classes',
        'subtitle': 'Voir et gérer vos classes',
        'icon': Icons.class_,
        'color': const Color(0xFF4CCEAC), // resolved at runtime via HomeTheme in the widget
        'colorKey': 'teal',
        'page': const ManageClassesPage(),
      },
      {
        'title': 'Annuaires Activités',
        'subtitle': 'Voir tout l\'année',
        'icon': Icons.calendar_today,
        'colorKey': 'indigo',
        'tabIndex': 1,
      },
      {
        'title': 'Notifications',
        'subtitle': 'Alertes et messages',
        'icon': Icons.notifications,
        'color': const Color(0xFFFF6B6B),
        'colorKey': 'notifications',
        'tabIndex': 3,
      },
      {
        'title': 'Photos Parents',
        'subtitle': 'Envoyer des photos ciblées',
        'icon': Icons.photo_camera_outlined,
        'color': const Color(0xFFFFA726),
        'colorKey': 'photos',
        'tabIndex': 2,
      },
      {
        'title': 'Aide & Contact',
        'subtitle': 'Support technique',
        'icon': Icons.help_outline,
        'color': const Color(0xFF29B6F6),
        'colorKey': 'help',
        'page': const SupportPage(),
      },
    ];
  }
}
