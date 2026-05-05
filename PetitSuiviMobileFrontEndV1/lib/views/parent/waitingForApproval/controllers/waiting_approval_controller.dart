import 'package:flutter/material.dart';
import 'package:newv/views/auth/login/login_page.dart';

/// Controller handling the logic for the Waiting Approval screen.
class WaitingApprovalController {
  /// Navigates the user back to the login screen and clears the navigation stack.
  void logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
      (route) => false,
    );
  }
}
