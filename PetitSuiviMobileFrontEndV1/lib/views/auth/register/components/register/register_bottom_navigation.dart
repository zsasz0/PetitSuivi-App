import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:newv/views/themes/theme_manager.dart';
import '../../themes/register_theme.dart';

/// A stateless navigation bar providing 'Back' and 'Next/Finish' buttons.
class RegisterBottomNavigation extends StatelessWidget {
  final int currentStep;
  final bool isLoading;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const RegisterBottomNavigation({
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
        color: RegisterTheme.baseDark,
        boxShadow: [
          BoxShadow(
            color: RegisterTheme.baseDark.withValues(alpha: 0.8),
            offset: const Offset(0, -4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (currentStep > 0)
            TextButton(
              onPressed: onBack,
              child: Text(
                'Retour',
                style: TextStyle(
                  color: RegisterTheme.mutedText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            const SizedBox.shrink(),
          ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: RegisterTheme.tealAccent,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading && currentStep == 1
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: RegisterTheme.baseDark,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    currentStep == 1 ? 'Terminer et S\'inscrire' : 'Suivant',
                    style: TextStyle(
                      color: RegisterTheme.baseDark,
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
