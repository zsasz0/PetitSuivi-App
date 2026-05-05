import 'package:flutter/material.dart';
import 'package:newv/views/themes/theme_colors.dart';
import 'package:newv/views/teacher/profile/themes/teacher_profile_theme.dart';

class ProfileInfoCard extends StatelessWidget {
  final String email;
  final String phone;
  final String address;
  final int yearsOfTeaching;
  final int age;

  const ProfileInfoCard({
    super.key,
    required this.email,
    required this.phone,
    required this.address,
    required this.yearsOfTeaching,
    required this.age,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: TeacherProfileTheme.surfaceCard(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildInfoRow(Icons.email, 'Email', email),
              Divider(color: ThemeColors.glassBorderSubtle),
              _buildInfoRow(Icons.phone, 'Téléphone', phone),
              Divider(color: ThemeColors.glassBorderSubtle),
              _buildInfoRow(Icons.location_on, 'Adresse', address),
              Divider(color: ThemeColors.glassBorderSubtle),
              _buildInfoRow(
                Icons.work_history,
                'Années d\'enseignement',
                yearsOfTeaching > 0 ? '$yearsOfTeaching ans' : '-',
              ),
              Divider(color: ThemeColors.glassBorderSubtle),
              _buildInfoRow(
                Icons.cake,
                'Âge',
                age > 0 ? '$age ans' : '-',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: TeacherProfileTheme.primaryColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TeacherProfileTheme.labelStyle,
                ),
                Text(
                  value,
                  style: TeacherProfileTheme.valueStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
