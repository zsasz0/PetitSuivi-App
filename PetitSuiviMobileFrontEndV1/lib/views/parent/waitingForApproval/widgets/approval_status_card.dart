import 'package:provider/provider.dart';
import 'package:newv/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:newv/app_theme.dart';

// File: approval_status_card.dart
// Purpose: Visual card displaying the 'pending approval' status with icon and message.
// Usage: Child widget inside WaitingApprovalPage.
// API Usage: No.
// Dependencies: AppTheme.

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
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.grey.withValues(alpha: 0.12),
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
              color: Colors.orange.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hourglass_top_rounded,
              color: Colors.orange,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Inscription en attente de validation',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.darkerText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vous serez notifié(e) dès que votre compte parent sera approuvé.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontSize: 14,
              color: AppTheme.grey,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
