import 'package:newv/utils/api_constants.dart';
import 'dart:convert';
import 'dart:ui';

import 'package:newv/app_theme.dart';
import 'package:newv/l10n/app_localizations.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/utils/unauthorized_handler.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:newv/theme_manager.dart';
import 'package:newv/theme_colors.dart';

// File: re_registration_page.dart
// Purpose: Specialized form for returning students to re-enroll for the new year.
// Usage: Navigated from ChildSelectionPage when status is 'inscription_requise'.
// API Usage:
//   - GET /api/parameters (Load pricing)
//   - POST /api/parents/{cin}/children (Submit inscription)
// Dependencies: AuthSession, UnauthorizedHandler, ApiConstants.

/// A lightweight registration form specifically for existing students.
class ReRegistrationPage extends StatefulWidget {
  final int childId;
  final String firstName;
  final String lastName;
  final String birthDate;

  const ReRegistrationPage({
    super.key,
    required this.childId,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
  });

  @override
  State<ReRegistrationPage> createState() => _ReRegistrationPageState();
}

class _ReRegistrationPageState extends State<ReRegistrationPage> {
  static const String _apiBaseUrl = ApiConstants.baseUrl;

  // ── Theme ──
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

  // ── Form state ──
  String? _selectedInscriptionType;
  String _selectedMealPlan = '';
  String? _selectedPaymentMethod;
  bool _isSubmitting = false;

  // ── Pricing & options (loaded from API) ──
  double _baseFee = 1200.0;

  List<String> _inscriptionTypes = [
    'Préscolaire (التحضيري)',
    'Maternelle (التمهيدي)',
  ];
  List<String> _mealPlanOptions = [
    'Mon enfant prend le déjeuner et le goûter',
    'Mon enfant prend seulement le déjeuner',
    'Mon enfant prend seulement le goûter',
    'Mon enfant ne mange pas à l\'école (le parent le récupère puis le ramène)',
  ];
  Map<String, double> _mealPlanFees = {
    'Mon enfant prend le déjeuner et le goûter': 350.0,
    'Mon enfant prend seulement le déjeuner': 250.0,
    'Mon enfant prend seulement le goûter': 120.0,
    'Mon enfant ne mange pas à l\'école (le parent le récupère puis le ramène)':
        0.0,
  };
  List<String> _paymentMethods = ['oneShot', 'monthlyPartial'];
  bool _loadingPricing = true;

  @override
  void initState() {
    super.initState();
    _loadPricingAndOptions();
  }

