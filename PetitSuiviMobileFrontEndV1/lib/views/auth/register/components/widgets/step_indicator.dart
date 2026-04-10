import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:newv/theme_manager.dart';

// File: step_indicator.dart
// Purpose: Discrete indicator for a single step in the stepper.
// Usage: Component of CustomStepper.
// API Usage: No.
// Dependencies: None.

/// A visual indicator representing an active, completed, or pending step.
class StepIndicator extends StatelessWidget {
  static Color get _baseDark => ThemeManager.instance.isLightMode ? const Color(0xFFF0F2F5) : const Color(0xFF141B2D);
  static Color get _tealAccent => ThemeManager.instance.isLightMode ? const Color(0xFF009688) : const Color(0xFF4CCEAC);
  static Color get _mutedText => ThemeManager.instance.isLightMode ? const Color(0xFF6C757D) : const Color(0xFFA1A4AB);

  final int stepIndex;
  final String title;
  final int currentStep;

  const StepIndicator({
    super.key,
    required this.stepIndex,
    required this.title,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    final isActive = currentStep == stepIndex;
    final isCompleted = currentStep > stepIndex;
    final color = isActive || isCompleted
        ? _tealAccent
        : _mutedText.withValues(alpha: 0.5);

    return Column(
      children: [
        // AnimatedContainer is used to animate the step indicator
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isCompleted
                ? _tealAccent
                : (isActive
                      ? _tealAccent.withValues(alpha: 0.2)
                      : Colors.transparent),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: _tealAccent.withValues(alpha: 0.3),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child:
                isCompleted // if step is completed, show check mark
                ? Icon(Icons.check, size: 20, color: _baseDark)
                : Text(
                    '${stepIndex + 1}',
                    style: TextStyle(
                      color: isActive
                          ? _tealAccent
                          : _mutedText.withValues(alpha: 0.5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
