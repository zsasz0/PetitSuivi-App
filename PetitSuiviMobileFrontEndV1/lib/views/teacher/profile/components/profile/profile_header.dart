import 'package:flutter/material.dart';
import 'package:newv/views/teacher/profile/themes/teacher_profile_theme.dart';

class ProfileHeader extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String fullName;

  const ProfileHeader({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.fullName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: TeacherProfileTheme.primaryColor.withValues(alpha: 0.5),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: TeacherProfileTheme.primaryColor.withValues(alpha: 0.2),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 45,
            backgroundColor: TeacherProfileTheme.surfaceColor,
            child: Text(
              '${firstName.isNotEmpty ? firstName[0] : 'U'}${lastName.isNotEmpty ? lastName[0] : ''}',
              style: TextStyle(
                fontFamily: TeacherProfileTheme.fontName,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: TeacherProfileTheme.primaryColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          fullName.isNotEmpty ? fullName : 'Enseignant',
          style: TeacherProfileTheme.headerNameStyle,
        ),
        Text(
          'Enseignant',
          style: TeacherProfileTheme.headerRoleStyle,
        ),
      ],
    );
  }
}
