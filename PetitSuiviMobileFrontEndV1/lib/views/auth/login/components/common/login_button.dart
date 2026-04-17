import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/views/themes/theme_manager.dart';

// File: login_button.dart
// Purpose: Primary action button for the login process.
// Usage: Submit button in LoginPage.
// API Usage: No.
// Dependencies: None.

/// A styled large button used to trigger login authentication.
class LoginButton extends StatelessWidget {
  final VoidCallback onPressed;

  static Color get _tealAccent => ThemeManager.instance.isLightMode ? const Color(0xFF009688) : const Color(0xFF4CCEAC);
  static Color get _baseDark => ThemeManager.instance.isLightMode ? const Color(0xFFF0F2F5) : const Color(0xFF141B2D);

  const LoginButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed, // call the login function
        style: ElevatedButton.styleFrom(
          backgroundColor: _tealAccent,
          foregroundColor: _baseDark,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Se connecter',
          style: TextStyle(
            fontFamily: AppTheme.fontName,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
