import 'package:flutter/material.dart';
import '../common/fade_slide_transition.dart';
import '../common/glass_text_field.dart';

class LoginInputs extends StatelessWidget {
  final AnimationController staggerController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const LoginInputs({
    super.key,
    required this.staggerController,
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FadeSlideTransition(
          controller: staggerController,
          delay: 0.4,
          child: GlassTextField(
            controller: emailController,
            label: 'Email',
            icon: Icons.email_outlined,
          ),
        ),
        const SizedBox(height: 16),
        FadeSlideTransition(
          controller: staggerController,
          delay: 0.5,
          child: GlassTextField(
            controller: passwordController,
            label: 'Mot de passe',
            icon: Icons.lock_outline,
            isPassword: true,
          ),
        ),
      ],
    );
  }
}
