import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newv/utils/api_constants.dart';
import 'package:newv/services/notification_service.dart';

class NotificationApis {
  final String baseUrl = '${ApiConstants.baseUrl}/api';

  Map<String, String> _getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<NotificationModel>> fetchNotifications(String token) async {
    final uri = Uri.parse('$baseUrl/parents/notifications?role=parent');
    final response = await http.get(uri, headers: _getHeaders(token));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List data = jsonResponse['data'] ?? [];
      return data.map((item) => NotificationModel.fromJson(item)).toList();
    }
    throw Exception('Failed to fetch notifications: ${response.statusCode}');
  }

  Future<void> markAllAsRead(String token) async {
    final uri = Uri.parse('$baseUrl/parents/notifications/mark-all-read');
    final response = await http.patch(
      uri,
      headers: _getHeaders(token),
      body: jsonEncode({'role': 'parent'}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark all as read: ${response.statusCode}');
    }
  }

  Future<void> markAsRead(String token, int notificationId) async {
    final uri = Uri.parse('$baseUrl/parents/notifications/$notificationId/read');
    final response = await http.patch(
      uri,
      headers: _getHeaders(token),
      body: jsonEncode({'role': 'parent'}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark as read: ${response.statusCode}');
    }
  }
}
