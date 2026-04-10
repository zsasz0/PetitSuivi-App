import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:newv/utils/api_constants.dart';
import 'package:newv/app_theme.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/l10n/app_localizations.dart';
import 'package:newv/utils/unauthorized_handler.dart';
import 'package:provider/provider.dart';
import 'package:newv/theme_manager.dart';
import 'package:newv/theme_colors.dart';

// File: payments_page.dart
// Purpose: Financial dashboard for parents to track child fees and payments.
// Usage: Accessed via the "Payments" tab or drawer.
// API Usage:
//   - GET /api/parents/{cin}/payments (Fetch payment and inscription history)
// Dependencies: AuthSession, UnauthorizedHandler, ApiConstants, AppTheme.

/// A page that manages and displays payment history and upcoming invoices for a parent.
class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  static const String _apiBaseUrl = ApiConstants.baseUrl;

  List<Map<String, dynamic>> _payments = [];
  bool _isLoading = true;
  String? _selectedPaymentKey;

  // Modern Theme Colors
  static Color get _baseDark => ThemeManager.instance.isLightMode
      ? const Color(0xFFF0F2F5)
      : const Color(0xFF141B2D);
  static Color get _tealAccent => ThemeManager.instance.isLightMode
      ? const Color(0xFF009688)
      : const Color(0xFF4CCEAC);
  static Color get _indigoAccent => ThemeManager.instance.isLightMode
      ? const Color(0xFF3F51B5)
      : const Color(0xFF6870FA);
  static Color get _lightText => ThemeManager.instance.isLightMode
      ? const Color(0xFF212529)
      : const Color(0xFFF2F0F0);
  static Color get _mutedText => ThemeManager.instance.isLightMode
      ? const Color(0xFF6C757D)
      : const Color(0xFFA1A4AB);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPayments());
  }

  Future<void> _loadPayments() async {
    final session = context.read<AuthSession>();
    final token = session.token;
    final cin = session.cin;

    if (token == null || token.isEmpty || cin == null) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      return;
    }

    final uri = Uri.parse('$_apiBaseUrl/api/parents/$cin/payments');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;
      if (UnauthorizedHandler.handle(
        context: context,
        statusCode: response.statusCode,
      ))
        return;
      final body = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          body['data'] is List) {
        final rows = (body['data'] as List)
            .whereType<Map>()
            .map((item) => item.cast<String, dynamic>())
            .toList();

        setState(() {
          _payments = rows;
          _isLoading = false;
          if (_selectedPaymentKey == null && _payments.isNotEmpty) {
            final first = _payments.first;
            _selectedPaymentKey = _paymentKey(first);
          }
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic>? get _selectedPayment {
    if (_selectedPaymentKey == null) return null;
    for (final payment in _payments) {
      if (_paymentKey(payment) == _selectedPaymentKey) return payment;
    }
    return null;
  }

  String _paymentKey(Map<String, dynamic> payment) {
    return '${payment['inscription_id']}-${payment['child_id']}';
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    final l10n = AppLocalizations.of(context)!;
    final selected = _selectedPayment;

    return Container(
      color: _baseDark,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            l10n.payments,
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: _lightText,
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
                color: _tealAccent,
                onPressed: _loadPayments,
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(_tealAccent),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    if (_payments.isNotEmpty) _buildSelector(l10n),
                    const SizedBox(height: 24),
                    if (selected == null)
                      _buildEmptyState(l10n)
                    else
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: ListView(
                            key: ValueKey(_selectedPaymentKey),
                            padding: const EdgeInsets.only(bottom: 100),
                            children: [
                              _buildSummaryCard(selected),
                              const SizedBox(height: 32),
                              _buildTransactionsCard(selected),
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

  Widget _buildSelector(AppLocalizations l10n) {
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
              value: _selectedPaymentKey,
              dropdownColor: _baseDark.withValues(alpha: 0.95),
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: _tealAccent),
              hint: Text(
                l10n.selectChild,
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  color: _mutedText,
                ),
              ),
              items: _payments.map((payment) {
                String fullName =
                    (payment['child_full_name']?.toString().trim().isNotEmpty ==
                        true)
                    ? payment['child_full_name'].toString()
                    : 'Enfant';

                // Append the academic year if dynamically available
                final classInfo = payment['class'];
                if (classInfo is Map && classInfo['year'] != null) {
                  final startYear = int.tryParse(classInfo['year'].toString());
                  if (startYear != null) {
                    final endYear = startYear + 1;
                    fullName = '$fullName ($startYear/$endYear)';
                  }
                }

                return DropdownMenuItem<String>(
                  value: _paymentKey(payment),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _childColor(payment),
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
                            color: _lightText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedPaymentKey = value),
            ),
          ),
        ),
      ),
    );
  }

  String _mapPaymentMethod(String? method) {
    final normalized = (method ?? '').trim().toLowerCase();
    if (normalized == 'monthlypartial' ||
        normalized == 'monthly_partial' ||
        normalized == 'monthly partial') {
      return 'Paiement Mensuel';
    }
    if (normalized == 'oneshot' ||
        normalized == 'one_shot' ||
        normalized == 'one shot') {
      return 'Paiement annuel';
    }
    return method ?? "-";
  }

  String? _rawPaymentMethod(Map<String, dynamic> payment) {
    return payment['payment_method']?.toString() ??
        payment['paymentMethod']?.toString() ??
        payment['Paymentmethod']?.toString();
  }

  Widget _buildSummaryCard(Map<String, dynamic> payment) {
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
    final double ratio = amount > 0
        ? (paid / amount).clamp(0.0, 1.0).toDouble()
        : 0.0;
    final status =
        ((payment['inscription_status'] as Map?)?['name']?.toString() ??
                'pending')
            .toLowerCase();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _tealAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _tealAccent.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: _tealAccent.withValues(alpha: 0.05),
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
                    color: _lightText,
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
                  color: _tealAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    color: _tealAccent,
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
            _mapPaymentMethod(_rawPaymentMethod(payment)),
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
                      color: _mutedText,
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
                          color: _lightText,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                      Text(
                        ' TND',
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          color: _tealAccent,
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
                      color: _mutedText,
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
                          color: _lightText,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                      Text(
                        ' TND',
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          color: _mutedText,
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
              valueColor: AlwaysStoppedAnimation<Color>(_tealAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: _mutedText, size: 20),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontFamily: AppTheme.fontName,
            color: _mutedText,
            fontSize: 15,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              color: _lightText,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            softWrap: true,
          ),
        ),
      ],
    );
  }

  // Color palette for per-child frais distinction. Adapted for Dark UI.
  static const List<Color> _childColors = [
    Color(0xFF6870FA), // Indigo
    Color(0xFF4CCEAC), // Teal
    Color(0xFFFF94A3), // Light Pink/Coral
    Color(0xFFFFCC70), // Warm Yellow
    Color(0xFF8B93FF), // Soft Blue
    Color(0xFFFF7ED4), // Vibrant Pink
  ];

  Color _childColor(Map<String, dynamic> payment) {
    final idx = _payments.indexOf(payment);
    return _childColors[idx.clamp(0, _childColors.length - 1) %
        _childColors.length];
  }

  Widget _buildTransactionsCard(Map<String, dynamic> payment) {
    final partials = (payment['partial_payments'] is List)
        ? (payment['partial_payments'] as List)
              .whereType<Map>()
              .map((e) => e.cast<String, dynamic>())
              .toList()
        : <Map<String, dynamic>>[];

    final fraisAmount =
        (payment['frais_inscription_amount'] as num?)?.toDouble() ?? 0.0;
    final inscriptionDate = payment['inscription_date']?.toString() ?? '-';
    final childAccent = _childColor(payment);
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
            color: _lightText,
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
                color: _mutedText,
              ),
            ),
          )
        else ...[
          if (hasFrais)
            _buildFraisRow(childAccent, inscriptionDate, fraisAmount),
          ...partials.map((tx) => _buildPartialTxRow(tx)),
        ],
      ],
    );
  }

  Widget _buildFraisRow(Color childAccent, String date, double amount) {
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
                    color: _lightText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    fontSize: 13,
                    color: _mutedText.withValues(alpha: 0.8),
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

  Widget _buildPartialTxRow(Map<String, dynamic> tx) {
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
              color: _tealAccent,
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
                    color: _lightText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tx['date']?.toString() ?? '-',
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    fontSize: 13,
                    color: _mutedText.withValues(alpha: 0.8),
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
              color: _lightText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
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
                color: _mutedText,
              ),
              const SizedBox(height: 16),
              Text(
                _payments.isEmpty
                    ? 'Aucun enfant/inscription trouvé.'
                    : l10n.selectChildToViewPayments,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  color: _mutedText,
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
