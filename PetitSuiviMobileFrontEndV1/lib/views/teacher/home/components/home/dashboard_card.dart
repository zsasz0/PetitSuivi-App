import 'package:flutter/material.dart';
import 'package:newv/views/teacher/home/themes/home_theme.dart';
import 'package:newv/views/teacher/teacher_theme.dart';

// File: dashboard_card.dart
// Purpose: An individual animated grid card for the teacher dashboard.
//          Accepts an item map and the shared AnimationController from the parent State.

class DashboardCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final int index;
  final int totalItems;
  final AnimationController animController;
  final VoidCallback onTap;

  const DashboardCard({
    super.key,
    required this.item,
    required this.index,
    required this.totalItems,
    required this.animController,
    required this.onTap,
  });

  /// Resolves the card accent color from the item map or a colorKey fallback.
  Color _resolveColor() {
    if (item['color'] != null) return item['color'] as Color;
    switch (item['colorKey'] as String?) {
      case 'teal':
        return HomeTheme.tealAccent;
      case 'indigo':
        return HomeTheme.indigoAccent;
      case 'notifications':
        return HomeTheme.notificationsAccent;
      case 'photos':
        return HomeTheme.photosAccent;
      case 'help':
        return HomeTheme.helpAccent;
      default:
        return HomeTheme.tealAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animController,
        curve: Interval(
          (1 / totalItems) * index,
          1.0,
          curve: Curves.fastOutSlowIn,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: animController,
      builder: (context, child) {
        return FadeTransition(
          opacity: animation,
          child: Transform(
            transform: Matrix4.translationValues(
              0.0,
              30 * (1.0 - animation.value),
              0.0,
            ),
            child: _buildCardContent(context),
          ),
        );
      },
    );
  }

  Widget _buildCardContent(BuildContext context) {
    final color = _resolveColor();
    return Container(
      decoration: TeacherTheme.surfaceCard(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIcon(color),
              const SizedBox(height: 16),
              _buildTitle(),
              const SizedBox(height: 8),
              _buildSubtitle(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(16),
      child: Icon(
        item['icon'] as IconData,
        color: color,
        size: 32,
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        item['title'] as String,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: TeacherTheme.fontName,
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: HomeTheme.lightText,
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        item['subtitle'] as String,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: TeacherTheme.fontName,
          fontWeight: FontWeight.w400,
          fontSize: 12,
          color: HomeTheme.mutedText,
        ),
      ),
    );
  }
}
