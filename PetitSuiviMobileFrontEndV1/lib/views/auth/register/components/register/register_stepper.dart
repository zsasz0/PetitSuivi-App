import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:newv/views/themes/theme_manager.dart';
import '../../themes/register_theme.dart';
import 'step_indicator.dart';

/// A stateless horizontal progress indicator with 'Parent' and 'Enfants' steps.
class RegisterStepper extends StatelessWidget {
  final int currentStep;

  const RegisterStepper({super.key, required this.currentStep});

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
                      ? RegisterTheme.tealAccent
                      : RegisterTheme.glassBorder,
                ),
              ),
              StepIndicator(
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
