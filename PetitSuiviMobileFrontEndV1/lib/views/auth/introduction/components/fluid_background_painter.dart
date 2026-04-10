import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:newv/theme_manager.dart';

// File: fluid_background_painter.dart
// Purpose: Decorative animated background with glowing fluid blobs.
// Usage: Background layer for IntroductionAnimationScreen.
// API Usage: No.
// Dependencies: None.

/// A [CustomPainter] that renders a dynamic, animated fluid background.
///
/// It uses sine waves to shift translucent blobs across the canvas,
/// creating an organic "glowing" effect.
class FluidBackgroundPainter extends CustomPainter {
  /// The current animation value (usually 0.0 to 1.0).
  final double value;

  /// The current page index to shift the background parallax.
  final int page;

  /// Creates a [FluidBackgroundPainter] with the given [value] and [page].
  FluidBackgroundPainter(this.value, this.page);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Fluid movement using combination of sine waves
    final dx1 = math.cos(value * 2 * math.pi) * size.width * 0.4;
    final dy1 = math.sin(value * 2 * math.pi) * size.height * 0.3;

    final dx2 = math.sin((value + 0.33) * 2 * math.pi) * size.width * 0.4;
    final dy2 = math.cos((value + 0.5) * 2 * math.pi) * size.height * 0.3;

    final dx3 = math.cos((value + 0.66) * 2 * math.pi) * size.width * 0.3;
    final dy3 = math.sin((value + 0.2) * 2 * math.pi) * size.height * 0.4;

    // Transition offset to give a 3D moving camera feel when sliding pages
    // We smooth this visually by combining it directly with coordinate space.
    final pageOffsetX = page * -size.width * 0.2;

    // Teal blob top leftish
    final isLight = ThemeManager.instance.isLightMode;
    final paintTeal = Paint()
      ..color = (isLight ? const Color(0xFF009688) : const Color(0xFF4CCEAC))
          .withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);

    // Indigo blob bottom rightish
    final paintIndigo = Paint()
      ..color = (isLight ? const Color(0xFF3F51B5) : const Color(0xFF6870FA))
          .withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 120);

    // Navy highlight blob center/bottom
    final paintNavyGlow = Paint()
      ..color = (isLight ? const Color(0xFFB0BEC5) : const Color(0xFF1F2A40))
          .withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 150);

    // Draw the ambient glowing forms
    canvas.drawCircle(
      Offset(cx + dx1 + pageOffsetX, cy - size.height * 0.2 + dy1),
      180 + 30 * math.sin(value * 2 * math.pi),
      paintTeal,
    );
    canvas.drawCircle(
      Offset(
        cx + dx2 + size.width * 0.2 + pageOffsetX,
        cy + size.height * 0.2 + dy2,
      ),
      220 + 40 * math.cos(value * 2 * math.pi),
      paintIndigo,
    );
    canvas.drawCircle(
      Offset(cx + dx3 - size.width * 0.3 + pageOffsetX, cy + dy3),
      240 + 30 * math.sin((value + 0.5) * 2 * math.pi),
      paintNavyGlow,
    );
  }

  @override
  bool shouldRepaint(covariant FluidBackgroundPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.page != page;
  }
}
