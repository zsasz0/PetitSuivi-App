import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/views/themes/theme_colors.dart';
import 'package:newv/views/parent/payments/controllers/payment_controller.dart';
import 'package:newv/views/parent/payments/themes/payment_theme.dart';
import 'package:newv/views/parent/payments/components/payments/payment_transaction_rows.dart';
import 'package:provider/provider.dart';

class PaymentTransactionsCard extends StatelessWidget {
  final Map<String, dynamic> payment;

  const PaymentTransactionsCard({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<PaymentController>();
    final partials = (payment['partial_payments'] is List)
        ? (payment['partial_payments'] as List)
            .whereType<Map>()
            .map((e) => e.cast<String, dynamic>())
            .toList()
        : <Map<String, dynamic>>[];

    final fraisAmount =
        (payment['frais_inscription_amount'] as num?)?.toDouble() ?? 0.0;
    final inscriptionDate = payment['inscription_date']?.toString() ?? '-';

    final idx = controller.payments.indexOf(payment);
    final childAccent = PaymentTheme.getChildColor(idx);
    final hasFrais = fraisAmount > 0;
    final hasAny = hasFrais || partials.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historique des Transactions',
          style: TextStyle(
            fontFamily: AppTheme.fontName,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: PaymentTheme.lightText,
          ),
        ),
        const SizedBox(height: 16),
        if (!hasAny)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ThemeColors.glassBackgroundSubtle,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ThemeColors.glassBorder),
            ),
            alignment: Alignment.center,
            child: Text(
              'Aucun paiement enregistré.',
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                color: PaymentTheme.mutedText,
              ),
            ),
          )
        else ...[
          if (hasFrais)
            FraisInscriptionRow(
              childAccent: childAccent,
              date: inscriptionDate,
              amount: fraisAmount,
            ),
          ...partials.map((tx) => PartialPaymentRow(tx: tx)),
        ],
      ],
    );
  }
}
