import 'package:flutter/material.dart';
import '../../../../themes/app_theme.dart';
import '../../themes/child_tracking_theme.dart';

class ChildTrackingError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ChildTrackingError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.red.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            message,
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              color: Colors.red.shade300,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: onRetry,
          style: ElevatedButton.styleFrom(
            backgroundColor: ChildTrackingTheme.tealAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 12,
            ),
          ),
          child: Text(
            'Réessayer',
            style: TextStyle(
              color: ChildTrackingTheme.baseDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
