import 'package:flutter/material.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/utils/unauthorized_handler.dart';
import 'package:newv/views/parent/payments/apis/payment_apis.dart';
import 'package:provider/provider.dart';

class PaymentController extends ChangeNotifier {
  List<Map<String, dynamic>> _payments = [];
  bool _isLoading = true;
  String? _selectedPaymentKey;

  List<Map<String, dynamic>> get payments => _payments;
  bool get isLoading => _isLoading;
  String? get selectedPaymentKey => _selectedPaymentKey;

  set selectedPaymentKey(String? value) {
    _selectedPaymentKey = value;
    notifyListeners();
  }

  Map<String, dynamic>? get selectedPayment {
    if (_selectedPaymentKey == null) return null;
    for (final payment in _payments) {
      if (getPaymentKey(payment) == _selectedPaymentKey) return payment;
    }
    return null;
  }

  String getPaymentKey(Map<String, dynamic> payment) {
    return '${payment['inscription_id']}-${payment['child_id']}';
  }

  Future<void> loadPayments(BuildContext context, {bool silent = false}) async {
    final session = context.read<AuthSession>();
    final token = session.token;
    final cin = session.cin;

    if (token == null || token.isEmpty || cin == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final result = await PaymentApis.fetchPayments(
        cin: cin.toString(),
        token: token,
      );
      final int statusCode = result['status'];
      final Map<String, dynamic> body = result['data'];

      if (!context.mounted) return;
      if (UnauthorizedHandler.handle(
        context: context,
        statusCode: statusCode,
      )) {
        return;
      }

      if (statusCode >= 200 && statusCode < 300 && body['data'] is List) {
        _payments = (body['data'] as List)
            .whereType<Map>()
            .map((item) => item.cast<String, dynamic>())
            .toList();

        if (_selectedPaymentKey == null && _payments.isNotEmpty) {
          _selectedPaymentKey = getPaymentKey(_payments.first);
        }
      }
    } catch (e) {
      debugPrint('Error loading payments: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String mapPaymentMethod(String? method) {
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

  String? getRawPaymentMethod(Map<String, dynamic> payment) {
    return payment['payment_method']?.toString() ??
        payment['paymentMethod']?.toString() ??
        payment['Paymentmethod']?.toString();
  }
}
