import 'inscription_status.dart';
import 'inscription_type.dart';
import 'meal_plan.dart';
import 'medical_form.dart';
import 'payment.dart';
import 'child.dart';

/// Represents an inscription record for a child.
class Inscription {
  final int? id;
  final double baseFee;
  final DateTime date;
  final double fraisInscriptionSnapshot;
  final double inscriptionFeesPaymentAmount;
  final int isArchived;
  final double mealPlanFee;

  // Relationships
  final InscriptionStatus? status;
  final InscriptionType? type;
  final MealPlan? mealPlan;
  final MedicalForm? medicalForm;
  final Payment? payment;

  /// Link back to Child (1 Inscription -> 1 Child)
  final Child? child;

  Inscription({
    this.id,
    required this.baseFee,
    required this.date,
    required this.fraisInscriptionSnapshot,
    required this.inscriptionFeesPaymentAmount,
    required this.isArchived,
    required this.mealPlanFee,
    this.status,
    this.type,
    this.mealPlan,
    this.medicalForm,
    this.payment,
    this.child,
  });

  factory Inscription.fromJson(Map<String, dynamic> json) {
    return Inscription(
      id: json['id'] as int?,
      baseFee: (json['baseFee'] ?? 0.0).toDouble(),
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      fraisInscriptionSnapshot: (json['fraisInscriptionSnapshot'] ?? 0.0).toDouble(),
      inscriptionFeesPaymentAmount: (json['inscriptionFeesPaymentAmount'] ?? 0.0).toDouble(),
      isArchived: json['isArchived'] ?? 0,
      mealPlanFee: (json['mealPlanFee'] ?? 0.0).toDouble(),
      status: json['status'] != null
          ? InscriptionStatus.fromJson(json['status'] as Map<String, dynamic>)
          : null,
      type: json['type'] != null
          ? InscriptionType.fromJson(json['type'] as Map<String, dynamic>)
          : null,
      mealPlan: json['mealPlan'] != null
          ? MealPlan.fromJson(json['mealPlan'] as Map<String, dynamic>)
          : null,
      medicalForm: json['medicalForm'] != null
          ? MedicalForm.fromJson(json['medicalForm'] as Map<String, dynamic>)
          : null,
      payment: json['payment'] != null
          ? Payment.fromJson(json['payment'] as Map<String, dynamic>)
          : null,
      child: json['child'] != null ? Child.fromJson(json['child'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'baseFee': baseFee,
      'date': date.toIso8601String(),
      'fraisInscriptionSnapshot': fraisInscriptionSnapshot,
      'inscriptionFeesPaymentAmount': inscriptionFeesPaymentAmount,
      'isArchived': isArchived,
      'mealPlanFee': mealPlanFee,
      'status': status?.toJson(),
      'type': type?.toJson(),
      'mealPlan': mealPlan?.toJson(),
      'medicalForm': medicalForm?.toJson(),
      'payment': payment?.toJson(),
      'child': child?.toJson(),
    };
  }
}
