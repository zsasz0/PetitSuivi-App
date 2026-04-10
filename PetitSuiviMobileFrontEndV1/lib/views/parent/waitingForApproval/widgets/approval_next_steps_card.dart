import 'package:provider/provider.dart';
import 'package:newv/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:newv/app_theme.dart';

// File: approval_next_steps_card.dart
// Purpose: Informational card listing the steps that follow after registration submission.
// Usage: Child widget inside WaitingApprovalPage.
// API Usage: No.
// Dependencies: AppTheme.

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
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.grey.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prochaines étapes',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.darkerText,
            ),
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
        Icon(icon, size: 18, color: AppTheme.nearlyDarkBlue),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontSize: 13,
              color: AppTheme.darkText,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
