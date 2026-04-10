import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newv/models/evaluation.dart';
import 'package:newv/models/signalement.dart';
import 'package:newv/utils/api_constants.dart';

/// Service responsible for managing child evaluations and signalements via API.
///
/// This service handles fetching activities, saving evaluations, and retrieving
/// incident reports (signalements) for specific children.
class EvaluationService {
  /// The base URL for the API endpoints.
  final String baseUrl = '${ApiConstants.baseUrl}/api';

  /// Retrieves the standard headers including the Authorization Bearer token.
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Fetches planned activities and their criteria for a specific class on a given date.
  Future<List<dynamic>> getClassActivities(int classId, String date) async {
    final response = await http.get(
      Uri.parse('$baseUrl/classes/$classId/activities/date/$date'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        return jsonResponse['data']['activities'] ?? [];
      }
    }
    throw Exception('Failed to fetch class activities');
  }

  /// Fetches already saved evaluations for a specific child on a given date.
  Future<List<dynamic>> getChildEvaluations(int childId, String date) async {
    final response = await http.get(
      Uri.parse('$baseUrl/children/$childId/evaluations/date/$date'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        return jsonResponse['data']['evaluations'] ?? [];
      }
    }
    throw Exception('Failed to fetch child evaluations');
  }

  /// Fetches evaluations intended for parent viewing (Acquired/To reinforce).
  Future<List<dynamic>> getParentCompetences(int childId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/children/$childId/evaluations/parent-view'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        return jsonResponse['data']['evaluations'] ?? [];
      }
    }
    throw Exception('Failed to fetch parent competences');
  }

  /// Saves or updates a single evaluation criterion for a child.
  Future<void> evaluateCriteria({
    required int childId,
    required int activityId,
    required int teacherId,
    required String date,
    required int criteriaId,
    required String statusLabel,
    String? comment,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/evaluations'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'child_id': childId,
        'activity_id': activityId,
        'teacher_id': teacherId,
        'evaluation_date': date,
        'criteria': [
          {
            'criteria_id': criteriaId,
            'status_label': statusLabel,
            if (comment != null) 'comment': comment,
          },
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save evaluation');
    }
  }

  /// Saves a complete [Evaluation] object to the backend.
  Future<Evaluation> saveEvaluation(Evaluation evaluation) async {
    final response = await http.post(
      Uri.parse('$baseUrl/evaluations'),
      headers: await _getHeaders(),
      body: json.encode(evaluation.toJson()),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success']) {
        return Evaluation.fromJson(jsonResponse['data']);
      }
    }
    throw Exception(
      'Failed to save evaluation: ${response.statusCode} - ${response.body}',
    );
  }

  /// Retrieves all signalements (incident reports) associated with a child.
  Future<List<Signalement>> getSignalementsForChild(int childId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/children/$childId/signalements'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success']) {
        final List<dynamic> data = jsonResponse['data'];
        return data.map((item) => Signalement.fromJson(item)).toList();
      }
    }
    throw Exception('Failed to load signalements: ${response.statusCode}');
  }

  /// Saves a new [Signalement] (incident report) to the backend.
  Future<Signalement> saveSignalement(Signalement signalement) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signalements'),
      headers: await _getHeaders(),
      body: json.encode(signalement.toJson()),
    );

    if (response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success']) {
        return Signalement.fromJson(jsonResponse['data']);
      }
    }
    throw Exception(
      'Failed to save signalement: ${response.statusCode} - ${response.body}',
    );
  }
}
