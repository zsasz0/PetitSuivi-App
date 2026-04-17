import 'package:flutter/material.dart';
import 'package:newv/views/teacher/profile/themes/teacher_profile_theme.dart';

class ProfileStatsRow extends StatelessWidget {
  final bool isLoading;
  final int classCount;
  final int enfantCount;

  const ProfileStatsRow({
    super.key,
    required this.isLoading,
    required this.classCount,
    required this.enfantCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              isLoading ? '-' : '$classCount',
              'Classes',
              Icons.class_,
              TeacherProfileTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              isLoading ? '-' : '$enfantCount',
              'Enfants',
              Icons.child_care,
              TeacherProfileTheme.secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: TeacherProfileTheme.fontName,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: TeacherProfileTheme.fontName,
              fontSize: 14,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
