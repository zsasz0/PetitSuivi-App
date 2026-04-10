import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newv/utils/api_constants.dart';

/// Service responsible for managing pickup notifications between parents and teachers.
///
/// This service allows parents to notify teachers when they are picking up a child,
/// and allows teachers to view and manage these notifications.
class PickupNotificationService {
  /// The base URL for the pickup notification API endpoints.
  final String baseUrl = '${ApiConstants.baseUrl}/api';

  /// Helper to construct standard request headers.
  Map<String, String> _getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Sends a pickup notification for a specific [childId].
  Future<void> sendNotification(
    int childId,
    String token, {
    int durationMinutes = 15,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notifications/pickup'),
      headers: _getHeaders(token),
      body: jsonEncode({
        'child_id': childId,
        'duration_minutes': durationMinutes,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to send notification: ${response.body}');
    }
  }

  /// Retrieves a list of unread pickup notifications for the teacher.
  Future<List<dynamic>> getTeacherNotifications(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/teacher/teacher/pickup-notifications'),
      headers: _getHeaders(token),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['data'] ?? [];
    }

    throw Exception('Failed to fetch notifications: ${response.statusCode}');
  }

  /// Marks a specific pickup notification as completed by its [notificationId].
  Future<void> markAsCompleted(int notificationId, String token) async {
    final response = await http.patch(
      Uri.parse(
        '$baseUrl/teacher/teacher/pickup-notifications/$notificationId/complete',
      ),
      headers: _getHeaders(token),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update notification: ${response.statusCode}');
    }
  }
}
