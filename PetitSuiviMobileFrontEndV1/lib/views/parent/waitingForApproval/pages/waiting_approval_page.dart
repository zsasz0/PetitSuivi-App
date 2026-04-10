import 'package:provider/provider.dart';
import 'package:newv/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:newv/app_theme.dart';
import 'package:newv/views/auth/login/login_page.dart';
import 'package:newv/views/parent/waitingForApproval/widgets/approval_next_steps_card.dart';
import 'package:newv/views/parent/waitingForApproval/widgets/approval_status_card.dart';

// File: waiting_approval_page.dart
// Purpose: Informational screen shown to parents whose account is still pending admin approval.
// Usage: Displayed after login if the parent's Account.Approval_status is not 'approved'.
// API Usage: No direct API calls.
// Dependencies: LoginPage, ApprovalStatusCard, ApprovalNextStepsCard.

/// A full-screen holding page informing the parent that their registration is under review.
class WaitingApprovalPage extends StatelessWidget {
  const WaitingApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return PopScope(
      canPop: false,
      child: Container(
        color: AppTheme.background,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text(
              'Validation en cours',
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkerText,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  const ApprovalStatusCard(),
                  const SizedBox(height: 16),
                  const ApprovalNextStepsCard(),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                        (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.nearlyDarkBlue),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.logout_rounded),
                    label: Text(
                      'Retour à la connexion',
                      style: TextStyle(
                        fontFamily: AppTheme.fontName,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
