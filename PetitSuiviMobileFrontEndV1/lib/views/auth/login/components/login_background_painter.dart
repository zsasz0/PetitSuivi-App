import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:newv/theme_manager.dart';

// File: login_background_painter.dart
// Purpose: Animated background for the login screen.
// Usage: CustomPaint background in LoginPage.
// API Usage: No.
// Dependencies: None.

/// A [CustomPainter] that renders slowly moving glowing orbs for the login screen.
class LoginBackgroundPainter extends CustomPainter {
  final double value;

  LoginBackgroundPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    // We set the center of action higher up since it's a login screen
    final cy = size.height * 0.3;

    // Orb 1: Teal (Top Left) moving slowly
    final dx1 = math.cos(value * 2 * math.pi) * size.width * 0.3;
    final dy1 = math.sin(value * 2 * math.pi) * size.height * 0.15;

    // Orb 2: Indigo (Top Right to center) moving offset to Teal
    final dx2 = math.sin((value + 0.4) * 2 * math.pi) * size.width * 0.35;
    final dy2 = math.cos((value + 0.6) * 2 * math.pi) * size.height * 0.15;

    // Glowing Masks
    final isLight = ThemeManager.instance.isLightMode;
    final paintTeal = Paint()
      ..color = (isLight ? const Color(0xFF009688) : const Color(0xFF4CCEAC))
          .withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 120);

    final paintIndigo = Paint()
      ..color = (isLight ? const Color(0xFF3F51B5) : const Color(0xFF6870FA))
          .withValues(alpha: 0.20)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 150);

    canvas.drawCircle(
      Offset(cx - size.width * 0.1 + dx1, cy + dy1),
      180,
      paintTeal,
    );
    canvas.drawCircle(
      Offset(cx + size.width * 0.2 + dx2, cy + size.height * 0.1 + dy2),
      240,
      paintIndigo,
    );
  }

  @override
  bool shouldRepaint(covariant LoginBackgroundPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}
