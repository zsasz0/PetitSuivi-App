import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newv/utils/api_constants.dart';

class TeacherClassesApi {
  static const String _baseUrl = ApiConstants.baseUrl;

  /// Fetches classrooms assigned to the teacher.
  static Future<http.Response> getTeacherClasses(String teacherCin, String token) async {
    final uri = Uri.parse('$_baseUrl/api/teachers/$teacherCin/classes/by-planning');
    return await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  /// Fetches presence list for a class, month, and year.
  static Future<http.Response> getAttendance(int classId, int month, int year, String token) async {
    final uri = Uri.parse('$_baseUrl/api/classes/$classId/presences?month=$month&year=$year');
    return await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  /// Records a new presence.
  static Future<http.Response> postAttendance(int classId, Map<String, dynamic> data, String token) async {
    final uri = Uri.parse('$_baseUrl/api/classes/$classId/presences');
    return await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
  }

  /// Updates an existing presence.
  static Future<http.Response> putAttendance(int classId, int presenceId, Map<String, dynamic> data, String token) async {
    final uri = Uri.parse('$_baseUrl/api/classes/$classId/presences/$presenceId');
    return await http.put(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
  }

  /// Fetches activities and criteria for a class on a specific date.
  static Future<http.Response> getClassActivities(int classId, String dateStr, String token) async {
    final uri = Uri.parse('$_baseUrl/api/classes/$classId/activities/date/$dateStr');
    return await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  /// Fetches students for a class.
  static Future<http.Response> getClassStudents(int classId, String token) async {
    final uri = Uri.parse('$_baseUrl/api/classes/$classId/students');
    return await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  /// Fetches existing evaluations for a child on a specific date.
  static Future<http.Response> getChildEvaluations(int childId, String dateStr, String token) async {
    final uri = Uri.parse('$_baseUrl/api/children/$childId/evaluations/date/$dateStr');
    return await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  /// Saves evaluations in bulk.
  static Future<http.Response> saveBulkEvaluations(Map<String, dynamic> body, String token) async {
    final uri = Uri.parse('$_baseUrl/api/evaluations/bulk');
    return await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }
}
