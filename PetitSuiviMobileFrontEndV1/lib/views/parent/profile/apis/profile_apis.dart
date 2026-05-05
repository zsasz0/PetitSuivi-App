import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newv/utils/api_constants.dart';

class ProfileApis {
  static const String _apiBaseUrl = ApiConstants.baseUrl;

  static Future<http.Response> getParameters() async {
    final uri = Uri.parse('$_apiBaseUrl/api/parameters');
    return await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );
  }

  static Future<http.Response> getPaymentMethods() async {
    final uri = Uri.parse('$_apiBaseUrl/api/payment-methods');
    return await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );
  }

  static Future<http.Response> getChildren(String parentCin, String token) async {
    final uri = Uri.parse('$_apiBaseUrl/api/parents/$parentCin/children');
    return await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.Response> createChildInscription({
    required String parentCin,
    required String token,
    required Map<String, dynamic> payload,
  }) async {
    final uri = Uri.parse('$_apiBaseUrl/api/parents/$parentCin/children');
    return await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );
  }

  static Future<http.Response> changePassword({
    required String token,
    required String newPassword,
  }) async {
    final uri = Uri.parse('$_apiBaseUrl/api/password/change');
    return await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'new_password': newPassword}),
    );
  }

  static Future<http.Response> updateProfile({
    required String parentCin,
    required String token,
    required Map<String, dynamic> payload,
  }) async {
    final uri = Uri.parse('$_apiBaseUrl/api/parents/$parentCin/profile');
    return await http.put(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );
  }
}
