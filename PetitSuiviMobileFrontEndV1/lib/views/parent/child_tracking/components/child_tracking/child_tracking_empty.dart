import 'package:flutter/material.dart';
import '../../../../themes/app_theme.dart';
import '../../../../themes/theme_colors.dart';
import '../../themes/child_tracking_theme.dart';

class ChildTrackingEmpty extends StatelessWidget {
  const ChildTrackingEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: ThemeColors.glassBackgroundSubtle,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ThemeColors.glassBorder),
      ),
      child: Column(
        children: [
          Icon(
            Icons.child_care_outlined,
            size: 64,
            color: ChildTrackingTheme.mutedText,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun enfant trouvé pour ce parent.',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              color: ChildTrackingTheme.mutedText,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
