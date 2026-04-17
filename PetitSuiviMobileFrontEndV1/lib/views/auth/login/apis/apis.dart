import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:newv/utils/api_constants.dart';
import '../../../../models/parameter.dart';
import '../../../../models/account.dart';

/// Service class containing API calls for the Login feature.
class LoginApis {
  static const String _baseUrl = ApiConstants.baseUrl;

  /// Queries the API to check if `inscriptions_open` parameter is active.
  static Future<bool> fetchInscriptionsStatus() async {
    try {
      final uri = Uri.parse('$_baseUrl/api/parameters');
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        final List<dynamic> jsonList = data is List ? data : (data['data'] ?? []);
        
        final List<Parameter> params = jsonList
            .map((p) => Parameter.fromJson(p as Map<String, dynamic>))
            .toList();
        
        for (final p in params) {
          if (p.name == 'inscriptions_open') {
            return p.value == 'true' || p.value == '1';
          }
        }
      }
    } catch (e) {
      // On error, we default to the last known state or usually true
    }
    return true;
  }

  /// Checks whether an active (non-archived) school-year planning exists.
  ///
  /// Calls the public endpoint `GET /api/plannings/active-check` which
  /// returns `{ "has_active": true|false }`.
  ///
  /// Returns:
  /// - `true`  → an active planning exists.
  /// - `false` → no active planning (all archived or none exist).
  /// - `null`  → can't determine (network/server error) → caller fail-opens.
  static Future<bool?> fetchActivePlanning() async {
    try {
      final uri = Uri.parse('$_baseUrl/api/plannings/active-check');
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      debugPrint('[LoginApis] GET /api/plannings/active-check → ${response.statusCode}');
      debugPrint('[LoginApis] Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};

        final hasActive = data['has_active'] == true;
        debugPrint('[LoginApis] has_active = $hasActive');
        return hasActive;
      }

      debugPrint('[LoginApis] Non-2xx response, fail-open');
      return null;
    } catch (e) {
      debugPrint('[LoginApis] fetchActivePlanning error: $e');
      return null;
    }
  }

  /// Performs the authentication request.
  /// Returns a [Map] containing the response body and the HTTP status code.
  static Future<Map<String, dynamic>> performLogin({
    required String email,
    required String password,
    required bool isTeacher,
  }) async {
    final endpoint = isTeacher ? '/api/login/teacher' : '/api/login/parent';
    final uri = Uri.parse('$_baseUrl$endpoint');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    final Map<String, dynamic> data = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};
    
    // Using Account and Role classes to validate user data structure if present
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (data['user'] != null) {
        try {
          // This validates that the user data matches our Account entity
          final account = Account.fromJson(data['user'] as Map<String, dynamic>);
          // We can optionally store it in the data map for the controller to use
          data['account'] = account;
        } catch (e) {
          // If parsing fails, we continue with raw data but could log the error
        }
      }
    }
        
    // We add the status code to the map so the UI can handle different logic (e.g. 401, 403)
    data['statusCode'] = response.statusCode;
    return data;
  }
}
