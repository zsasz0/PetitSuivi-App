import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/views/themes/theme_colors.dart';
import 'package:newv/views/parent/child_tracking/themes/child_tracking_theme.dart';

class PickupPendingHint extends StatelessWidget {
  const PickupPendingHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ThemeColors.glassBackgroundSubtle,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.glassBorderSubtle),
      ),
      child: Text(
        'Action disponible après approbation',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: AppTheme.fontName,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: ChildTrackingTheme.mutedText,
        ),
      ),
    );
  }
}
