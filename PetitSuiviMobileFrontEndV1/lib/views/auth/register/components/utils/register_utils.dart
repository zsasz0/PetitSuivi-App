import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newv/utils/api_constants.dart';
import 'package:newv/theme_manager.dart';

// File: register_utils.dart
// Purpose: Shared registration utilities (SnackBars, DatePickers, APIs).
// Usage: Used throughout the registration flow.
// API Usage: Yes, fetches payment methods from /api/payment-methods.
// Dependencies: ApiConstants.

/// A general-purpose utility class for the parent registration flow.
class RegisterUtils {
  // used to show error message
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // used to select parent date
  static Future<String?> selectParentDate(BuildContext context) async {
    final bool isLight = ThemeManager.instance.isLightMode;
    final Color tealAccent = isLight
        ? const Color(0xFF009688)
        : const Color(0xFF4CCEAC);
    final Color baseDark = isLight
        ? const Color(0xFFF0F2F5)
        : const Color(0xFF141B2D);
    final Color lightText = isLight
        ? const Color(0xFF212529)
        : const Color(0xFFF2F0F0);

    final now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 30, now.month, now.day),
      // firstDate is 150 years ago : this ensure that the parent is at most 150 years old
      firstDate: DateTime(now.year - 150, now.month, now.day),
      // lastDate is 18 years ago : this ensure that the parent is at least 18 years old
      lastDate: DateTime(now.year - 18, now.month, now.day),
      builder: (context, child) {
        return Theme(
          data: (isLight ? ThemeData.light() : ThemeData.dark()).copyWith(
            colorScheme:
                (isLight ? const ColorScheme.light() : const ColorScheme.dark())
                    .copyWith(
                      primary: tealAccent,
                      onPrimary: isLight ? Colors.white : baseDark,
                      surface: baseDark,
                      onSurface: lightText,
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

  // used to load payment methods from the server
  static Future<List<String>> loadPaymentMethods() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/payment-methods');
    try {
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};
        final data = body['data'];
        if (data is List) {
          return data
              .map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toList();
        }
      }
    } catch (_) {
      // Ignore network errors, returning empty list
    }
    return [];
  }
}
