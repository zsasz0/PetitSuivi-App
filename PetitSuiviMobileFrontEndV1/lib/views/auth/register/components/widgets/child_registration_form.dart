import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:newv/app_theme.dart';
import 'package:newv/theme_colors.dart';
import 'child_payment_method_card.dart';
import 'child_glass_text_field.dart';
import 'child_glass_dropdown.dart';
import '../utils/child_registration_utils.dart';
import 'package:newv/theme_manager.dart';

/// Form component for registering an individual child's enrollment details.
///
/// This widget fetches live pricing depending on the selected meal plan by
/// interacting asynchronously with the application parameters backend.
///
/// **API Connectivity:**
/// - **Fetches Pricing Parameters**: `GET /api/parameters`
///   (Uses `ChildRegistrationUtils.loadPricingParameters`)
///

/// A comprehensive form for enrolling a single child.
///
/// Handles personal info, meal plan selection, and medical record linking.
/// A form widget for registering a single child's information.
///
/// This widget handles the collection of basic child data and provides a button
/// to open the exhaustive medical record page.
///
/// It receives [parentAddress] and [totalChildren] from the parent registration
/// step to enable automatic pre-filling of child medical records with sensible
/// defaults derived from the parent's input.
class ChildRegistrationForm extends StatefulWidget {
  final int index;
  final Map<String, dynamic> childData;
  final List<String> paymentMethods;

  /// The parent's address, used to pre-fill the child's medical record address.
  final String parentAddress;

  /// The total number of children being registered, used to pre-calculate
  /// the child's social position among siblings (e.g., Only Child, Eldest, Youngest).
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
  // Modern Theme Colors
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

  static const List<String> _mealPlanOptions = [
    'Mon enfant prend le déjeuner et le goûter',
    'Mon enfant prend seulement le déjeuner',
    'Mon enfant prend seulement le goûter',
    'Mon enfant ne mange pas à l\'école (le parent le récupère puis le ramène)',
  ];

  // Pricing – fetched from /api/parameters, defaults used as fallback
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

