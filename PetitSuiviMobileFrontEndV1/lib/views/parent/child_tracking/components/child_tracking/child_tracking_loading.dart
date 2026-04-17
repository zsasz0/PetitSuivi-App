import 'package:flutter/material.dart';
import '../../themes/child_tracking_theme.dart';

class ChildTrackingLoading extends StatelessWidget {
  const ChildTrackingLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ChildTrackingTheme.tealAccent),
        ),
      ),
    );
  }
}
