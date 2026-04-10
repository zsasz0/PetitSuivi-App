import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:newv/theme_manager.dart';

// File: bottom_navigation.dart
// Purpose: Navigation controls for the multi-step registration flow.
// Usage: Footer in RegisterPage.
// API Usage: No.
// Dependencies: None.

/// A stateless navigation bar providing 'Back' and 'Next/Finish' buttons.
class BottomNavigation extends StatelessWidget {
  static Color get _baseDark => ThemeManager.instance.isLightMode ? const Color(0xFFF0F2F5) : const Color(0xFF141B2D);
  static Color get _tealAccent => ThemeManager.instance.isLightMode ? const Color(0xFF009688) : const Color(0xFF4CCEAC);
  static Color get _mutedText => ThemeManager.instance.isLightMode ? const Color(0xFF6C757D) : const Color(0xFFA1A4AB);

  final int currentStep;
  final bool isLoading;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const BottomNavigation({
    super.key,
    required this.currentStep,
    required this.isLoading,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: _baseDark,
        boxShadow: [
          BoxShadow(
            color: _baseDark.withValues(alpha: 0.8),
            offset: const Offset(0, -4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        // children contains back button and next button
        // if currentStep is 0, back button is not displayed
        // if currentStep is 1, next button is displayed
        children: [
          if (currentStep > 0)
            TextButton(
              // onBack contains the value of the previous step
              onPressed: onBack,
              child: Text(
                'Retour',
                style: TextStyle(
                  color: _mutedText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            const SizedBox.shrink(), // if currentStep is 0, back button is not displayed
          ElevatedButton(
            // onNext is used to go to the next step
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: _tealAccent,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            // if currentStep is 1, next button is displayed
            // isLoading is used to display the loading indicator
            child: isLoading && currentStep == 1
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: _baseDark,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    currentStep == 1 ? 'Terminer et S\'inscrire' : 'Suivant',
                    style: TextStyle(
                      color: _baseDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