  /// Opens the child medical record page and handles data pre-filling.
  ///
  /// This method constructs the initial data map for the medical record page by
  /// analyzing the current [childData] and parent parameters. It automatically
  /// populates the following if they are currently completely empty:
  /// - **Text Fields**: Full name, birthdate, nationality (Tunisian default),
  ///   address (from parent), and previous institution/duration (from old school).
  /// - **Yes/No Checks**: Defaults `fatherAlive`, `motherAlive`,
  ///   `fatherLivesWithFamily`, and `motherLivesWithFamily` to `true`.
  /// - **Single Choices**: Calculates the child's social position based on
  ///   [index] and [totalChildren], and sets sensible defaults for social behavior.
  /// - **Multi Choices**: Sets `previousEnrollment` based on whether `oldSchool`
  ///   was provided.
  Future<void> _openMedicalRecordPage() async {
    final childBirthStr = (widget.childData['birthDate'] ?? '')
        .toString()
        .trim();
    if (childBirthStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez entrer la date de naissance de l\'enfant d\'abord.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final parsedDate = DateTime.tryParse(childBirthStr);
    if (parsedDate != null) {
      final now = DateTime.now();
      int ageMonths =
          (now.year - parsedDate.year) * 12 + now.month - parsedDate.month;
      if (now.day < parsedDate.day) {
        ageMonths--;
      }

      if (ageMonths < 24 || ageMonths > 64) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'L\'âge de l\'enfant doit être compris entre 2 ans et 5 ans et 4 mois.',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    }

    // Build the initial data, injecting pre-fill values from parent/child registration
    final existingData = Map<String, dynamic>.from(
      (widget.childData['medicalRecordForm'] as Map<String, dynamic>?) ??
          <String, dynamic>{},
    );

    // Pre-fill text fields if they haven't been filled yet
    final existingText = Map<String, dynamic>.from(
      (existingData['text'] as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{},
    );

    // childFullName: child firstName + lastName
    final childFirst = (widget.childData['firstName'] ?? '').toString().trim();
    final childLast = (widget.childData['lastName'] ?? '').toString().trim();
    if ((existingText['childFullName'] ?? '').toString().isEmpty &&
        (childFirst.isNotEmpty || childLast.isNotEmpty)) {
      existingText['childFullName'] = '$childFirst $childLast'.trim();
    }

    // birthDatePlace: child birthDate
    final childBirth = (widget.childData['birthDate'] ?? '').toString().trim();
    if ((existingText['birthDatePlace'] ?? '').toString().isEmpty &&
        childBirth.isNotEmpty) {
      existingText['birthDatePlace'] = childBirth;
    }

    // nationality: default to تونسية
    if ((existingText['nationality'] ?? '').toString().isEmpty) {
      existingText['nationality'] = 'تونسية';
    }

    // address: parent's address
    final parentAddr = widget.parentAddress.trim();
    if ((existingText['address'] ?? '').toString().isEmpty &&
        parentAddr.isNotEmpty) {
      existingText['address'] = parentAddr;
    }

    // institutionStudyDuration: child's oldSchool
    final oldSchool = (widget.childData['oldSchool'] ?? '').toString().trim();
    if ((existingText['institutionStudyDuration'] ?? '').toString().isEmpty &&
        oldSchool.isNotEmpty) {
      existingText['institutionStudyDuration'] = oldSchool;
    }

    existingData['text'] = existingText;

    // Pre-fill checks (yesNo) — only set defaults if not previously set
    final existingChecks = Map<String, dynamic>.from(
      (existingData['checks'] as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{},
    );
    // Sensible defaults: parents alive and living with family
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

    // Pre-fill singleChoice — only set defaults if not previously set
    final existingSingle = Map<String, dynamic>.from(
      (existingData['singleChoice'] as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{},
    );
    // social_position_siblings: derive from child index and total children
    if ((existingSingle['social_position_siblings'] ?? '').toString().isEmpty) {
      if (widget.totalChildren == 1) {
        existingSingle['social_position_siblings'] = 'وحيد';
      } else if (widget.index == 0) {
        existingSingle['social_position_siblings'] = 'الأكبر';
      } else if (widget.index == widget.totalChildren - 1) {
        existingSingle['social_position_siblings'] = 'الأصغر';
      } else {
        existingSingle['social_position_siblings'] = 'الأوسط';
      }
    }
    // Section 4 sensible defaults
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

    // Section 2 sensible defaults
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

    // Pre-fill multiChoice — previousEnrollment based on oldSchool
    final existingMulti = Map<String, dynamic>.from(
      (existingData['multiChoice'] as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{},
    );
    if (existingMulti['previousEnrollment'] == null) {
      if (oldSchool.isNotEmpty) {
        existingMulti['previousEnrollment'] = ['بروضة أخرى'];
      } else {
        existingMulti['previousEnrollment'] = ['لا'];
      }
    }
    if (existingMulti['waterSource'] == null) {
      existingMulti['waterSource'] = ['ماء معلب'];
    }
    existingData['multiChoice'] = existingMulti;

    final result = await ChildRegistrationUtils.openMedicalRecordPage(
      context,
      existingData,
    );
    if (!mounted || result == null) return;

    setState(() {
      widget.childData['medicalRecordForm'] = result;
      widget.childData['medicalRecord'] = 'Dossier médical rempli';
    });
  }

  /// used to load pricing parameters from the server
  Future<void> _loadPricingParameters() async {
    final data = await ChildRegistrationUtils.loadPricingParameters(
      _mealPlanOptions,
    );
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
        // Recalculate total with live prices
        final currentMeal = widget.childData['mealPlan'] as String? ?? '';
        widget.childData['totalPayment'] =
            ChildRegistrationUtils.calculateTotalPayment(
              _baseFee,
              _mealPlanFees,
              currentMeal,
            );
      });
    } else {
      setState(() => _loadingPricing = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.childData['firstName'],
    );
    _surnameController = TextEditingController(
      text: widget.childData['lastName'],
    );
    _oldSchoolController = TextEditingController(
      text: widget.childData['oldSchool'],
    );
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
    widget.childData['totalPayment'] =
        ChildRegistrationUtils.calculateTotalPayment(
          _baseFee,
          _mealPlanFees,
          initialMealPlan,
        );
    final methods = widget.paymentMethods.isNotEmpty
        ? widget.paymentMethods
              .where((e) => e == 'oneShot' || e == 'monthlyPartial')
              .toList()
        : const <String>['oneShot', 'monthlyPartial'];
    // Default to monthly if invalid method is found
    final current = widget.childData['paymentMethod']?.toString();
    widget.childData['paymentMethod'] = methods.contains(current)
        ? current
        : methods.first;

    _loadPricingParameters();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _oldSchoolController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await ChildRegistrationUtils.selectDate(context);
    if (picked != null) {
      setState(() {
        widget.childData['birthDate'] = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    final paymentMethods = widget.paymentMethods.isNotEmpty
        ? widget.paymentMethods
              .where((e) => e == 'oneShot' || e == 'monthlyPartial')
              .toList()
        : const <String>['oneShot', 'monthlyPartial'];
    final hasMedicalRecord =
        ((widget.childData['medicalRecordForm'] as Map?)?.isNotEmpty ?? false);
    final totalPayment =
        (widget.childData['totalPayment'] as num?)?.toDouble() ??
        ChildRegistrationUtils.calculateTotalPayment(
          _baseFee,
          _mealPlanFees,
          widget.childData['mealPlan'] as String? ?? '',
        );

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: ThemeColors.glassBackgroundSubtle,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ThemeColors.glassBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.shadow,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
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
                        color: _tealAccent.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.child_care,
                        color: _tealAccent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Enfant ${widget.index + 1}',
                      style: TextStyle(
                        color: _lightText,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: AppTheme.fontName,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: ThemeColors.glassBorder),
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
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: ChildGlassTextField(
                      controller: TextEditingController(
                        text: widget.childData['birthDate'],
                      ),
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
                    setState(() {
                      widget.childData['inscriptionType'] = value;
                    });
                  },
                ),

                ChildGlassDropdown(
                  label: 'Repas (déjeuner / goûter)',
                  value:
                      (widget.childData['mealPlan'] as String?)?.isNotEmpty ==
                          true
                      ? widget.childData['mealPlan'] as String
                      : null,
                  items: _mealPlanOptions,
                  itemLabelBuilder: (option) {
                    final price = _mealPlanFees[option];
                    String shortLabel = option;
                    if (option.contains('récupère puis le ramène')) {
                      shortLabel = 'Pas de cantine (Maison)';
                    } else if (option.contains('déjeuner et le goûter')) {
                      shortLabel = 'Déjeuner + Goûter';
                    } else if (option.contains('seulement le déjeuner')) {
                      shortLabel = 'Uniquement Déjeuner';
                    } else if (option.contains('seulement le goûter')) {
                      shortLabel = 'Uniquement Goûter';
                    }
                    if (price != null && price > 0) {
                      shortLabel += ' (${price.toStringAsFixed(0)} TND)';
                    } else if (price != null && price == 0) {
                      shortLabel += ' (Gratuit)';
                    }
                    return shortLabel;
                  },
                  onChanged: (value) {
                    setState(() {
                      widget.childData['mealPlan'] = value ?? '';
                      widget.childData['totalPayment'] =
                          ChildRegistrationUtils.calculateTotalPayment(
                            _baseFee,
                            _mealPlanFees,
                            widget.childData['mealPlan'] as String,
                          );
                    });
                  },
                ),

                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: _tealAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _tealAccent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: _loadingPricing
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _tealAccent,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Calcul du montant…',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: _tealAccent,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total paiement:',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: _tealAccent,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${ChildRegistrationUtils.formatAmount(totalPayment)} TND',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: _tealAccent,
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Méthode de paiement',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _lightText,
                    fontSize: 16,
                    fontFamily: AppTheme.fontName,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (paymentMethods.contains('oneShot'))
                      Expanded(
                        child: ChildPaymentMethodCard(
                          selectedValue: widget.childData['paymentMethod']
                              ?.toString(),
                          onTap: (val) {
                            setState(() {
                              widget.childData['paymentMethod'] = val;
                            });
                          },
                          value: 'oneShot',
                          title: 'Annuel',
                          subtitle: 'Paiement complet',
                          icon: Icons.payments_outlined,
                        ),
                      ),
                    if (paymentMethods.contains('oneShot') &&
                        paymentMethods.contains('monthlyPartial'))
                      const SizedBox(width: 12),
                    if (paymentMethods.contains('monthlyPartial'))
                      Expanded(
                        child: ChildPaymentMethodCard(
                          selectedValue: widget.childData['paymentMethod']
                              ?.toString(),
                          onTap: (val) {
                            setState(() {
                              widget.childData['paymentMethod'] = val;
                            });
                          },
                          value: 'monthlyPartial',
                          title: 'Mensuel',
                          subtitle: 'Paiements partiels',
                          icon: Icons.calendar_month_outlined,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Divider(color: ThemeColors.glassBorder),
                const SizedBox(height: 16),

                // Medical record
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ThemeColors.glassBorderSubtle,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ThemeColors.glassBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: hasMedicalRecord
                              ? _tealAccent.withValues(alpha: 0.2)
                              : _indigoAccent.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.medical_services_outlined,
                          color: hasMedicalRecord ? _tealAccent : _indigoAccent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          hasMedicalRecord
                              ? 'Dossier médical rempli'
                              : 'Dossier médical non rempli',
                          style: TextStyle(
                            color: hasMedicalRecord ? _lightText : _mutedText,
                            fontWeight: hasMedicalRecord
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: _openMedicalRecordPage,
                        style: TextButton.styleFrom(
                          foregroundColor: hasMedicalRecord
                              ? _tealAccent
                              : _indigoAccent,
                        ),
                        child: Text(
                          hasMedicalRecord ? 'Modifier' : 'Ajouter',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
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
