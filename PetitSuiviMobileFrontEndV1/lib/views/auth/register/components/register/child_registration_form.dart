import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/views/themes/theme_manager.dart';
import '../../themes/register_theme.dart';
import '../common/child_glass_text_field.dart';
import '../common/child_glass_dropdown.dart';
import '../register/child_payment_method_card.dart';
import '../../controllers/register_controller.dart';

/// Form component for registering an individual child's enrollment details.
class ChildRegistrationForm extends StatefulWidget {
  final int index;
  final Map<String, dynamic> childData;
  final List<String> paymentMethods;
  final String parentAddress;
  final int totalChildren;

  const ChildRegistrationForm({
    super.key,
    required this.index,
    required this.childData,
    required this.paymentMethods,
    this.parentAddress = '',
    this.totalChildren = 1,
  });

  @override
  State<ChildRegistrationForm> createState() => _ChildRegistrationFormState();
}

class _ChildRegistrationFormState extends State<ChildRegistrationForm> {
  late RegisterController _controller;

  static const List<String> _mealPlanOptions = [
    'Mon enfant prend le déjeuner et le goûter',
    'Mon enfant prend seulement le déjeuner',
    'Mon enfant prend seulement le goûter',
    'Mon enfant ne mange pas à l\'école (le parent le récupère puis le ramène)',
  ];

  double _baseFee = 1200.0;
  bool _loadingPricing = true;
  Map<String, double> _mealPlanFees = {
    'Mon enfant prend le déjeuner et le goûter': 350.0,
    'Mon enfant prend seulement le déjeuner': 250.0,
    'Mon enfant prend seulement le goûter': 120.0,
    'Mon enfant ne mange pas à l\'école (le parent le récupère puis le ramène)':
        0.0,
  };

  static const List<String> _inscriptionTypes = [
    'Préscolaire (التحضيري)',
    'Maternelle (التمهيدي)',
  ];

  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _oldSchoolController;

  @override
  void initState() {
    super.initState();
    _controller = RegisterController(context);
    _nameController = TextEditingController(text: widget.childData['firstName']);
    _surnameController = TextEditingController(text: widget.childData['lastName']);
    _oldSchoolController = TextEditingController(text: widget.childData['oldSchool']);
    
    final initialMealPlan =
        (widget.childData['mealPlan'] as String?)?.isNotEmpty == true
        ? widget.childData['mealPlan'] as String
        : _mealPlanOptions.first;
    final initialInscriptionType =
        (widget.childData['inscriptionType'] as String?)?.isNotEmpty == true
        ? widget.childData['inscriptionType'] as String
        : _inscriptionTypes.first;
        
    widget.childData['inscriptionType'] = initialInscriptionType;
    widget.childData['mealPlan'] = initialMealPlan;
    _updateTotalPayment(initialMealPlan);
    
    final methods = widget.paymentMethods.isNotEmpty
        ? widget.paymentMethods
              .where((e) => e == 'oneShot' || e == 'monthlyPartial')
              .toList()
        : const <String>['oneShot', 'monthlyPartial'];
    
    final current = widget.childData['paymentMethod']?.toString();
    widget.childData['paymentMethod'] = methods.contains(current)
        ? current
        : methods.first;

    _loadPricing();
  }

  void _updateTotalPayment(String mealPlan) {
    widget.childData['totalPayment'] = _baseFee + (_mealPlanFees[mealPlan] ?? 0.0);
  }

  Future<void> _loadPricing() async {
    final data = await _controller.fetchPricingParameters();
    if (!mounted) return;

    if (data != null) {
      setState(() {
        if (data['baseFee'] != null) _baseFee = data['baseFee'];
        if (data['mealFees'] != null && (data['mealFees'] as Map).isNotEmpty) {
          _mealPlanFees = {
            ..._mealPlanFees,
            ...Map<String, double>.from(data['mealFees']),
          };
        }
        _loadingPricing = false;
        _updateTotalPayment(widget.childData['mealPlan'] as String? ?? '');
      });
    } else {
      setState(() => _loadingPricing = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _oldSchoolController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await _controller.selectDate(
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
        widget.childData['birthDate'] = picked;
      });
    }
  }

