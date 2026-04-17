import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/views/themes/theme_manager.dart';

// File: start_button.dart
// Purpose: High-visibility button to finish the intro and enter the app.
// Usage: Final action button in IntroductionAnimationScreen.
// API Usage: No.
// Dependencies: None.

/// A stylized action button used to conclude the introductory walkthrough.
class StartButton extends StatelessWidget {
  /// Callback triggered when the button is pressed.
  final VoidCallback onPressed;

  static Color get _tealAccent => ThemeManager.instance.isLightMode ? const Color(0xFF009688) : const Color(0xFF4CCEAC);
  static Color get _baseDark => ThemeManager.instance.isLightMode ? const Color(0xFFF0F2F5) : const Color(0xFF141B2D);

  /// Creates a [StartButton] with a required [onPressed] callback.
  const StartButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return SizedBox(
      key: const ValueKey('startButton'),
      width: double.infinity,
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          color: _tealAccent,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: onPressed,
            child: Center(
              child: Text(
                'Commencer',
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: _baseDark,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
