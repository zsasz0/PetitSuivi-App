import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/views/auth/register/entities/child.dart';
import 'package:newv/views/themes/theme_colors.dart';
import 'package:newv/views/parent/child_tracking/controllers/child_tracking_controller.dart';
import 'package:newv/views/parent/child_tracking/themes/child_tracking_theme.dart';

class PickupNotifierButton extends StatelessWidget {
  final Child child;
  final ChildTrackingController controller;

  const PickupNotifierButton({
    super.key,
    required this.child,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final alreadyNotified = controller.isPickupNotified(child);

    if (alreadyNotified) {
      return Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: ChildTrackingTheme.tealAccent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ChildTrackingTheme.tealAccent.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 22,
              color: ChildTrackingTheme.tealAccent,
            ),
            const SizedBox(width: 8),
            Text(
              'Récupération notifiée',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: ChildTrackingTheme.tealAccent,
              ),
            ),
          ],
        ),
      );
    }

    return OutlinedButton(
      onPressed: () => _handlePickupNotification(context),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        backgroundColor: ThemeColors.glassBackgroundSubtle,
        side: BorderSide(color: ChildTrackingTheme.indigoAccent.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_active_outlined,
            size: 22,
            color: ChildTrackingTheme.indigoAccent,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Notifier la récupération',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ChildTrackingTheme.indigoAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePickupNotification(BuildContext context) async {
    int selectedDuration = 15;
    final int? durationMinutes = await showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ChildTrackingTheme.baseDark,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: ThemeColors.glassBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ChildTrackingTheme.indigoAccent.withValues(alpha: 0.15),
                  ),
                  child: Icon(
                    Icons.directions_car_filled_outlined,
                    size: 32,
                    color: ChildTrackingTheme.indigoAccent,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Récupération de ${child.firstName}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ChildTrackingTheme.lightText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Dans combien de temps serez-vous là ?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    fontSize: 14,
                    color: ChildTrackingTheme.mutedText,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  '$selectedDuration min',
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: ChildTrackingTheme.tealAccent,
                  ),
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: ChildTrackingTheme.tealAccent,
                    inactiveTrackColor: ThemeColors.glassBorderStrong,
                    thumbColor: ChildTrackingTheme.tealAccent,
                    overlayColor: ChildTrackingTheme.tealAccent.withValues(alpha: 0.15),
                    trackHeight: 8,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                  ),
                  child: Slider(
                    value: selectedDuration.toDouble(),
                    min: 5,
                    max: 60,
                    divisions: 11,
                    onChanged: (value) {
                      setDialogState(() {
                        selectedDuration = (value / 5).round() * 5;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '5m',
                        style: TextStyle(
                          fontSize: 12,
                          color: ChildTrackingTheme.mutedText.withValues(alpha: 0.7),
                        ),
                      ),
                      Text(
                        '60m',
                        style: TextStyle(
                          fontSize: 12,
                          color: ChildTrackingTheme.mutedText.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: ThemeColors.glassBorderStrong),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          'Annuler',
                          style: TextStyle(
                            fontFamily: AppTheme.fontName,
                            fontWeight: FontWeight.bold,
                            color: ChildTrackingTheme.mutedText,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, selectedDuration),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: ChildTrackingTheme.tealAccent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text(
                          'Confirmer',
                          style: TextStyle(
                            fontFamily: AppTheme.fontName,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (durationMinutes != null && context.mounted) {
      await controller.handlePickupNotification(
        context: context,
        child: child,
        durationMinutes: durationMinutes,
      );
    }
  }
}
