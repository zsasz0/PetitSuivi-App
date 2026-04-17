import 'package:flutter/material.dart';
import 'package:newv/views/auth/login/components/common/login_background_painter.dart';

class LoginBackground extends StatelessWidget {
  final AnimationController bgAnimController;

  const LoginBackground({
    super.key,
    required this.bgAnimController,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: bgAnimController,
        builder: (context, child) {
          return CustomPaint(
            painter: LoginBackgroundPainter(bgAnimController.value),
          );
        },
      ),
    );
  }
}
