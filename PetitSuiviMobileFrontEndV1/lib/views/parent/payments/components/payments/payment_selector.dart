import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/l10n/app_localizations.dart';
import 'package:newv/views/themes/theme_colors.dart';
import 'package:newv/views/parent/payments/controllers/payment_controller.dart';
import 'package:newv/views/parent/payments/themes/payment_theme.dart';
import 'package:provider/provider.dart';

class PaymentSelector extends StatelessWidget {
  const PaymentSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PaymentController>();
    final l10n = AppLocalizations.of(context)!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: ThemeColors.glassBackgroundSubtle,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ThemeColors.glassBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: controller.selectedPaymentKey,
              dropdownColor: PaymentTheme.baseDark.withValues(alpha: 0.95),
              icon: Icon(Icons.keyboard_arrow_down_rounded,
                  color: PaymentTheme.tealAccent),
              hint: Text(
                l10n.selectChild,
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  color: PaymentTheme.mutedText,
                ),
              ),
              items: controller.payments.map((payment) {
                String fullName =
                    (payment['child_full_name']?.toString().trim().isNotEmpty ==
                            true)
                        ? payment['child_full_name'].toString()
                        : 'Enfant';

                final classInfo = payment['class'];
                if (classInfo is Map && classInfo['year'] != null) {
                  final startYear = int.tryParse(classInfo['year'].toString());
                  if (startYear != null) {
                    final endYear = startYear + 1;
                    fullName = '$fullName ($startYear/$endYear)';
                  }
                }

                final idx = controller.payments.indexOf(payment);
                final childColor = PaymentTheme.getChildColor(idx);

                return DropdownMenuItem<String>(
                  value: controller.getPaymentKey(payment),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: childColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          fullName,
                          style: TextStyle(
                            fontFamily: AppTheme.fontName,
                            fontWeight: FontWeight.w600,
                            color: PaymentTheme.lightText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => controller.selectedPaymentKey = value,
            ),
          ),
        ),
      ),
    );
  }
}
