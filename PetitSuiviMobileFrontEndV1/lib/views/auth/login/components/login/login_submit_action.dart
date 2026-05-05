import 'package:flutter/material.dart';
import '../../components/common/login_button.dart';
import '../../themes/login_theme.dart';

class LoginSubmitAction extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const LoginSubmitAction({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(
              color: LoginTheme.tealAccent,
            ),
          )
        : LoginButton(
            onPressed: onPressed,
          );
  }
}
