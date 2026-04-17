import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/l10n/app_localizations.dart';
import 'package:newv/views/themes/theme_colors.dart';
import 'package:newv/views/parent/payments/controllers/payment_controller.dart';
import 'package:newv/views/parent/payments/themes/payment_theme.dart';
import 'package:provider/provider.dart';

class EmptyPayments extends StatelessWidget {
  const EmptyPayments({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PaymentController>();
    final l10n = AppLocalizations.of(context)!;

    return Expanded(
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: ThemeColors.glassBackgroundSubtle,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: ThemeColors.glassBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 64,
                color: PaymentTheme.mutedText,
              ),
              const SizedBox(height: 16),
              Text(
                controller.payments.isEmpty
                    ? 'Aucun enfant/inscription trouvé.'
                    : l10n.selectChildToViewPayments,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  color: PaymentTheme.mutedText,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
