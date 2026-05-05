import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newv/utils/api_constants.dart';
import 'package:flutter/foundation.dart';

class SupportApis {
  static Future<Map<String, String>> fetchParameters(String? token) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/api/parameters');
      debugPrint('[SupportApis] Fetching parameters from: $uri');

      final Map<String, String> headers = {
        'Accept': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(uri, headers: headers);

      debugPrint('[SupportApis] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);

        List<dynamic> data;
        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map<String, dynamic>) {
          data = decoded['data'] ?? [];
        } else {
          data = [];
        }

        final Map<String, String> params = {};
        for (var item in data) {
          final key = (item['name'] ?? item['Name'] ?? '').toString();
          final val = (item['value'] ?? item['Value'] ?? '').toString();
          if (key.isNotEmpty && val.isNotEmpty) {
            params[key] = val;
          }
        }
        return params;
      } else {
        throw Exception('Failed to fetch parameters: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[SupportApis] Error: $e');
      rethrow;
    }
  }
}
