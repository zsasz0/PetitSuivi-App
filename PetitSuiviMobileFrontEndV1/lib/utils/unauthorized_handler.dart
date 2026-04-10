import 'package:flutter/material.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/views/auth/login/login_page.dart';
import 'package:provider/provider.dart';

/// Utility class to handle unauthorized (401) API responses globally.
///
/// When a 401 status code is detected, this handler clears the user's
/// session and redirects them to the login page.
class UnauthorizedHandler {
  static bool _isRedirecting = false;

  /// Evaluates the [statusCode] and performs a redirection if it is 401.
  ///
  /// Returns `true` if it handled a 401 response, `false` otherwise.
  static bool handle({required BuildContext context, required int statusCode}) {
    if (statusCode != 401) return false;
    if (!context.mounted) return true;
    if (_isRedirecting) return true;

    _isRedirecting = true;
    context.read<AuthSession>().clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
      _isRedirecting = false;
    });

    return true;
  }
}
