import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/l10n/app_localizations.dart';
import 'package:newv/views/themes/theme_colors.dart';
import 'package:newv/views/themes/theme_manager.dart';
import 'package:newv/views/parent/payments/components/payments/empty_payments.dart';
import 'package:newv/views/parent/payments/components/payments/payment_selector.dart';
import 'package:newv/views/parent/payments/components/payments/payment_summary_card.dart';
import 'package:newv/views/parent/payments/components/payments/payment_transactions_card.dart';
import 'package:newv/views/parent/payments/controllers/payment_controller.dart';
import 'package:newv/views/parent/payments/themes/payment_theme.dart';
import 'package:provider/provider.dart';

/// A page that manages and displays payment history and upcoming invoices for a parent.
class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  final PaymentController _controller = PaymentController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadPayments(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: const _PaymentsPageContent(),
    );
  }
}

class _PaymentsPageContent extends StatelessWidget {
  const _PaymentsPageContent();

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    final controller = context.watch<PaymentController>();
    final l10n = AppLocalizations.of(context)!;
    final selected = controller.selectedPayment;

    return Container(
      color: PaymentTheme.baseDark,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            l10n.payments,
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: PaymentTheme.lightText,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: ThemeColors.glassBackgroundSubtle,
                shape: BoxShape.circle,
                border: Border.all(color: ThemeColors.glassBorder),
              ),
              child: IconButton(
                icon: const Icon(Icons.refresh_rounded),
                color: PaymentTheme.tealAccent,
                onPressed: () => controller.loadPayments(context),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: controller.isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(PaymentTheme.tealAccent),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    if (controller.payments.isNotEmpty) const PaymentSelector(),
                    const SizedBox(height: 24),
                    if (selected == null)
                      const EmptyPayments()
                    else
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: ListView(
                            key: ValueKey(controller.selectedPaymentKey),
                            padding: const EdgeInsets.only(bottom: 100),
                            children: [
                              PaymentSummaryCard(payment: selected),
                              const SizedBox(height: 32),
                              PaymentTransactionsCard(payment: selected),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
