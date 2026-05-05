import 'package:provider/provider.dart';
import 'package:newv/views/themes/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:newv/views/parent/waitingForApproval/themes/waiting_approval_theme.dart';

/// A decorative card communicating that the parent's inscription is awaiting validation.
class ApprovalStatusCard extends StatelessWidget {
  const ApprovalStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: WaitingApprovalTheme.cardColor,
        borderRadius: BorderRadius.circular(WaitingApprovalTheme.largeCardRadius),
        boxShadow: [
          BoxShadow(
            color: WaitingApprovalTheme.tertiaryTextColor.withValues(alpha: 0.12),
            offset: const Offset(0, 5),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: WaitingApprovalTheme.statusPendingColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.hourglass_top_rounded,
              color: WaitingApprovalTheme.statusPendingColor,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Inscription en attente de validation',
            textAlign: TextAlign.center,
            style: WaitingApprovalTheme.statusTitleStyle,
          ),
          const SizedBox(height: 8),
          Text(
            'Vous serez notifié(e) dès que votre compte parent sera approuvé.',
            textAlign: TextAlign.center,
            style: WaitingApprovalTheme.bodyStyle,
          ),
        ],
      ),
    );
  }
}
