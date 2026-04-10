import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:newv/utils/api_constants.dart';
import 'package:newv/views/auth/login/login_page.dart';

import 'package:newv/app_theme.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/utils/unauthorized_handler.dart';

import 'package:newv/views/auth/register/components/utils/child_registration_utils.dart';

import './parent_profile_edit_page.dart';
import './child_profile_view_page.dart';
import 'package:newv/theme_manager.dart';
import 'package:newv/theme_colors.dart';

// File: parent_profile_page.dart
// Purpose: Central profile management for parents, including child enrollment.
// Usage: Top-level profile screen.
// API Usage:
//   - GET /api/parameters (Fetch pricing/open dates)
//   - GET /api/payment-methods (Fetch available payment options)
//   - GET /api/parents/{cin}/children (Fetch children list)
//   - POST /api/parents/{cin}/children (Register new child)
//   - POST /api/password/change (Account security)
// Dependencies: AuthSession, UnauthorizedHandler, ApiConstants, ChildMedicalRecordPage.

/// A comprehensive settings and profile page for Parent users.
class ParentProfilePage extends StatefulWidget {
  const ParentProfilePage({super.key});

  @override
  State<ParentProfilePage> createState() => _ParentProfilePageState();
}

class _ParentProfilePageState extends State<ParentProfilePage> {
  static const String _apiBaseUrl = ApiConstants.baseUrl;
  static const List<String> _defaultPaymentMethods = [
    'oneShot',
    'monthlyPartial',
  ];

  final List<Map<String, dynamic>> _children = [];
  List<String> _paymentMethods = _defaultPaymentMethods;
  bool _isLoadingChildren = true;
  int _lastSeenSyncVersion = -1;

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

  static Color get _orangeAccent => ThemeManager.instance.isLightMode
      ? Colors.orange.shade700
      : Colors.orangeAccent;
  static Color get _redAccent => ThemeManager.instance.isLightMode
      ? Colors.red.shade700
      : Colors.redAccent;

  // Pricing – loaded dynamically from /api/parameters
  double _baseFee = 1200.0;
  bool _loadingPricing = true;
  bool _inscriptionsOpen = true; // gate for registration
  Map<String, double> _mealPlanFees = {
    'Mon enfant prend le déjeuner et le goûter': 350.0,
    'Mon enfant prend seulement le déjeuner': 250.0,
    'Mon enfant prend seulement le goûter': 120.0,
    'Mon enfant ne mange pas à l\'école (le parent le récupère puis le ramène)':
        0.0,
  };

  static const List<String> _mealPlanOptions = [
    'Mon enfant prend le déjeuner et le goûter',
    'Mon enfant prend seulement le déjeuner',
    'Mon enfant prend seulement le goûter',
    'Mon enfant ne mange pas à l\'école (le parent le récupère puis le ramène)',
  ];
  static const List<String> _inscriptionTypes = [
    'Préscolaire (التحضيري)',
    'Maternelle (التمهيدي)',
  ];

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
    _loadPricingParameters();
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

