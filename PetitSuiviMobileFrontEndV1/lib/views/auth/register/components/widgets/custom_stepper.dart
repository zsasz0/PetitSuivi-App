import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'step_indicator.dart';
import 'package:newv/theme_manager.dart';
import 'package:newv/theme_colors.dart';

// File: custom_stepper.dart
// Purpose: Progress bar for the registration flow.
// Usage: Rendered at the top of RegisterPage.
// API Usage: No.
// Dependencies: StepIndicator.

/// A stateless horizontal progress indicator with 'Parent' and 'Enfants' steps.
class CustomStepper extends StatelessWidget {
  static Color get _tealAccent => ThemeManager.instance.isLightMode
      ? const Color(0xFF009688)
      : const Color(0xFF4CCEAC);

  final int currentStep;

  const CustomStepper({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              StepIndicator(
                stepIndex: 0,
                title: 'Parent',
                currentStep: currentStep,
              ),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 2,
                  color: currentStep >= 1
                      ? _tealAccent
                      : ThemeColors.glassBorderStrong,
                ),
              ),
              StepIndicator(
                // step indicator for children used when currentStep is 1
                // it contains the title of the step and the current step
                stepIndex: 1,
                title: 'Enfants',
                currentStep: currentStep,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
