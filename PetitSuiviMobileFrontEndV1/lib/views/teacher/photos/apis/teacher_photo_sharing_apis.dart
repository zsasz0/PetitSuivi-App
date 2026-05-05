import 'package:http/http.dart' as http;
import 'package:newv/utils/api_constants.dart';

class TeacherPhotoSharingApis {
  static const String _baseUrl = ApiConstants.baseUrl;

  static String get _normalizedBaseUrl => _baseUrl.endsWith('/')
      ? _baseUrl.substring(0, _baseUrl.length - 1)
      : _baseUrl;

  static Map<String, String> _headers(String token) => {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  static Future<http.Response> getTeacherClasses(Object cin, String token) async {
    return await http.get(
      Uri.parse('$_normalizedBaseUrl/api/teachers/$cin/classes'),
      headers: _headers(token),
    );
  }

  static Future<http.Response> getClassStudents(String classId, String token) async {
    return await http.get(
      Uri.parse('$_normalizedBaseUrl/api/classes/$classId/students'),
      headers: _headers(token),
    );
  }
}
