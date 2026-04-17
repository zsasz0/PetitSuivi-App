import 'package:provider/provider.dart';
import 'package:newv/views/themes/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:newv/views/parent/waitingForApproval/controllers/waiting_approval_controller.dart';
import 'package:newv/views/parent/waitingForApproval/themes/waiting_approval_theme.dart';
import 'package:newv/views/parent/waitingForApproval/components/waiting_approval/approval_status_card.dart';
import 'package:newv/views/parent/waitingForApproval/components/waiting_approval/approval_next_steps_card.dart';

/// Informational screen shown to parents whose account is still pending admin approval.
/// Standardized PetitSuivi Modular Architecture.
class WaitingApprovalPage extends StatefulWidget {
  const WaitingApprovalPage({super.key});

  @override
  State<WaitingApprovalPage> createState() => _WaitingApprovalPageState();
}

class _WaitingApprovalPageState extends State<WaitingApprovalPage> {
  final WaitingApprovalController _controller = WaitingApprovalController();

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    
    return PopScope(
      canPop: false,
      child: Container(
        color: WaitingApprovalTheme.backgroundColor,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text(
              'Validation en cours',
              style: WaitingApprovalTheme.titleStyle,
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
                  _buildLogoutButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the logout button that returns the user to the login screen.
  Widget _buildLogoutButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _controller.logout(context),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: WaitingApprovalTheme.primaryActionColor),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: const Icon(Icons.logout_rounded),
      label: Text(
        'Retour à la connexion',
        style: WaitingApprovalTheme.buttonStyle,
      ),
    );
  }
}