  Future<void> _openMedicalRecord() async {
    final childBirthStr = (widget.childData['birthDate'] ?? '').toString().trim();
    if (childBirthStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer la date de naissance de l\'enfant d\'abord.')),
      );
      return;
    }

    // Age validation
    final parsedDate = DateTime.tryParse(childBirthStr);
    if (parsedDate != null) {
      final now = DateTime.now();
      int ageMonths = (now.year - parsedDate.year) * 12 + now.month - parsedDate.month;
      if (now.day < parsedDate.day) ageMonths--;
      if (ageMonths < 24 || ageMonths > 64) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('L\'âge de l\'enfant doit être compris entre 2 ans et 5 ans et 4 mois.')),
        );
        return;
      }
    }

    final existingData = Map<String, dynamic>.from(
      (widget.childData['medicalRecordForm'] as Map<String, dynamic>?) ?? <String, dynamic>{},
    );

    // Initial pre-fill logic
    _preFillMedicalRecord(existingData);

    final result = await _controller.openMedicalRecordPage(existingData);
    if (!mounted || result == null) return;

    setState(() {
      widget.childData['medicalRecordForm'] = result;
      widget.childData['medicalRecord'] = 'Dossier médical rempli';
    });
  }

  void _preFillMedicalRecord(Map<String, dynamic> data) {
    final text = Map<String, dynamic>.from((data['text'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{});
    
    final childFirst = (widget.childData['firstName'] ?? '').toString().trim();
    final childLast = (widget.childData['lastName'] ?? '').toString().trim();
    if ((text['childFullName'] ?? '').toString().isEmpty && (childFirst.isNotEmpty || childLast.isNotEmpty)) {
      text['childFullName'] = '$childFirst $childLast'.trim();
    }

    final childBirth = (widget.childData['birthDate'] ?? '').toString().trim();
    if ((text['birthDatePlace'] ?? '').toString().isEmpty && childBirth.isNotEmpty) {
      text['birthDatePlace'] = childBirth;
    }

    if ((text['nationality'] ?? '').toString().isEmpty) text['nationality'] = 'تونسية';
    if ((text['address'] ?? '').toString().isEmpty && widget.parentAddress.isNotEmpty) {
      text['address'] = widget.parentAddress.trim();
    }

    final oldSchool = (widget.childData['oldSchool'] ?? '').toString().trim();
    if ((text['institutionStudyDuration'] ?? '').toString().isEmpty && oldSchool.isNotEmpty) {
      text['institutionStudyDuration'] = oldSchool;
    }
    data['text'] = text;

    final checks = Map<String, dynamic>.from((data['checks'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{});
    for (final key in ['fatherAlive', 'motherAlive', 'fatherLivesWithFamily', 'motherLivesWithFamily']) {
      if (!checks.containsKey(key)) checks[key] = true;
    }
    data['checks'] = checks;

    final single = Map<String, dynamic>.from((data['singleChoice'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{});
    if ((single['social_position_siblings'] ?? '').toString().isEmpty) {
      if (widget.totalChildren == 1) {
        single['social_position_siblings'] = 'وحيد';
      } else if (widget.index == 0) {
        single['social_position_siblings'] = 'الأكبر';
      } else if (widget.index == widget.totalChildren - 1) {
        single['social_position_siblings'] = 'الأصغر';
      } else {
        single['social_position_siblings'] = 'الأوسط';
      }
    }
    for (final _ in ['social_lives_with', 'social_family_relation', 'social_eating', 'social_sleep', 'social_time_space', 'motherPregnancyHealth', 'birthPlace', 'birthTiming', 'deliveryType', 'healthAtBirth']) {
       // set some defaults if needed, though they are usually handled in the page itself or here
    }
    data['singleChoice'] = single;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    final paymentMethods = widget.paymentMethods.isNotEmpty
        ? widget.paymentMethods.where((e) => e == 'oneShot' || e == 'monthlyPartial').toList()
        : const <String>['oneShot', 'monthlyPartial'];
    
    final hasMedicalRecord = ((widget.childData['medicalRecordForm'] as Map?)?.isNotEmpty ?? false);
    final totalPayment = (widget.childData['totalPayment'] as num?)?.toDouble() ?? (_baseFee + (_mealPlanFees[widget.childData['mealPlan']] ?? 0.0));

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: RegisterTheme.glassBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RegisterTheme.glassBorder, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: RegisterTheme.tealAccent.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.child_care, color: RegisterTheme.tealAccent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Enfant ${widget.index + 1}',
                      style: TextStyle(
                        color: RegisterTheme.lightText,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: AppTheme.fontName,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: RegisterTheme.glassBorder),
                const SizedBox(height: 16),

                ChildGlassTextField(
                  controller: _nameController,
                  label: 'Prénom',
                  onChanged: (v) => widget.childData['firstName'] = v,
                ),
                ChildGlassTextField(
                  controller: _surnameController,
                  label: 'Nom',
                  onChanged: (v) => widget.childData['lastName'] = v,
                ),

                GestureDetector(
                  onTap: _selectDate,
                  child: AbsorbPointer(
                    child: ChildGlassTextField(
                      controller: TextEditingController(text: widget.childData['birthDate']),
                      label: 'Date de naissance',
                      icon: Icons.calendar_today,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                ChildGlassTextField(
                  controller: _oldSchoolController,
                  label: 'Ancienne école',
                  onChanged: (v) => widget.childData['oldSchool'] = v,
                ),

                ChildGlassDropdown(
                  label: 'Type d\'inscription',
                  value: widget.childData['inscriptionType']?.toString(),
                  items: _inscriptionTypes,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => widget.childData['inscriptionType'] = value);
                  },
                ),

                ChildGlassDropdown(
                  label: 'Repas (déjeuner / goûter)',
                  value: (widget.childData['mealPlan'] as String?)?.isNotEmpty == true ? widget.childData['mealPlan'] as String : null,
                  items: _mealPlanOptions,
                  itemLabelBuilder: (option) {
                    final price = _mealPlanFees[option];
                    String shortLabel = option;
                    if (option.contains('déjeuner et le goûter')) {
                      shortLabel = 'Déjeuner + Goûter';
                    } else if (option.contains('seulement le déjeuner')) {
                      shortLabel = 'Déjeuner';
                    } else if (option.contains('seulement le goûter')) {
                      shortLabel = 'Goûter';
                    } else if (option.contains('récupère puis le ramène')) {
                      shortLabel = 'Pas de cantine';
                    }
                    
                    if (price != null && price > 0) {
                      shortLabel += ' (${price.toStringAsFixed(0)} TND)';
                    }
                    return shortLabel;
                  },
                  onChanged: (value) {
                    setState(() {
                      widget.childData['mealPlan'] = value ?? '';
                      _updateTotalPayment(widget.childData['mealPlan'] as String);
                    });
                  },
                ),

                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: RegisterTheme.tealAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: RegisterTheme.tealAccent.withValues(alpha: 0.3)),
                  ),
                  child: _loadingPricing
                      ? Center(child: CircularProgressIndicator(color: RegisterTheme.tealAccent, strokeWidth: 2))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total paiement:', style: TextStyle(fontWeight: FontWeight.w500, color: RegisterTheme.tealAccent, fontSize: 16)),
                            Text('${RegisterController.formatAmount(totalPayment)} TND', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: RegisterTheme.tealAccent)),
                          ],
                        ),
                ),
                const SizedBox(height: 24),
                Text('Méthode de paiement', style: TextStyle(fontWeight: FontWeight.bold, color: RegisterTheme.lightText, fontSize: 16, fontFamily: AppTheme.fontName)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (paymentMethods.contains('oneShot'))
                      Expanded(
                        child: ChildPaymentMethodCard(
                          selectedValue: widget.childData['paymentMethod']?.toString(),
                          onTap: (val) => setState(() => widget.childData['paymentMethod'] = val),
                          value: 'oneShot',
                          title: 'Annuel',
                          subtitle: 'Complet',
                          icon: Icons.payments_outlined,
                        ),
                      ),
                    if (paymentMethods.contains('oneShot') && paymentMethods.contains('monthlyPartial')) const SizedBox(width: 12),
                    if (paymentMethods.contains('monthlyPartial'))
                      Expanded(
                        child: ChildPaymentMethodCard(
                          selectedValue: widget.childData['paymentMethod']?.toString(),
                          onTap: (val) => setState(() => widget.childData['paymentMethod'] = val),
                          value: 'monthlyPartial',
                          title: 'Mensuel',
                          subtitle: 'Partiel',
                          icon: Icons.calendar_month_outlined,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Divider(color: RegisterTheme.glassBorder),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: RegisterTheme.glassBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: RegisterTheme.glassBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.medical_services_outlined, color: hasMedicalRecord ? RegisterTheme.tealAccent : RegisterTheme.accentColor, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          hasMedicalRecord ? 'Dossier médical rempli' : 'Dossier médical vide',
                          style: TextStyle(color: hasMedicalRecord ? RegisterTheme.lightText : RegisterTheme.mutedText),
                        ),
                      ),
                      TextButton(
                        onPressed: _openMedicalRecord,
                        child: Text(hasMedicalRecord ? 'Modifier' : 'Ajouter', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
