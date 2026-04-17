import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../apis/apis.dart';
import '../../../../models/auth_session.dart';
import '../../../../models/account.dart';
import '../../../parent/waitingForApproval/waiting_approval_page.dart';

/// Controller class that handles business logic for the LoginPage.
class LoginController {
  final BuildContext context;
  // Constructor
  LoginController(this.context);
  /// Attempts to automatically log the user in if a persisted session exists in AuthSession.
  /// Also verifies that an active school-year planning exists before navigating.
  Future<void> resumePersistedSessionIfAvailable({
    required VoidCallback onTeacherHome,
    required VoidCallback onParentHome,
    required Function(String) onError,
  }) async {
    final session = context.read<AuthSession>();
    if (!session.isLoggedIn) return;
    // Gate: ensure an active (non-archived) planning exists
    final hasActivePlanning = await checkActivePlanning();
    if (!context.mounted) return;
    // If no active planning, clear session and show error
    if (!hasActivePlanning) {
      // Clear stored session so the user is not silently let through on every restart
      session.clear();
      onError(
        'L\'accès est temporairement suspendu. '
        'Aucune année scolaire active n\'est en cours. '
        'Veuillez contacter l\'administration.',
      );
      return;
    }


    /// main logic
    // Navigate to the appropriate home page based on user role
    if (session.role == 'teacher') {
      onTeacherHome();
    } else if (session.role == 'parent') {
      onParentHome();
    }
  }

  /// Restores the last used email address using SharedPreferences to reduce repetitive typing.
  Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('saved_email');
  }

  /// Queries the API to check if `inscriptions_open` parameter is active.
  /// Used to conditionally show the registration link.
  Future<bool> checkInscriptionsOpen() async {
    return await LoginApis.fetchInscriptionsStatus();
  }

  /// Checks whether there is at least one active (non-archived) planning.
  /// Returns `false` only when plannings were successfully fetched and all
  /// are archived. Returns `true` on network error (fail-open).
  Future<bool> checkActivePlanning() async {
    final result = await LoginApis.fetchActivePlanning();
    // null = network error → fail-open so we don't lock out users for infra issues
    return result ?? true;
  }

  /// Validates input and fires the POST request for user authentication.
  /// Handles session storage and navigation upon success or error.
  Future<void> handleLogin({
    required String email,
    required String password,
    required int selectedRole,
    required Function(bool) onLoadingChanged,
    required Function(String) onError,
    required VoidCallback onTeacherHome,
    required VoidCallback onParentHome,
  }) async {
    // 1. Basic Validation
    if (email.isEmpty || password.isEmpty) {
      onError('Email et mot de passe sont obligatoires.');
      return;
    }

    // 2. Prepare for API call
    FocusScope.of(context).unfocus();
    onLoadingChanged(true);

    try {
      // 3. Call API Service
      final data = await LoginApis.performLogin(
        email: email,
        password: password,
        isTeacher: selectedRole == 1,
      );

      final statusCode = data['statusCode'] as int;

      if (!context.mounted) return;

      // 4. Handle Success response
      if (statusCode >= 200 && statusCode < 300) {
        final token = data['token']?.toString();
        final Account? account = data['account'] as Account?;

        if (token == null || token.isEmpty || account == null) {
          onError('Réponse API invalide (compte ou jeton manquant).');
          onLoadingChanged(false);
          return;
        }

        // Map Role value to string for AuthSession
        String roleName = '';
        if (account.role.value == 1) {
          roleName = 'teacher';
        } else if (account.role.value == 3) {
          roleName = 'parent';
        } else if (account.role.value == 2) {
          roleName = 'admin';
        }

        if (roleName.isEmpty) {
          onError('Rôle utilisateur non reconnu.');
          onLoadingChanged(false);
          return;
        }

        // Save session locally via Provider
        context.read<AuthSession>().setSession(
          token: token,
          cin: account.cin,
          role: roleName,
          firstName: account.firstName,
          lastName: account.lastName,
          email: account.email,
          phone: account.phone.toString(),
          address: account.adresse,
          birthdate: account.birthdate.toIso8601String(),
          inscriptionDate: account.inscriptiondate.toIso8601String(),
        );

        // Persist email for next time
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_email', email);

        // Role-based navigation — but first verify an active school year exists
        final hasActivePlanning = await checkActivePlanning();
        if (!context.mounted) return;

        if (!hasActivePlanning) {
          onError(
            'L\'accès est temporairement suspendu. '
            'Aucune année scolaire active n\'est en cours. '
            'Veuillez contacter l\'administration.',
          );
          onLoadingChanged(false);
          return;
        }

        if (roleName == 'teacher') {
          onTeacherHome();
        } else if (roleName == 'parent') {
          onParentHome();
        } else {
          onError('Role utilisateur invalide.');
        }
      } 
      // 5. Handle Error response
      else {
        // Special case: Admin approval pending
        final requiresAdminApproval = data['requires_admin_approval'] == true;
        if (requiresAdminApproval && selectedRole == 2) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const WaitingApprovalPage(),
            ),
            (route) => false,
          );
          return;
        }

        final message = data['message']?.toString() ?? 'Échec de connexion.';
        onError(message);
      }
    } catch (e) {
      // 6. Network or unexpected error
      onError('Impossible de joindre le serveur. Vérifiez l\'URL API.');
    } finally {
      // 7. Cleanup loading state
      onLoadingChanged(false);
    }
  }
}
