import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newv/utils/api_constants.dart';

class ChildTrackingApis {
  static const String _baseUrl = ApiConstants.baseUrl;

  /// GET /api/parameters to check if inscriptions are open.
  static Future<http.Response> checkInscriptionsOpen() async {
    final uri = Uri.parse('$_baseUrl/api/parameters');
    return await http.get(uri, headers: {'Accept': 'application/json'});
  }

  /// GET /api/parents/{cin}/children to load parent's children.
  static Future<http.Response> loadChildren(String cin, String token) async {
    final uri = Uri.parse('$_baseUrl/api/parents/$cin/children');
    return await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  /// GET /api/children/{childId}/signalements.
  static Future<http.Response> loadSignalements(int childId, String token) async {
    final uri = Uri.parse('$_baseUrl/api/children/$childId/signalements');
    return await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  /// PATCH /api/children/{childId}/signalements/read.
  static Future<http.Response> markSignalementsAsRead(
    int childId,
    String token,
    List<int> signalementIds,
  ) async {
    final uri = Uri.parse('$_baseUrl/api/children/$childId/signalements/read');
    return await http.patch(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'signalement_ids': signalementIds}),
    );
  }
}