  /// Strips accents/diacritics and lowercases a string for fuzzy key matching.
  String _normalizeKey(String s) {
    const accents = 'àâäéèêëîïôùûüç';
    const plain = 'aaaeeeeiiouu uc';
    final buf = StringBuffer();
    for (final ch in s.toLowerCase().runes) {
      final c = String.fromCharCode(ch);
      final idx = accents.indexOf(c);
      buf.write(idx >= 0 ? plain[idx] : c);
    }
    return buf.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  Future<void> _loadPricingAndOptions() async {
    // Defaults are already set. Try loading live prices.
    _selectedMealPlan = _mealPlanOptions.first;
    _selectedInscriptionType = _inscriptionTypes.first;

    final session = context.read<AuthSession>();
    final token = session.token;

    if (token == null || token.isEmpty) {
      setState(() => _loadingPricing = false);
      return;
    }

    try {
      final pricingUri = Uri.parse('$_apiBaseUrl/api/parameters');
      final response = await http.get(
        pricingUri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final raw = response.body.isNotEmpty ? jsonDecode(response.body) : null;
        final list = raw is List ? raw : (raw is Map ? raw['data'] : null);

        if (list is List) {
          double? baseFee;
          final Map<String, double> mealFees = {};

          for (final item in list) {
            if (item is! Map) continue;
            final name = item['name']?.toString() ?? '';
            final value = double.tryParse(item['value']?.toString() ?? '');
            if (value == null) continue;

            final normName = _normalizeKey(name);

            if (normName == _normalizeKey('Prix de base')) {
              baseFee = value;
            } else {
              String? matchedOption;
              if (normName.contains('dejeuner et le gouter')) {
                matchedOption = _mealPlanOptions[0];
              } else if (normName.contains('seulement le dejeuner')) {
                matchedOption = _mealPlanOptions[1];
              } else if (normName.contains('seulement le gouter')) {
                matchedOption = _mealPlanOptions[2];
              } else if (normName.contains('ne mange pas')) {
                matchedOption = _mealPlanOptions[3];
              }

              if (matchedOption != null) {
                mealFees[matchedOption] = value;
              }
            }
          }

          if (baseFee != null) _baseFee = baseFee;
          if (mealFees.isNotEmpty) {
            _mealPlanFees = {..._mealPlanFees, ...mealFees};
          }
        }
      }
    } catch (_) {}

    // Inscription types are hardcoded to match the main registration form.
    if (_inscriptionTypes.isNotEmpty && _selectedInscriptionType == null) {
      _selectedInscriptionType = _inscriptionTypes.first;
    }

    if (mounted) setState(() => _loadingPricing = false);
  }

  double _calculateTotal() {
    return _baseFee + (_mealPlanFees[_selectedMealPlan] ?? 0.0);
  }

  String _paymentMethodLabel(String method) {
    switch (method) {
      case 'oneShot':
        return 'Annuel (En une seule fois)';
      case 'monthlyPartial':
        return 'Mensuel (Chaque mois)';
      default:
        return method;
    }
  }

  Future<void> _submitReRegistration() async {
    if (_selectedInscriptionType == null ||
        _selectedPaymentMethod == null ||
        _selectedMealPlan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final session = context.read<AuthSession>();
    final token = session.token;
    final parentCin = session.cin;

    if (token == null || token.isEmpty || parentCin == null) {
      setState(() => _isSubmitting = false);
      return;
    }

    final uri = Uri.parse(
      '$_apiBaseUrl/api/parents/$parentCin/children/${widget.childId}/re-register',
    );

    final payload = <String, dynamic>{
      'payment_method': _selectedPaymentMethod,
      'meal_plan': _selectedMealPlan,
      'total_amount': _calculateTotal(),
      'insc_date': DateTime.now().toIso8601String().split('T').first,
    };

    try {
      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
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

      if (response.statusCode >= 200 && response.statusCode < 300) {
        context.read<AuthSession>().bumpChildrenVersion();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.firstName} a été ré-inscrit(e) avec succès ! En attente d\'approbation.',
            ),
            backgroundColor: Colors.green.shade800,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              body['message']?.toString() ?? 'Échec de la ré-inscription.',
            ),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur réseau. Vérifiez votre connexion.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: _baseDark,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Ré-inscription',
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
          iconTheme: IconThemeData(color: _lightText),
        ),
        body: _loadingPricing
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(_tealAccent),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Child Info (read-only) ──
                    _buildSectionCard(
                      icon: Icons.face_retouching_natural_rounded,
                      title: 'Enfant',
                      child: Column(
                        children: [
                          _buildReadOnlyRow('Prénom', widget.firstName),
                          _buildReadOnlyRow('Nom', widget.lastName),
                          _buildReadOnlyRow(
                            'Date de naissance',
                            widget.birthDate,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Medical Notice ──
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _tealAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _tealAccent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.medical_information,
                            color: _tealAccent,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Le dossier médical de l\'année précédente sera automatiquement réutilisé.',
                              style: TextStyle(
                                fontFamily: AppTheme.fontName,
                                fontSize: 13,
                                color: _tealAccent.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Inscription Form ──
                    _buildSectionCard(
                      icon: Icons.school_outlined,
                      title: 'Nouvelle inscription',
                      child: Column(
                        children: [
                          _buildDropdown(
                            value: _selectedInscriptionType,
                            label: 'Type d\'inscription',
                            items: _inscriptionTypes,
                            onChanged: (val) =>
                                setState(() => _selectedInscriptionType = val),
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(
                            value: _selectedMealPlan.isNotEmpty
                                ? _selectedMealPlan
                                : null,
                            label: 'Plan de repas',
                            items: _mealPlanOptions,
                            onChanged: (val) =>
                                setState(() => _selectedMealPlan = val ?? ''),
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(
                            value: _selectedPaymentMethod,
                            label: 'Méthode de paiement',
                            items: _paymentMethods,
                            isPaymentMethod: true,
                            onChanged: (val) =>
                                setState(() => _selectedPaymentMethod = val),
                          ),
                          const SizedBox(height: 20),

                          // Total
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: _indigoAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Total : ${_calculateTotal().toStringAsFixed(0)} TND',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: _indigoAccent,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Submit Button ──
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitReRegistration,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _tealAccent,
                          foregroundColor: _baseDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: _baseDark,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Inscrire pour la nouvelle année',
                                style: TextStyle(
                                  fontFamily: AppTheme.fontName,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ThemeColors.glassBorderSubtle,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ThemeColors.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: _tealAccent, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppTheme.fontName,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _lightText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                fontSize: 13,
                color: _mutedText,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: _lightText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatMealPlan(String option) {
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

    final price = _mealPlanFees[option];
    if (price != null && price > 0) {
      shortLabel += ' (${price.toStringAsFixed(0)} TND)';
    } else if (price != null && price == 0) {
      shortLabel += ' (Gratuit)';
    }
    return shortLabel;
  }

  Widget _buildDropdown({
    required String? value,
    required String label,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool isPaymentMethod = false,
  }) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: value,
      dropdownColor: _baseDark.withValues(alpha: 0.95),
      icon: Icon(Icons.arrow_drop_down, color: _mutedText),
      style: TextStyle(color: _lightText),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: _mutedText, fontSize: 14),
        filled: true,
        fillColor: ThemeColors.glassBorderSubtle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      items: items.map((item) {
        String displayLabel = item;
        if (isPaymentMethod) {
          displayLabel = _paymentMethodLabel(item);
        } else if (label == 'Plan de repas') {
          displayLabel = _formatMealPlan(item);
        }

        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            displayLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
