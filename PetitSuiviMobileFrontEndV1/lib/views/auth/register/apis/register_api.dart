import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newv/utils/api_constants.dart';

class RegisterApi {
  static const String _baseUrl = ApiConstants.baseUrl;

  static Future<Map<String, dynamic>> register(
    Map<String, dynamic> payload,
  ) async {
    final uri = Uri.parse('$_baseUrl/api/register');
    final response = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    return {
      'statusCode': response.statusCode,
      'body': response.body.isNotEmpty
          ? jsonDecode(response.body)
          : <String, dynamic>{},
    };
  }

  static Future<Map<String, dynamic>> checkEmail(String email) async {
    final uri = Uri.parse('$_baseUrl/api/register/check-email');
    final response = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email}),
    );

    return {
      'statusCode': response.statusCode,
      'body': response.body.isNotEmpty
          ? jsonDecode(response.body)
          : <String, dynamic>{},
    };
  }

  static Future<Map<String, dynamic>> checkCin(String cin) async {
    final uri = Uri.parse('$_baseUrl/api/register/check-cin');
    final response = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'cin': cin}),
    );

    return {
      'statusCode': response.statusCode,
      'body': response.body.isNotEmpty
          ? jsonDecode(response.body)
          : <String, dynamic>{},
    };
  }

  static Future<List<String>> getPaymentMethods() async {
    final uri = Uri.parse('$_baseUrl/api/payment-methods');
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
      // Ignore network errors
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>?> fetchParameters() async {
    final uri = Uri.parse('$_baseUrl/api/parameters');
    try {
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final raw = response.body.isNotEmpty ? jsonDecode(response.body) : null;
        final list = raw is List ? raw : (raw is Map ? raw['data'] : null);
        if (list is List) {
          return List<Map<String, dynamic>>.from(list);
        }
      }
    } catch (_) {}
    return null;
  }
}
