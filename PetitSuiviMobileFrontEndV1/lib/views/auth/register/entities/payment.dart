import 'payment_method.dart';
import 'partial_payment.dart';

/// Represents a payment record.
class Payment {
  final int? id;
  final double amount;
  final DateTime date;
  final PaymentMethod? method;

  /// Each Payment has a list of PartialPayments (1 to *)
  final List<PartialPayment> partialPayments;

  Payment({
    this.id,
    required this.amount,
    required this.date,
    this.method,
    this.partialPayments = const [],
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as int?,
      amount: (json['amount'] ?? 0.0).toDouble(),
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      method: json['method'] != null
          ? PaymentMethod.fromJson(json['method'] as Map<String, dynamic>)
          : null,
      partialPayments: (json['partialPayments'] as List?)
              ?.map((p) => PartialPayment.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'method': method?.toJson(),
      'partialPayments': partialPayments.map((p) => p.toJson()).toList(),
    };
  }
}
