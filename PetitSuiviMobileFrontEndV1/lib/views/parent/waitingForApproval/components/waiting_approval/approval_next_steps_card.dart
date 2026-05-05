import 'package:provider/provider.dart';
import 'package:newv/views/themes/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:newv/views/parent/waitingForApproval/themes/waiting_approval_theme.dart';

/// A card listing what happens next (email notification, phone call from staff).
class ApprovalNextStepsCard extends StatelessWidget {
  const ApprovalNextStepsCard({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: WaitingApprovalTheme.cardColor,
        borderRadius: BorderRadius.circular(WaitingApprovalTheme.cardRadius),
        border: Border.all(color: WaitingApprovalTheme.tertiaryTextColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prochaines étapes',
            style: WaitingApprovalTheme.cardTitleStyle,
          ),
          const SizedBox(height: 12),
          _step(
            Icons.email_outlined,
            'Vous recevrez un email de notification dès validation.',
          ),
          const SizedBox(height: 10),
          _step(
            Icons.call_outlined,
            'Notre équipe vous contactera également par téléphone.',
          ),
        ],
      ),
    );
  }

  Widget _step(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: WaitingApprovalTheme.primaryActionColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: WaitingApprovalTheme.stepStyle,
          ),
        ),
      ],
    );
  }
}
