import 'package:flutter/material.dart';

// File: fade_slide_transition.dart
// Purpose: Staggered animation utility for UI elements.
// Usage: Wraps widgets in LoginPage for entrance animations.
// API Usage: No.
// Dependencies: None.

/// A utility widget that handles staggered slide-up and fade-in animations.
class FadeSlideTransition extends StatelessWidget {
  final AnimationController controller;
  final double delay;
  final Widget child;

  const FadeSlideTransition({
    super.key,
    required this.controller,
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // We map a start and end time based on the delay to create staggered effects
    final start = delay;
    final end = (delay + 0.3).clamp(0.0, 1.0);

    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - animation.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
