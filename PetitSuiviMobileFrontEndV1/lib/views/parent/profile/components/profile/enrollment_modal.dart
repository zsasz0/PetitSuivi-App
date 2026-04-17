import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/views/themes/theme_colors.dart';
import 'package:newv/views/themes/theme_manager.dart';
import 'package:newv/views/auth/register/controllers/register_controller.dart';
import 'package:newv/views/auth/register/themes/register_theme.dart';
import 'package:newv/views/parent/profile/themes/profile_theme.dart';
import 'package:newv/views/parent/profile/components/common/profile_form_components.dart';

class EnrollmentModal extends StatefulWidget {
  final List<String> inscriptionTypes;
  final List<String> paymentMethods;
  final List<String> mealPlanOptions;
  final Map<String, double> mealPlanFees;
  final bool loadingPricing;
  final double Function(String) calculateTotalAmount;
  final String Function(String) paymentMethodLabel;
  final String Function(String, {double? price}) shortMealPlanLabel;
  final Future<bool> Function({
    required String firstName,
    required String lastName,
    required String birthDate,
    required String inscriptionType,
    required String paymentMethod,
    required String mealPlan,
    required double totalAmount,
    Map<String, dynamic>? medicalForm,
  }) onCreateInscription;

  const EnrollmentModal({
    super.key,
    required this.inscriptionTypes,
    required this.paymentMethods,
    required this.mealPlanOptions,
    required this.mealPlanFees,
    required this.loadingPricing,
    required this.calculateTotalAmount,
    required this.paymentMethodLabel,
    required this.shortMealPlanLabel,
    required this.onCreateInscription,
  });

  @override
  State<EnrollmentModal> createState() => _EnrollmentModalState();
}