  Future<void> _loadPricingParameters() async {
    final uri = Uri.parse('$_apiBaseUrl/api/parameters');
    try {
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );
      if (!mounted) return;

      final raw = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      final list = raw is List ? raw : (raw is Map ? raw['data'] : null);
      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          list is List) {
        double? baseFee;
        final Map<String, double> mealFees = {};

        for (final item in list) {
          if (item is! Map) continue;
          final name = item['name']?.toString() ?? '';
          final rawValue = item['value']?.toString() ?? '';

          if (name == 'inscriptions_open') {
            if (mounted) {
              setState(() {
                _inscriptionsOpen = rawValue == 'true' || rawValue == '1';
              });
            }
            continue;
          }

          final value = double.tryParse(rawValue);
          if (value == null) continue;

          final normName = _normalizeKey(name);

          if (normName == _normalizeKey('Prix de base')) {
            baseFee = value;
          } else {
            // Map DB name to Option
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

        if (!mounted) return;
        setState(() {
          if (baseFee != null) _baseFee = baseFee;
          if (mealFees.isNotEmpty)
            _mealPlanFees = {..._mealPlanFees, ...mealFees};
          _loadingPricing = false;
        });
      } else {
        if (mounted) setState(() => _loadingPricing = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingPricing = false);
    }
  }

  Future<void> _loadPaymentMethods() async {
    final uri = Uri.parse('$_apiBaseUrl/api/payment-methods');
    try {
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );
      if (!mounted) return;

      final body = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      final data = body['data'];
      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          data is List) {
        final methods = data
            .map((e) => e.toString())
            .where(
              (e) => e == 'oneShot' || e == 'monthlyPartial',
            ) // Only allow yearly and monthly
            .toList();
        if (methods.isNotEmpty) {
          final mergedMethods = <String>[
            ..._defaultPaymentMethods,
            ...methods,
          ].toSet().toList();
          setState(() => _paymentMethods = mergedMethods);
        }
      }
    } catch (_) {
      // Keep defaults if endpoint is unavailable.
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentVersion = context.watch<AuthSession>().syncVersion;
    if (currentVersion != _lastSeenSyncVersion) {
      _lastSeenSyncVersion = currentVersion;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadChildren());
    }
  }

  /// this function is used to load the children of the parent
  Future<void> _loadChildren() async {
    if (!mounted) return;

    final session = context.read<AuthSession>();
    final token = session.token;
    final parentCin = session.cin;

    if (token == null || token.isEmpty || parentCin == null) {
      if (!mounted) return;
      setState(() => _isLoadingChildren = false);
      return;
    }

    final uri = Uri.parse('$_apiBaseUrl/api/parents/$parentCin/children');

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
        final mapped = (body['data'] as List).whereType<Map>().map((item) {
          final map = item.cast<String, dynamic>();
          final inscriptions = (map['inscriptions'] is List)
              ? map['inscriptions'] as List
              : const [];
          return <String, dynamic>{
            'firstName': map['firstName']?.toString() ?? '',
            'lastName': map['lastName']?.toString() ?? '',
            'birthDate': map['birthdate']?.toString(),
            'description': '',
            'medicalRecord': null,
            'extraData': {'inscriptions': inscriptions},
          };
        }).toList();

        setState(() {
          _children
            ..clear()
            ..addAll(mapped);
          _isLoadingChildren = false;
        });
      } else {
        setState(() => _isLoadingChildren = false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingChildren = false);
    }
  }

  Future<bool> _createChildInscription({
    required String firstName,
    required String lastName,
    required String birthDate,
    required String inscriptionType,
    required String paymentMethod,
    required String mealPlan,
    required double totalAmount,
    Map<String, dynamic>? medicalForm,
  }) async {
    final session = context.read<AuthSession>();
    final token = session.token;
    final parentCin = session.cin;

    if (token == null || token.isEmpty || parentCin == null) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session invalide. Reconnectez-vous.')),
      );
      return false;
    }

    final uri = Uri.parse('$_apiBaseUrl/api/parents/$parentCin/children');

    final payload = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'birthdate': birthDate,
      'inscription_type': inscriptionType,
      'payment_method': paymentMethod,
      'meal_plan': mealPlan,
      'total_amount': totalAmount,
      'insc_date': DateTime.now().toIso8601String().split('T').first,
    };
    if (medicalForm != null && medicalForm.isNotEmpty) {
      payload['medical_form'] = medicalForm;
    }

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

      if (!mounted) return false;
      if (UnauthorizedHandler.handle(
        context: context,
        statusCode: response.statusCode,
      ))
        return false;

      final body = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        context.read<AuthSession>().bumpChildrenVersion();
        await _loadChildren();
        return true;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            body['message']?.toString() ?? 'Échec de l\'inscription.',
          ),
        ),
      );
      return false;
    } catch (_) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur réseau lors de l\'inscription de l\'enfant.'),
        ),
      );
      return false;
    }
  }

  Future<void> _showChangePasswordDialog() async {
    // Capture from OUTER context before the dialog opens
    final session = context.read<AuthSession>();
    final token = session.token;
    final outerMessenger = ScaffoldMessenger.of(context);

    String newPassword = '';
    String confirmPassword = '';
    bool isSaving = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: _baseDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: ThemeColors.glassBorder),
            ),
            title: Text(
              'Changer mot de passe',
              style: TextStyle(color: _lightText),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (val) => newPassword = val,
                  obscureText: true,
                  style: TextStyle(color: _lightText),
                  decoration: InputDecoration(
                    labelText: 'Nouveau mot de passe',
                    labelStyle: TextStyle(color: _mutedText),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: ThemeColors.glassBorderWithOpacity(0.3),
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: _tealAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (val) => confirmPassword = val,
                  obscureText: true,
                  style: TextStyle(color: _lightText),
                  decoration: InputDecoration(
                    labelText: 'Confirmer le mot de passe',
                    labelStyle: TextStyle(color: _mutedText),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: ThemeColors.glassBorderWithOpacity(0.3),
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: _tealAccent),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(dialogCtx),
                child: Text('Annuler', style: TextStyle(color: _mutedText)),
              ),
              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        final pwd = newPassword.trim();

                        if (pwd.isEmpty) {
                          outerMessenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Le mot de passe ne peut pas être vide.',
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        if (pwd.length < 8) {
                          outerMessenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Le mot de passe doit contenir au moins 8 caractères.',
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        if (!pwd.contains(RegExp(r'[A-Z]'))) {
                          outerMessenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Le mot de passe doit contenir au moins une lettre majuscule.',
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }
                        if (!pwd.contains(RegExp(r'[a-z]'))) {
                          outerMessenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Le mot de passe doit contenir au moins une lettre minuscule.',
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }
                        if (!pwd.contains(RegExp(r'[0-9]'))) {
                          outerMessenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Le mot de passe doit contenir au moins un chiffre.',
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }
                        if (!pwd.contains(RegExp(r'[^A-Za-z0-9]'))) {
                          outerMessenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Le mot de passe doit contenir au moins un symbole.',
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        if (pwd != confirmPassword.trim()) {
                          outerMessenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Les deux mots de passe doivent être identiques.',
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        setState(() => isSaving = true);

                        await _changePassword(
                          newPassword: pwd,
                          token: token,
                          messenger: outerMessenger,
                        );

                        if (context.mounted) {
                          Navigator.pop(dialogCtx);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _indigoAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Changer',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _changePassword({
    required String newPassword,
    required String? token,
    required ScaffoldMessengerState messenger,
  }) async {
    if (token == null || token.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Session invalide. Reconnectez-vous.')),
      );
      return;
    }

    final uri = Uri.parse('$_apiBaseUrl/api/password/change');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'new_password': newPassword}),
      );

      final body = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              body['message']?.toString() ?? 'Mot de passe modifié.',
            ),
            backgroundColor: Colors.green.shade800,
          ),
        );
        return;
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            body['message']?.toString() ??
                'Échec du changement de mot de passe.',
          ),
          backgroundColor: Colors.red.shade800,
        ),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Erreur réseau.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  double _calculateTotalAmount(String mealPlan) {
    return _baseFee + (_mealPlanFees[mealPlan] ?? 0.0);
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

  String _shortMealPlanLabel(String plan, {double? price}) {
    String label;
    if (plan.contains('récupère puis le ramène')) {
      label = 'Pas de cantine (Maison)';
    } else if (plan.contains('déjeuner et le goûter')) {
      label = 'Déjeuner + Goûter';
    } else if (plan.contains('seulement le déjeuner')) {
      label = 'Uniquement Déjeuner';
    } else if (plan.contains('seulement le goûter')) {
      label = 'Uniquement Goûter';
    } else {
      label = plan;
    }
    if (price != null && price > 0) {
      label += ' (${price.toStringAsFixed(0)} TND)';
    } else if (price != null && price == 0) {
      label += ' (Gratuit)';
    }
    return label;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return Container(
      color: _baseDark,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Mon Profil',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: _lightText,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: 100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 32),
              _buildInfoCard(),
              const SizedBox(height: 24),
              _buildChildrenSection(),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final session = context.watch<AuthSession>();

    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ThemeColors.glassBackgroundSubtle,
            border: Border.all(color: ThemeColors.glassBorder),
            boxShadow: [
              BoxShadow(
                color: _tealAccent.withValues(alpha: 0.2),
                blurRadius: 20,
              ),
            ],
          ),
          child: Icon(
            Icons.person_outline_rounded,
            size: 40,
            color: _tealAccent,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          session.fullName,
          style: TextStyle(
            fontFamily: AppTheme.fontName,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: _lightText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          (session.email?.isNotEmpty ?? false)
              ? session.email!
              : 'parent@example.com',
          style: TextStyle(
            fontFamily: AppTheme.fontName,
            fontSize: 14,
            color: _mutedText,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    final session = context.watch<AuthSession>();

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ThemeColors.glassBackgroundSubtle,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ThemeColors.glassBorder),
          ),
          child: Column(
            children: [
              _buildInfoRow(
                Icons.phone_outlined,
                'Téléphone',
                (session.phone?.isNotEmpty ?? false) ? session.phone! : '-',
              ),
              Divider(height: 32, color: ThemeColors.divider),
              _buildInfoRow(
                Icons.location_on_outlined,
                'Adresse',
                (session.address?.isNotEmpty ?? false) ? session.address! : '-',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _indigoAccent.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: _indigoAccent, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  fontSize: 13,
                  color: _mutedText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _lightText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChildrenSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Mes Enfants',
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: _lightText,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _tealAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_children.length}',
                    style: TextStyle(
                      fontFamily: AppTheme.fontName,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: _tealAccent,
                    ),
                  ),
                ),
              ],
            ),
            if (_inscriptionsOpen)
              TextButton.icon(
                onPressed: _showAddChildDialog,
                icon: Icon(
                  Icons.add_circle_outline_rounded,
                  color: _tealAccent,
                  size: 20,
                ),
                label: Text(
                  'Ajouter',
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    fontWeight: FontWeight.bold,
                    color: _tealAccent,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  backgroundColor: _tealAccent.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoadingChildren)
          Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_tealAccent),
            ),
          )
        else if (_children.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ThemeColors.glassBackgroundSubtle,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ThemeColors.glassBorderSubtle,
                style: BorderStyle.solid,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              'Aucun enfant trouvé.',
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                color: _mutedText,
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _children.length,
            itemBuilder: (context, index) {
              final child = _children[index];
              return _buildChildCard(child);
            },
          ),
      ],
    );
  }

  Widget _buildChildCard(Map<String, dynamic> child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ThemeColors.glassBackgroundSubtle,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.glassBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChildProfileViewPage(childData: child),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _tealAccent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.face_retouching_natural_rounded,
                    color: _tealAccent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${child['firstName']} ${child['lastName']}',
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _lightText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Date de naissance: ${child['birthDate']}',
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontSize: 13,
                          color: _mutedText.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: _mutedText.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddChildDialog() {
    // Basic conversion of the existing dialog to dark mode.
    // For a real app, this should probably be its own widget file if it gets complex.
    final TextEditingController firstNameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final TextEditingController birthDateController = TextEditingController();
    String? selectedInscriptionType;
    String? selectedPaymentMethod = _paymentMethods.isNotEmpty
        ? _paymentMethods.first
        : null;
    String selectedMealPlan = _mealPlanOptions.first;
    Map<String, dynamic> medicalFormData = <String, dynamic>{};

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final double calculatedTotalAmount = _calculateTotalAmount(
              selectedMealPlan,
            );
            final bool canOpenMedical =
                firstNameController.text.trim().isNotEmpty &&
                lastNameController.text.trim().isNotEmpty &&
                birthDateController.text.trim().isNotEmpty &&
                selectedInscriptionType != null &&
                selectedPaymentMethod != null &&
                selectedMealPlan.isNotEmpty;

            return AlertDialog(
              backgroundColor: _baseDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: ThemeColors.glassBorder),
              ),
              title: Text(
                'Inscrire un enfant',
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  fontWeight: FontWeight.bold,
                  color: _lightText,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDarkTextField(
                      firstNameController,
                      'Prénom',
                      onChanged: (_) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 12),
                    _buildDarkTextField(
                      lastNameController,
                      'Nom',
                      onChanged: (_) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        final picked = await ChildRegistrationUtils.selectDate(
                          context,
                        );
                        if (picked != null) {
                          setDialogState(() {
                            birthDateController.text = picked;
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: _buildDarkTextField(
                          birthDateController,
                          'Date de naissance',
                          keyboardType: TextInputType.datetime,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Adding child details is complex. Minimal dark mode styling applied to old fields:
                    _buildDarkDropdown(
                      value: selectedInscriptionType,
                      label: 'Type d\'inscription',
                      items: _inscriptionTypes,
                      onChanged: (val) =>
                          setDialogState(() => selectedInscriptionType = val),
                    ),
                    const SizedBox(height: 12),
                    _buildDarkDropdown(
                      value: selectedPaymentMethod,
                      label: 'Méthode de paiement',
                      items: _paymentMethods,
                      isObjMap: true,
                      onChanged: (val) =>
                          setDialogState(() => selectedPaymentMethod = val),
                    ),
                    const SizedBox(height: 12),
                    _buildDarkDropdown(
                      value: selectedMealPlan,
                      label: 'Repas',
                      items: _mealPlanOptions,
                      isMealPlan: true,
                      onChanged: (val) =>
                          setDialogState(() => selectedMealPlan = val!),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _indigoAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _loadingPricing
                          ? Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: _indigoAccent,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : Text(
                              'Total: ${calculatedTotalAmount.toStringAsFixed(0)} TND',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _indigoAccent,
                              ),
                              textAlign: TextAlign.center,
                            ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ThemeColors.glassBackgroundSubtle,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ThemeColors.glassBorder),
                      ),
                      child: Column(
                        children: [
                          if (medicalFormData.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: _tealAccent,
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Dossier Médical prêt',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: _tealAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ElevatedButton.icon(
                            onPressed: canOpenMedical
                                ? () async {
                                    // Build pre-filled data mirroring registration flow
                                    final existingData =
                                        Map<String, dynamic>.from(
                                          medicalFormData,
                                        );
                                    final session = context.read<AuthSession>();

                                    // Pre-fill text fields
                                    final existingText =
                                        Map<String, dynamic>.from(
                                          (existingData['text'] as Map?)
                                                  ?.cast<String, dynamic>() ??
                                              <String, dynamic>{},
                                        );
                                    final childFirst = firstNameController.text
                                        .trim();
                                    final childLast = lastNameController.text
                                        .trim();
                                    if ((existingText['childFullName'] ?? '')
                                            .toString()
                                            .isEmpty &&
                                        (childFirst.isNotEmpty ||
                                            childLast.isNotEmpty)) {
                                      existingText['childFullName'] =
                                          '$childFirst $childLast'.trim();
                                    }
                                    if ((existingText['birthDatePlace'] ?? '')
                                            .toString()
                                            .isEmpty &&
                                        birthDateController.text.isNotEmpty) {
                                      existingText['birthDatePlace'] =
                                          birthDateController.text.trim();
                                    }
                                    if ((existingText['nationality'] ?? '')
                                        .toString()
                                        .isEmpty) {
                                      existingText['nationality'] = 'تونسية';
                                    }
                                    final parentAddr = (session.address ?? '')
                                        .trim();
                                    if ((existingText['address'] ?? '')
                                            .toString()
                                            .isEmpty &&
                                        parentAddr.isNotEmpty) {
                                      existingText['address'] = parentAddr;
                                    }
                                    existingData['text'] = existingText;

                                    // Pre-fill checks (yesNo) defaults
                                    final existingChecks =
                                        Map<String, dynamic>.from(
                                          (existingData['checks'] as Map?)
                                                  ?.cast<String, dynamic>() ??
                                              <String, dynamic>{},
                                        );
                                    for (final key in [
                                      'fatherAlive',
                                      'motherAlive',
                                      'fatherLivesWithFamily',
                                      'motherLivesWithFamily',
                                    ]) {
                                      if (!existingChecks.containsKey(key))
                                        existingChecks[key] = true;
                                    }
                                    existingData['checks'] = existingChecks;

                                    // Pre-fill singleChoice defaults
                                    final existingSingle =
                                        Map<String, dynamic>.from(
                                          (existingData['singleChoice'] as Map?)
                                                  ?.cast<String, dynamic>() ??
                                              <String, dynamic>{},
                                        );
                                    if ((existingSingle['social_position_siblings'] ??
                                            '')
                                        .toString()
                                        .isEmpty) {
                                      existingSingle['social_position_siblings'] =
                                          'وحيد';
                                    }
                                    if ((existingSingle['social_lives_with'] ??
                                            '')
                                        .toString()
                                        .isEmpty)
                                      existingSingle['social_lives_with'] =
                                          'كلا الوالدين';
                                    if ((existingSingle['social_family_relation'] ??
                                            '')
                                        .toString()
                                        .isEmpty)
                                      existingSingle['social_family_relation'] =
                                          'عادية';
                                    if ((existingSingle['social_eating'] ?? '')
                                        .toString()
                                        .isEmpty)
                                      existingSingle['social_eating'] = 'جيد';
                                    if ((existingSingle['social_sleep'] ?? '')
                                        .toString()
                                        .isEmpty)
                                      existingSingle['social_sleep'] = 'جيد';
                                    if ((existingSingle['social_time_space'] ??
                                            '')
                                        .toString()
                                        .isEmpty)
                                      existingSingle['social_time_space'] =
                                          'طبيعي';
                                    if ((existingSingle['motherPregnancyHealth'] ??
                                            '')
                                        .toString()
                                        .isEmpty)
                                      existingSingle['motherPregnancyHealth'] =
                                          'عادية';
                                    if ((existingSingle['birthPlace'] ?? '')
                                        .toString()
                                        .isEmpty)
                                      existingSingle['birthPlace'] = 'المستشفى';
                                    if ((existingSingle['birthTiming'] ?? '')
                                        .toString()
                                        .isEmpty)
                                      existingSingle['birthTiming'] =
                                          'في أوانها';
                                    if ((existingSingle['deliveryType'] ?? '')
                                        .toString()
                                        .isEmpty)
                                      existingSingle['deliveryType'] = 'عادية';
                                    if ((existingSingle['healthAtBirth'] ?? '')
                                        .toString()
                                        .isEmpty)
                                      existingSingle['healthAtBirth'] = 'عادية';
                                    existingData['singleChoice'] =
                                        existingSingle;

                                    // Pre-fill multiChoice
                                    final existingMulti =
                                        Map<String, dynamic>.from(
                                          (existingData['multiChoice'] as Map?)
                                                  ?.cast<String, dynamic>() ??
                                              <String, dynamic>{},
                                        );
                                    if (existingMulti['previousEnrollment'] ==
                                        null)
                                      existingMulti['previousEnrollment'] = [
                                        'لا',
                                      ];
                                    if (existingMulti['waterSource'] == null)
                                      existingMulti['waterSource'] = [
                                        'ماء معلب',
                                      ];
                                    existingData['multiChoice'] = existingMulti;

                                    final result =
                                        await ChildRegistrationUtils.openMedicalRecordPage(
                                          context,
                                          existingData,
                                        );
                                    if (result != null) {
                                      setDialogState(() {
                                        medicalFormData = result;
                                      });
                                    }
                                  }
                                : null,
                            icon: Icon(
                              medicalFormData.isNotEmpty
                                  ? Icons.edit_note
                                  : Icons.medical_services_outlined,
                              size: 18,
                              color: _baseDark,
                            ),
                            label: Text(
                              medicalFormData.isNotEmpty
                                  ? 'Modifier le dossier'
                                  : 'Dossier Médical (Requis)',
                              style: TextStyle(
                                color: _baseDark,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _tealAccent,
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
                  child: Text('Annuler', style: TextStyle(color: _mutedText)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (firstNameController.text.isNotEmpty &&
                        lastNameController.text.isNotEmpty &&
                        birthDateController.text.isNotEmpty &&
                        selectedInscriptionType != null &&
                        selectedPaymentMethod != null &&
                        medicalFormData.isNotEmpty) {
                      final parsedDate = DateTime.tryParse(
                        birthDateController.text.trim(),
                      );
                      if (parsedDate != null) {
                        final now = DateTime.now();
                        int ageMonths =
                            (now.year - parsedDate.year) * 12 +
                            now.month -
                            parsedDate.month;
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

                      final created = await _createChildInscription(
                        firstName: firstNameController.text.trim(),
                        lastName: lastNameController.text.trim(),
                        birthDate: birthDateController.text.trim(),
                        inscriptionType: selectedInscriptionType!,
                        paymentMethod: selectedPaymentMethod!,
                        mealPlan: selectedMealPlan,
                        totalAmount: calculatedTotalAmount,
                        medicalForm: medicalFormData,
                      );
                      if (!mounted) return;
                      if (created) {
                        Navigator.pop(context);
                      }
                    } else if (medicalFormData.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('La fiche médicale est requise.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Veuillez remplir tous les champs obligatoires.',
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _indigoAccent,
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
          },
        );
      },
    ).then((_) {
      firstNameController.dispose();
      lastNameController.dispose();
      birthDateController.dispose();
    });
  }

  Widget _buildDarkTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(color: _lightText),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: _mutedText, fontSize: 14),
        filled: true,
        fillColor: ThemeColors.glassBackgroundSubtle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildDarkDropdown({
    required String? value,
    required String label,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool isObjMap = false,
    bool isMealPlan = false,
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
        fillColor: ThemeColors.glassBackgroundSubtle,
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
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            isObjMap
                ? _paymentMethodLabel(item)
                : isMealPlan
                ? _shortMealPlanLabel(item, price: _mealPlanFees[item])
                : item,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // _buildButton('Modifier le profil (Désactivé)', Icons.edit_outlined, null),
        // _buildButton('Modifier le profil', Icons.edit_outlined, () async {
        //   final updated = await Navigator.push<bool>(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => const ParentProfileEditPage(),
        //     ),
        //   );
        //   if (!mounted) return;
        //   if (updated == true) {
        //     ScaffoldMessenger.of(context).showSnackBar(
        //       SnackBar(
        //         content: const Text('Profil parent mis à jour'),
        //         backgroundColor: Colors.green.shade800,
        //       ),
        //     );
        //   }
        // }),
        // const SizedBox(height: 16),
        _buildButton(
          'Changer le mot de passe',
          Icons.lock_outline_rounded,
          _showChangePasswordDialog,
        ),
        const SizedBox(height: 16),
        _buildButton(
          'Déconnexion',
          Icons.logout_rounded,
          () => _handleLogout(context),
          customColor: _redAccent,
        ),
      ],
    );
  }

  Widget _buildButton(
    String text,
    IconData icon,
    VoidCallback? onTap, {
    Color? customColor,
  }) {
    final c = customColor ?? _lightText;
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        backgroundColor: ThemeColors.glassBackgroundSubtle,
        side: BorderSide(color: ThemeColors.glassBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: c, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: c,
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    context.read<AuthSession>().clear();
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }
}
