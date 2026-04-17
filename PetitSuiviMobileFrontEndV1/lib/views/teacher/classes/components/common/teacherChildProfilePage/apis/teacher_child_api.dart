import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:newv/utils/api_constants.dart';

class TeacherChildApi {
  static const String _baseUrl = ApiConstants.baseUrl;

  final String? token;

  TeacherChildApi({this.token});

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null && token!.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  /// GET /api/children/{id}/ai-summaries
  Future<Map<String, dynamic>?> getAiSummaries(int childId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/children/$childId/ai-summaries'),
        headers: _headers,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('[TeacherChildApi] getAiSummaries error: $e');
    }
    return null;
  }

  /// GET /api/children/{id}/signalements
  Future<List<dynamic>?> getSignalements(int childId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/children/$childId/signalements'),
        headers: _headers,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return body['data'] as List?;
      }
    } catch (e) {
      debugPrint('[TeacherChildApi] getSignalements error: $e');
    }
    return null;
  }

  /// GET /api/classes/{id}/activities/date/{date}
  Future<Map<String, dynamic>?> getClassActivities(int classId, String dateStr) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/classes/$classId/activities/date/$dateStr'),
        headers: _headers,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('[TeacherChildApi] getClassActivities error: $e');
    }
    return null;
  }

  /// GET /api/children/{id}/evaluations/date/{date}
  Future<Map<String, dynamic>?> getExistingEvaluations(int childId, String dateStr) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/children/$childId/evaluations/date/$dateStr'),
        headers: _headers,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('[TeacherChildApi] getExistingEvaluations error: $e');
    }
    return null;
  }

  /// POST /api/evaluations/bulk
  Future<http.Response> saveEvaluationsBulk(Map<String, dynamic> body) async {
    return await http.post(
      Uri.parse('$_baseUrl/api/evaluations/bulk'),
      headers: _headers,
      body: jsonEncode(body),
    );
  }

  /// POST /api/signalements
  Future<http.Response> postSignalement(Map<String, dynamic> body) async {
    return await http.post(
      Uri.parse('$_baseUrl/api/signalements'),
      headers: _headers,
      body: jsonEncode(body),
    );
  }
}
