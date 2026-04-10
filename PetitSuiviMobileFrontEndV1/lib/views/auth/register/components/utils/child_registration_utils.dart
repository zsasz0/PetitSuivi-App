import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:newv/utils/api_constants.dart';
import '../widgets/child_medical_record_page.dart';
import 'package:newv/theme_manager.dart';

// File: child_registration_utils.dart
// Purpose: Helper methods for child-specific registration logic.
// Usage: Used by ChildRegistrationForm.
// API Usage: Yes, fetches pricing parameters from /api/parameters.
// Dependencies: ChildMedicalRecordPage, ApiConstants.

/// A utility class containing static methods for pricing, dates, and medical forms.
class ChildRegistrationUtils {
  static const String _apiBaseUrl = ApiConstants.baseUrl;
  static Color get _tealAccent => ThemeManager.instance.isLightMode
      ? const Color(0xFF009688)
      : const Color(0xFF4CCEAC);
  static Color get _baseDark => ThemeManager.instance.isLightMode
      ? const Color(0xFFF0F2F5)
      : const Color(0xFF141B2D);
  static Color get _lightText => ThemeManager.instance.isLightMode
      ? const Color(0xFF212529)
      : const Color(0xFFF2F0F0);

  static Future<Map<String, dynamic>?> openMedicalRecordPage(
    BuildContext context,
    Map<String, dynamic> initialData,
  ) async {
    return await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => ChildMedicalRecordPage(initialData: initialData),
      ),
    );
  }

  static String normalizeKey(String s) {
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

  static Future<Map<String, dynamic>?> loadPricingParameters(
    List<String> mealPlanOptions,
  ) async {
    final uri = Uri.parse('$_apiBaseUrl/api/parameters');
    try {
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

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
          final value = double.tryParse(item['value']?.toString() ?? '');
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

        return {'baseFee': baseFee, 'mealFees': mealFees};
      }
    } catch (_) {
      // Return null on failure
    }
    return null;
  }

  static Future<String?> selectDate(BuildContext context) async {
    final bool isLight = ThemeManager.instance.isLightMode;
    final DateTime now = DateTime.now();
    final DateTime firstDate = DateTime(now.year - 5, now.month - 4, now.day);
    final DateTime lastDate = DateTime(now.year - 2, now.month, now.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 3, now.month, now.day),
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: (isLight ? ThemeData.light() : ThemeData.dark()).copyWith(
            colorScheme:
                (isLight ? const ColorScheme.light() : const ColorScheme.dark())
                    .copyWith(
                      primary: _tealAccent,
                      onPrimary: isLight ? Colors.white : _baseDark,
                      surface: _baseDark,
                      onSurface: _lightText,
                    ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      return "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
    return null;
  }

  static double calculateTotalPayment(
    double baseFee,
    Map<String, double> mealPlanFees,
    String mealPlan,
  ) {
    return baseFee + (mealPlanFees[mealPlan] ?? 0.0);
  }

  static String formatAmount(double amount) {
    return amount.toStringAsFixed(0);
  }
}
