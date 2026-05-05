import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';
import '../../themes/login_theme.dart';
import '../common/fade_slide_transition.dart';

class LoginHeader extends StatelessWidget {
  final AnimationController staggerController;

  const LoginHeader({
    super.key,
    required this.staggerController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FadeSlideTransition(
          controller: staggerController,
          delay: 0.1,
          child: Center(
            child: Image.asset(
              'assets/images/appImage.png',
              width: 104,
              height: 104,
            ),
          ),
        ),
        const SizedBox(height: 32),
        FadeSlideTransition(
          controller: staggerController,
          delay: 0.2,
          child: Text(
            'Bienvenue !',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontWeight: FontWeight.w800,
              fontSize: 32,
              color: LoginTheme.lightText,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        FadeSlideTransition(
          controller: staggerController,
          delay: 0.3,
          child: Text(
            'Connectez-vous pour continuer',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontSize: 16,
              color: LoginTheme.mutedText,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
