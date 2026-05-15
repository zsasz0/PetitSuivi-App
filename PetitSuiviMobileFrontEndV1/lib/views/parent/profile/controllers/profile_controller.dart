import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/utils/unauthorized_handler.dart';
import 'package:newv/views/parent/profile/apis/profile_apis.dart';

class ProfileController {
  final BuildContext context;

  ProfileController(this.context);

  String normalizeKey(String s) {
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

  Future<void> loadPricingParameters({
    required Function(bool) setLoading,
    required Function(bool) setInscriptionsOpen,
    required Function(double) setBaseFee,
    required Function(Map<String, double>) setMealPlanFees,
    required List<String> mealPlanOptions,
  }) async {
    try {
      final response = await ProfileApis.getParameters();
      if (!context.mounted) return;

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
            setInscriptionsOpen(rawValue == 'true' || rawValue == '1');
            continue;
          }

          final value = double.tryParse(rawValue);
          if (value == null) continue;

          final normName = normalizeKey(name);

          if (normName == normalizeKey('Prix de base')) {
            baseFee = value;
          } else {
            String? matchedOption;
            if (normName.contains('dejeuner et le gouter')) {
              matchedOption = mealPlanOptions[0];
            } else if (normName.contains('seulement le dejeuner')) {
              matchedOption = mealPlanOptions[1];
            } else if (normName.contains('seulement le gouter')) {
              matchedOption = mealPlanOptions[2];
            } else if (normName.contains('ne mange pas')) {
              matchedOption = mealPlanOptions[3];
            }

            if (matchedOption != null) {
              mealFees[matchedOption] = value;
            }
          }
        }

        if (baseFee != null) setBaseFee(baseFee);
        if (mealFees.isNotEmpty) setMealPlanFees(mealFees);
        setLoading(false);
      } else {
        setLoading(false);
      }
    } catch (_) {
      if (context.mounted) setLoading(false);
    }
  }

  Future<void> loadPaymentMethods({
    required List<String> defaultPaymentMethods,
    required Function(List<String>) setPaymentMethods,
  }) async {
    try {
      final response = await ProfileApis.getPaymentMethods();
      if (!context.mounted) return;

      final body = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      final data = body['data'];
      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          data is List) {
        final methods = data
            .map((e) => e.toString())
            .where((e) => e == 'oneShot' || e == 'monthlyPartial')
            .toList();
        if (methods.isNotEmpty) {
          final mergedMethods = <String>{
            ...defaultPaymentMethods,
            ...methods,
          }.toList();
          setPaymentMethods(mergedMethods);
        }
      }
    } catch (_) {
      // Keep defaults
    }
  }

  Future<void> loadChildren({
    required Function(bool) setLoading,
    required Function(List<Map<String, dynamic>>) setChildren,
  }) async {
    final session = context.read<AuthSession>();
    final token = session.token;
    final parentCin = session.cin;

    if (token == null || token.isEmpty || parentCin == null) {
      setLoading(false);
      return;
    }

    try {
      final response = await ProfileApis.getChildren(
        parentCin.toString(),
        token,
      );
      if (!context.mounted) return;

      if (UnauthorizedHandler.handle(
        context: context,
        statusCode: response.statusCode,
      )) {
        return;
      }

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
            'id': map['id'],
            'firstName': map['firstName']?.toString() ?? '',
            'lastName': map['lastName']?.toString() ?? '',
            'birthDate': map['birthdate']?.toString(),
            'description': '',
            'medicalRecord': null,
            'extraData': {'inscriptions': inscriptions},
          };
        }).toList();

        setChildren(mapped);
        setLoading(false);
      } else {
        setLoading(false);
      }
    } catch (_) {
      if (context.mounted) setLoading(false);
    }
  }

  Future<bool> createChildInscription({
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session invalide. Reconnectez-vous.')),
        );
      }
      return false;
    }

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
      final response = await ProfileApis.createChildInscription(
        parentCin: parentCin.toString(),
        token: token,
        payload: payload,
      );

      if (!context.mounted) return false;
      if (UnauthorizedHandler.handle(
        context: context,
        statusCode: response.statusCode,
      )) {
        return false;
      }

      final body = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        session.bumpChildrenVersion();
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur réseau lors de l\'inscription de l\'enfant.'),
          ),
        );
      }
      return false;
    }
  }

  Future<void> changePassword({
    required String newPassword,
    required ScaffoldMessengerState messenger,
  }) async {
    final session = context.read<AuthSession>();
    final token = session.token;

    if (token == null || token.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Session invalide. Reconnectez-vous.')),
      );
      return;
    }

    try {
      final response = await ProfileApis.changePassword(
        token: token,
        newPassword: newPassword,
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

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String address,
  }) async {
    final session = context.read<AuthSession>();
    final token = session.token;
    final cin = session.cin;

    if (token == null || token.isEmpty || cin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session invalide. Reconnectez-vous.')),
      );
      return false;
    }

    try {
      final response = await ProfileApis.updateProfile(
        parentCin: cin.toString(),
        token: token,
        payload: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phone,
          'adresse': address,
        },
      );

      if (!context.mounted) return false;
      if (UnauthorizedHandler.handle(
        context: context,
        statusCode: response.statusCode,
      )) {
        return false;
      }

      final body = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = body['data'] as Map<String, dynamic>?;
        session.updateProfileData(
          firstName: data?['firstName']?.toString() ?? firstName,
          lastName: data?['lastName']?.toString() ?? lastName,
          email: data?['email']?.toString() ?? email,
          phone: data?['phone']?.toString() ?? phone,
          address: data?['adresse']?.toString() ?? address,
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              body['message']?.toString() ?? 'Erreur lors de la mise à jour.',
            ),
            backgroundColor: Colors.red.shade800,
          ),
        );
        return false;
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur réseau.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }
}
