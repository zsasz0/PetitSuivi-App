import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';
import '../../themes/login_theme.dart';
import '../common/fade_slide_transition.dart';

class LoginForgotPasswordLink extends StatelessWidget {
  final AnimationController staggerController;
  final VoidCallback onPressed;

  const LoginForgotPasswordLink({
    super.key,
    required this.staggerController,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FadeSlideTransition(
      controller: staggerController,
      delay: 0.75,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Mot de passe oublie ? ',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              color: LoginTheme.mutedText,
              fontSize: 15,
            ),
          ),
          TextButton(
            onPressed: onPressed,
            child: Text(
              'Reinitialiser',
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                fontWeight: FontWeight.w700,
                color: LoginTheme.tealAccent,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
