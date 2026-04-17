import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';
import '../../themes/login_theme.dart';
import '../common/fade_slide_transition.dart';

class LoginRegisterLink extends StatelessWidget {
  final bool inscriptionsOpen;
  final AnimationController staggerController;
  final VoidCallback onRegisterPressed;

  const LoginRegisterLink({
    super.key,
    required this.inscriptionsOpen,
    required this.staggerController,
    required this.onRegisterPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (!inscriptionsOpen) return const SizedBox.shrink();
    return FadeSlideTransition(
      controller: staggerController,
      delay: 0.8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Pas encore de compte ? ',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              color: LoginTheme.mutedText,
              fontSize: 15,
            ),
          ),
          TextButton(
            onPressed: onRegisterPressed,
            child: Text(
              'S\'inscrire',
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
