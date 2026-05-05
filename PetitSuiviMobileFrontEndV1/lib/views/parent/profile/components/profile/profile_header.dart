import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/views/parent/profile/themes/profile_theme.dart';

class ProfileHeader extends StatelessWidget {
  final AuthSession session;

  const ProfileHeader({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ProfileTheme.glassBackgroundSubtle,
            border: Border.all(color: ProfileTheme.glassBorder),
            boxShadow: [
              BoxShadow(
                color: ProfileTheme.tealAccent.withValues(alpha: 0.2),
                blurRadius: 20,
              ),
            ],
          ),
          child: Icon(
            Icons.person_outline_rounded,
            size: 40,
            color: ProfileTheme.tealAccent,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          session.fullName,
          style: TextStyle(
            fontFamily: AppTheme.fontName,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: ProfileTheme.lightText,
          ),
        ),
      ],
    );
  }
}
