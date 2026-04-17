import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newv/utils/api_constants.dart';

class TeacherProfileApi {
  static const String _baseUrl = ApiConstants.baseUrl;

  static Future<http.Response> fetchStats({
    required String token,
    required String teacherCin,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/teachers/$teacherCin/classes');
    return await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.Response> changePassword({
    required String token,
    required String newPassword,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/password/change');
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
}
