import 'package:flutter/material.dart';
import 'package:newv/views/parent/profile/themes/profile_theme.dart';
import 'package:newv/views/shared/components/profile_action_button.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onChangePassword;
  final VoidCallback onLogout;

  const ActionButtons({
    super.key,
    required this.onChangePassword,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileActionButton(
          icon: Icons.lock,
          text: 'Changer le mot de passe',
          color: ProfileTheme.tealAccent,
          onTap: onChangePassword,
        ),
        const SizedBox(height: 16),
        ProfileActionButton(
          icon: Icons.logout,
          text: 'Déconnexion',
          color: ProfileTheme.redAccent,
          onTap: onLogout,
        ),
      ],
    );
  }
}
