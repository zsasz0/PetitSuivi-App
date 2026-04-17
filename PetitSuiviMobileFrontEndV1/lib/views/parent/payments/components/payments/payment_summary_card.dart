import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/views/themes/theme_colors.dart';
import 'package:newv/views/parent/payments/controllers/payment_controller.dart';
import 'package:newv/views/parent/payments/themes/payment_theme.dart';
import 'package:provider/provider.dart';

class PaymentSummaryCard extends StatelessWidget {
  final Map<String, dynamic> payment;

  const PaymentSummaryCard({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<PaymentController>();
    final amount = (payment['amount'] as num?)?.toDouble() ?? 0.0;
    final partials = (payment['partial_payments'] is List)
        ? (payment['partial_payments'] as List)
            .whereType<Map>()
            .map((e) => e.cast<String, dynamic>())
            .toList()
        : <Map<String, dynamic>>[];
    final paid = partials.fold<double>(
      0.0,
      (sum, tx) => sum + ((tx['value'] as num?)?.toDouble() ?? 0.0),
    );
    final double ratio =
        amount > 0 ? (paid / amount).clamp(0.0, 1.0).toDouble() : 0.0;
    final status =
        ((payment['inscription_status'] as Map?)?['name']?.toString() ??
                'pending')
            .toLowerCase();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: PaymentTheme.tealAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: PaymentTheme.tealAccent.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: PaymentTheme.tealAccent.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  payment['child_full_name']?.toString() ?? 'Enfant',
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    color: PaymentTheme.lightText,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: PaymentTheme.tealAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    color: PaymentTheme.tealAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSummaryRow(
            Icons.restaurant_menu_rounded,
            'Repas',
            payment['meal_plan']?.toString() ?? '-',
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            Icons.credit_card_rounded,
            'Méthode',
            controller.mapPaymentMethod(controller.getRawPaymentMethod(payment)),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Payé',
                    style: TextStyle(
                      fontFamily: AppTheme.fontName,
                      color: PaymentTheme.mutedText,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        paid.toStringAsFixed(2),
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          color: PaymentTheme.lightText,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                      Text(
                        ' TND',
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          color: PaymentTheme.tealAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Reste à payer',
                    style: TextStyle(
                      fontFamily: AppTheme.fontName,
                      color: PaymentTheme.mutedText,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        (amount - paid)
                            .clamp(0, double.infinity)
                            .toStringAsFixed(2),
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          color: PaymentTheme.lightText,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                      Text(
                        ' TND',
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          color: PaymentTheme.mutedText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: ThemeColors.glassBorder,
              valueColor: AlwaysStoppedAnimation<Color>(PaymentTheme.tealAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: PaymentTheme.mutedText, size: 20),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontFamily: AppTheme.fontName,
            color: PaymentTheme.mutedText,
            fontSize: 15,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              color: PaymentTheme.lightText,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            softWrap: true,
          ),
        ),
      ],
    );
  }
}
