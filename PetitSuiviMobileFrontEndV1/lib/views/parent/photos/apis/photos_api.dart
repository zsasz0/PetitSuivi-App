import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newv/utils/api_constants.dart';

class PhotosApi {
  static const String _apiBaseUrl = ApiConstants.baseUrl;

  static String get _normalizedApiBaseUrl => _apiBaseUrl.endsWith('/')
      ? _apiBaseUrl.substring(0, _apiBaseUrl.length - 1)
      : _apiBaseUrl;

  /// Fetches approved children for a parent CIN.
  static Future<List<Map<String, dynamic>>> getApprovedChildren({
    required String cin,
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('$_normalizedApiBaseUrl/api/parents/$cin/children'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final data = body['data'] as List? ?? [];
      return data.cast<Map<String, dynamic>>().where((child) {
        final inscriptions = child['inscriptions'] as List? ?? [];
        if (inscriptions.isEmpty) return false;
        final latestStatus = (inscriptions.last as Map?)?['status'];
        final statusName = latestStatus is Map
            ? latestStatus['name']?.toString().toLowerCase()
            : latestStatus?.toString().toLowerCase();
        return statusName == 'approved';
      }).toList();
    } else {
      throw Exception('Failed to load children: ${response.statusCode}');
    }
  }
}