class _EnrollmentModalState extends State<EnrollmentModal> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  String? _selectedInscriptionType;
  String? _selectedPaymentMethod;
  late String _selectedMealPlan;
  Map<String, dynamic> _medicalFormData = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    _selectedPaymentMethod = widget.paymentMethods.isNotEmpty
        ? widget.paymentMethods.first
        : null;
    _selectedMealPlan = widget.mealPlanOptions.first;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double calculatedTotalAmount = widget.calculateTotalAmount(_selectedMealPlan);
    final bool canOpenMedical = _firstNameController.text.trim().isNotEmpty &&
        _lastNameController.text.trim().isNotEmpty &&
        _birthDateController.text.trim().isNotEmpty &&
        _selectedInscriptionType != null &&
        _selectedPaymentMethod != null &&
        _selectedMealPlan.isNotEmpty;

    return AlertDialog(
      backgroundColor: ProfileTheme.baseDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: ThemeColors.glassBorder),
      ),
      title: Text(
        'Inscrire un enfant',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: ProfileTheme.lightText,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ProfileTextField(
              controller: _firstNameController,
              label: 'Prénom',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            ProfileTextField(
              controller: _lastNameController,
              label: 'Nom',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final now = DateTime.now();
                final picked = await RegisterController(context).selectDate(
                  initialDate: DateTime(now.year - 3, now.month, now.day),
                  firstDate: DateTime(now.year - 5, now.month - 4, now.day),
                  lastDate: DateTime(now.year - 2, now.month, now.day),
                  tealAccent: RegisterTheme.tealAccent,
                  baseDark: RegisterTheme.baseDark,
                  lightText: RegisterTheme.lightText,
                  isLight: ThemeManager.instance.isLightMode,
                );
                if (picked != null) {
                  setState(() {
                    _birthDateController.text = picked;
                  });
                }
              },
              child: AbsorbPointer(
                child: ProfileTextField(
                  controller: _birthDateController,
                  label: 'Date de naissance',
                  keyboardType: TextInputType.datetime,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ProfileDropdown(
              value: _selectedInscriptionType,
              label: 'Type d\'inscription',
              items: widget.inscriptionTypes,
              labelMapper: (val) => val,
              onChanged: (val) => setState(() => _selectedInscriptionType = val),
            ),
            const SizedBox(height: 12),
            ProfileDropdown(
              value: _selectedPaymentMethod,
              label: 'Méthode de paiement',
              items: widget.paymentMethods,
              labelMapper: (val) => widget.paymentMethodLabel(val),
              onChanged: (val) => setState(() => _selectedPaymentMethod = val),
            ),
            const SizedBox(height: 12),
            ProfileDropdown(
              value: _selectedMealPlan,
              label: 'Repas',
              items: widget.mealPlanOptions,
              labelMapper: (val) => widget.shortMealPlanLabel(val,
                  price: widget.mealPlanFees[val]),
              onChanged: (val) => setState(() => _selectedMealPlan = val!),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: ProfileTheme.indigoAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: widget.loadingPricing
                  ? Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: ProfileTheme.indigoAccent,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : Text(
                      'Total: ${calculatedTotalAmount.toStringAsFixed(0)} TND',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: ProfileTheme.indigoAccent,
                      ),
                      textAlign: TextAlign.center,
                    ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ProfileTheme.glassBackgroundSubtle,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ProfileTheme.glassBorder),
              ),
              child: Column(
                children: [
                  if (_medicalFormData.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: ProfileTheme.tealAccent, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Dossier Médical prêt',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: ProfileTheme.tealAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ElevatedButton.icon(
                    onPressed: canOpenMedical
                        ? () async {
                            final existingData = Map<String, dynamic>.from(_medicalFormData);
                            final session = context.read<AuthSession>();
                            final existingText = Map<String, dynamic>.from(
                                (existingData['text'] as Map?)?.cast<String, dynamic>() ??
                                    <String, dynamic>{});
                            final childFirst = _firstNameController.text.trim();
                            final childLast = _lastNameController.text.trim();
                            if ((existingText['childFullName'] ?? '').toString().isEmpty &&
                                (childFirst.isNotEmpty || childLast.isNotEmpty)) {
                              existingText['childFullName'] = '$childFirst $childLast'.trim();
                            }
                            if ((existingText['birthDatePlace'] ?? '').toString().isEmpty &&
                                _birthDateController.text.isNotEmpty) {
                              existingText['birthDatePlace'] = _birthDateController.text.trim();
                            }
                            if ((existingText['nationality'] ?? '').toString().isEmpty) {
                              existingText['nationality'] = 'تونسية';
                            }
                            final parentAddr = (session.address ?? '').trim();
                            if ((existingText['address'] ?? '').toString().isEmpty &&
                                parentAddr.isNotEmpty) {
                              existingText['address'] = parentAddr;
                            }
                            existingData['text'] = existingText;

                            final existingChecks = Map<String, dynamic>.from(
                                (existingData['checks'] as Map?)?.cast<String, dynamic>() ??
                                    <String, dynamic>{});
                            for (final key in [
                              'fatherAlive',
                              'motherAlive',
                              'fatherLivesWithFamily',
                              'motherLivesWithFamily',
                            ]) {
                              if (!existingChecks.containsKey(key)) {
                                existingChecks[key] = true;
                              }
                            }
                            existingData['checks'] = existingChecks;

                            final existingSingle = Map<String, dynamic>.from(
                                (existingData['singleChoice'] as Map?)?.cast<String, dynamic>() ??
                                    <String, dynamic>{});
                            if ((existingSingle['social_position_siblings'] ?? '').toString().isEmpty) {
                              existingSingle['social_position_siblings'] = 'وحيد';
                            }
                            if ((existingSingle['social_lives_with'] ?? '').toString().isEmpty) {
                              existingSingle['social_lives_with'] = 'كلا الوالدين';
                            }
                            if ((existingSingle['social_family_relation'] ?? '').toString().isEmpty) {
                              existingSingle['social_family_relation'] = 'عادية';
                            }
                            if ((existingSingle['social_eating'] ?? '').toString().isEmpty) {
                              existingSingle['social_eating'] = 'جيد';
                            }
                            if ((existingSingle['social_sleep'] ?? '').toString().isEmpty) {
                              existingSingle['social_sleep'] = 'جيد';
                            }
                            if ((existingSingle['social_time_space'] ?? '').toString().isEmpty) {
                              existingSingle['social_time_space'] = 'طبيعي';
                            }
                            if ((existingSingle['motherPregnancyHealth'] ?? '').toString().isEmpty) {
                              existingSingle['motherPregnancyHealth'] = 'عادية';
                            }
                            if ((existingSingle['birthPlace'] ?? '').toString().isEmpty) {
                              existingSingle['birthPlace'] = 'المستشفى';
                            }
                            if ((existingSingle['birthTiming'] ?? '').toString().isEmpty) {
                              existingSingle['birthTiming'] = 'في أوانها';
                            }
                            if ((existingSingle['deliveryType'] ?? '').toString().isEmpty) {
                              existingSingle['deliveryType'] = 'عادية';
                            }
                            if ((existingSingle['healthAtBirth'] ?? '').toString().isEmpty) {
                              existingSingle['healthAtBirth'] = 'عادية';
                            }
                            existingData['singleChoice'] = existingSingle;

                            final existingMulti = Map<String, dynamic>.from(
                                (existingData['multiChoice'] as Map?)?.cast<String, dynamic>() ??
                                    <String, dynamic>{});
                            if (existingMulti['previousEnrollment'] == null) {
                              existingMulti['previousEnrollment'] = ['لا'];
                            }
                            if (existingMulti['waterSource'] == null) {
                              existingMulti['waterSource'] = ['ماء معلب'];
                            }
                            existingData['multiChoice'] = existingMulti;

                            final result = await RegisterController(context).openMedicalRecordPage(existingData);
                            if (result != null) {
                              setState(() {
                                _medicalFormData = result;
                              });
                            }
                          }
                        : null,
                    icon: Icon(
                      _medicalFormData.isNotEmpty ? Icons.edit_note : Icons.medical_services_outlined,
                      size: 18,
                      color: ProfileTheme.baseDark,
                    ),
                    label: Text(
                      _medicalFormData.isNotEmpty ? 'Modifier le dossier' : 'Dossier Médical (Requis)',
                      style: TextStyle(
                        color: ProfileTheme.baseDark,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ProfileTheme.tealAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Annuler', style: TextStyle(color: ProfileTheme.mutedText)),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_firstNameController.text.isNotEmpty &&
                _lastNameController.text.isNotEmpty &&
                _birthDateController.text.isNotEmpty &&
                _selectedInscriptionType != null &&
                _selectedPaymentMethod != null &&
                _medicalFormData.isNotEmpty) {
              final parsedDate = DateTime.tryParse(_birthDateController.text.trim());
              if (parsedDate != null) {
                final now = DateTime.now();
                int ageMonths = (now.year - parsedDate.year) * 12 + now.month - parsedDate.month;
                if (now.day < parsedDate.day) ageMonths--;
                if (ageMonths < 24 || ageMonths > 64) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('L\'âge de l\'enfant doit être compris entre 2 ans et 5 ans et 4 mois.'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }
              }

              final created = await widget.onCreateInscription(
                firstName: _firstNameController.text.trim(),
                lastName: _lastNameController.text.trim(),
                birthDate: _birthDateController.text.trim(),
                inscriptionType: _selectedInscriptionType!,
                paymentMethod: _selectedPaymentMethod!,
                mealPlan: _selectedMealPlan,
                totalAmount: calculatedTotalAmount,
                medicalForm: _medicalFormData,
              );
              if (!context.mounted) return;
              if (created) {
                Navigator.pop(context);
              }
            } else if (_medicalFormData.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('La fiche médicale est requise.'),
                  backgroundColor: Colors.red,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Veuillez remplir tous les champs obligatoires.'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ProfileTheme.indigoAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Inscrire',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
