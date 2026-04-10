import 'package:provider/provider.dart';
import 'package:newv/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:newv/views/teacher/teacher_theme.dart';
import '../classes/manage_classes_page.dart';
import 'package:newv/help_screen.dart';

/// File: teacher_dashboard_page.dart
/// Purpose: Primary navigation hub for Teacher users, providing quick access to classes, activities, and photos.
/// Usage: Main screen when a teacher logs in.
/// API Usage: No direct backend API is called from this view (navigation only).
/// Dependencies: TeacherTheme, ManageClassesPage, HelpScreen.

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
  // BUILD & UI METHODS
  // ===========================================================================
  
  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return Container(
      color: TeacherTheme.baseDark,
      child: ListView(
        padding: EdgeInsets.only(
          top:
              AppBar().preferredSize.height +
              MediaQuery.of(context).padding.top +
              24,
          bottom: 100 + MediaQuery.of(context).padding.bottom,
        ),
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildGrid(),
        ],
      ),
    );
  }

  /// Builds the top textual header of the dashboard.
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'Tableau de Bord',
        style: TextStyle(
          fontFamily: TeacherTheme.fontName,
          fontWeight: FontWeight.w700,
          fontSize: 22,
          letterSpacing: 1.2,
          color: TeacherTheme.lightText,
        ),
      ),
    );
  }

  /// Builds the 2-column grid displaying the main functional navigation cards.
  Widget _buildGrid() {
    // Each item maps to either a bottom tab index or a pushed page.
    final menuItems = [
      {
        'title': 'Gestion des Classes',
        'subtitle': 'Voir et gérer vos classes',
        'icon': Icons.class_,
        'color': TeacherTheme.tealAccent,
        'page': const ManageClassesPage(),
      },
      {
        'title': 'Annuaires Activités',
        'subtitle': 'Voir tout l\'année',
        'icon': Icons.calendar_today,
        'color': TeacherTheme.indigoAccent,
        'tabIndex': 1, // Bottom tab index for Activities
      },
      {
        'title': 'Notifications',
        'subtitle': 'Alertes et messages',
        'icon': Icons.notifications,
        'color': const Color(0xFFFF6B6B),
        'tabIndex': 3, // Bottom tab index for Notifications
      },
      {
        'title': 'Photos Parents',
        'subtitle': 'Envoyer des photos ciblées',
        'icon': Icons.photo_camera_outlined,
        'color': const Color(0xFFFFA726),
        'tabIndex': 2, // Bottom tab index for Photos
      },
      {
        'title': 'Aide & Contact',
        'subtitle': 'Support technique',
        'icon': Icons.help_outline,
        'color': const Color(0xFF29B6F6),
        'page': HelpScreen(),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.9,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return _buildGridItem(item, index, menuItems.length);
        },
      ),
    );
  }

  /// Builds an individual animated grid item card with click interactions.
  Widget _buildGridItem(Map<String, dynamic> item, int index, int totalItems) {
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Interval(
          (1 / totalItems) * index,
          1.0,
          curve: Curves.fastOutSlowIn,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return FadeTransition(
          opacity: animation,
          child: Transform(
            transform: Matrix4.translationValues(
              0.0,
              30 * (1.0 - animation.value),
              0.0,
            ),
            child: _buildCardContent(item),
          ),
        );
      },
    );
  }

  /// Builds the visual content and handles interactions for a single card.
  Widget _buildCardContent(Map<String, dynamic> item) {
    return Container(
      decoration: TeacherTheme.surfaceCard(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _handleCardTap(item),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCardIcon(item),
              const SizedBox(height: 16),
              _buildCardTitle(item),
              const SizedBox(height: 8),
              _buildCardSubtitle(item),
            ],
          ),
        ),
      ),
    );
  }

  /// Handles routing or tab switching when a card is tapped.
  void _handleCardTap(Map<String, dynamic> item) {
    final tabIndex = item['tabIndex'] as int?;
    if (tabIndex != null && widget.onTabSwitch != null) {
      // Switch bottom tab
      widget.onTabSwitch!(tabIndex);
    } else if (item['page'] != null) {
      // Push specific page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => item['page'] as Widget,
        ),
      );
    }
  }

  Widget _buildCardIcon(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: (item['color'] as Color).withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(16),
      child: Icon(
        item['icon'] as IconData,
        color: item['color'] as Color,
        size: 32,
      ),
    );
  }

  Widget _buildCardTitle(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        item['title'] as String,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: TeacherTheme.fontName,
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: TeacherTheme.lightText,
        ),
      ),
    );
  }

  Widget _buildCardSubtitle(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        item['subtitle'] as String,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: TeacherTheme.fontName,
          fontWeight: FontWeight.w400,
          fontSize: 12,
          color: TeacherTheme.mutedText,
        ),
      ),
    );
  }
}
