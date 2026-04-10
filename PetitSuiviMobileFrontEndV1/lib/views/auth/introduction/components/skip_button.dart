import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:newv/app_theme.dart';
import 'package:newv/theme_manager.dart';

// File: skip_button.dart
// Purpose: Simple text button to skip the introduction.
// Usage: Navigation footer in IntroductionAnimationScreen.
// API Usage: No.
// Dependencies: None.

/// A stateless button widget used to skip the introductory walkthrough.
class SkipButton extends StatelessWidget {
  /// Callback triggered when the button is pressed.
  final VoidCallback onPressed;

  static Color get _mutedText => ThemeManager.instance.isLightMode ? const Color(0xFF6C757D) : const Color(0xFFA1A4AB);

  /// Creates a [SkipButton] with a required [onPressed] callback.
  const SkipButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return Row(
      key: const ValueKey('skipButton'),
      children: [
        Expanded(
          child: TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              'Passer',
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                fontSize: 16,
                color: _mutedText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
