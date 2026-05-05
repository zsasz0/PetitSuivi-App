import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:newv/views/themes/theme_manager.dart';
import '../../themes/register_theme.dart';

/// A visual indicator representing an active, completed, or pending step.
class StepIndicator extends StatelessWidget {
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
        ? RegisterTheme.tealAccent
        : RegisterTheme.mutedText.withValues(alpha: 0.5);

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isCompleted
                ? RegisterTheme.tealAccent
                : (isActive
                      ? RegisterTheme.tealAccent.withValues(alpha: 0.2)
                      : Colors.transparent),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: RegisterTheme.tealAccent.withValues(alpha: 0.3),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check, size: 20, color: RegisterTheme.baseDark)
                : Text(
                    '${stepIndex + 1}',
                    style: TextStyle(
                      color: isActive
                          ? RegisterTheme.tealAccent
                          : RegisterTheme.mutedText.withValues(alpha: 0.5),
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
