import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/views/themes/theme_colors.dart';
import 'package:newv/views/parent/payments/themes/payment_theme.dart';

class FraisInscriptionRow extends StatelessWidget {
  final Color childAccent;
  final String date;
  final double amount;

  const FraisInscriptionRow({
    super.key,
    required this.childAccent,
    required this.date,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: childAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: childAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: childAccent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.school_rounded, color: childAccent, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Frais d'Inscription",
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: PaymentTheme.lightText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    fontSize: 13,
                    color: PaymentTheme.mutedText.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: childAccent,
            ),
          ),
        ],
      ),
    );
  }
}

class PartialPaymentRow extends StatelessWidget {
  final Map<String, dynamic> tx;

  const PartialPaymentRow({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final val = ((tx['value'] as num?)?.toDouble() ?? 0.0);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.glassBackgroundSubtle,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.glassBorderWithOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: ThemeColors.glassBackgroundSubtle,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.download_done_rounded,
              color: PaymentTheme.tealAccent,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Paiement partiel",
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: PaymentTheme.lightText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tx['date']?.toString() ?? '-',
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    fontSize: 13,
                    color: PaymentTheme.mutedText.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+${val.toStringAsFixed(2)}',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: PaymentTheme.lightText,
            ),
          ),
        ],
      ),
    );
  }
}
