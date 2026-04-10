import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newv/utils/api_constants.dart';

/// Data model representing a notification entity.
class NotificationModel {
  final int id;
  final String recipientId;
  final String recipientRole;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  /// Creates a new [NotificationModel] instance.
  NotificationModel({
    required this.id,
    required this.recipientId,
    required this.recipientRole,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    required this.isRead,
    required this.createdAt,
  });

  /// Factory constructor to create a [NotificationModel] from a JSON map.
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      recipientId: json['recipient_id']?.toString() ?? '',
      recipientRole: json['recipient_role'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      data: json['data'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

/// Service responsible for fetching and managing user notifications.
///
/// This service provides methods to retrieve list of notifications,
/// marking them as read, and getting unread counts based on user roles.
class NotificationService {
  /// The base URL for the notification API endpoints.
  final String baseUrl = '${ApiConstants.baseUrl}/api';

  /// Helper to construct standard request headers.
  Map<String, String> _getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Maps the generic role name to its corresponding API resource path segment.
  String _getRolePath(String role) {
    return role == 'parent' ? 'parents' : 'teacher/teacher';
  }

  /// Retrieves a list of [NotificationModel] for the specified [role].
  Future<List<NotificationModel>> getNotifications(
    String token,
    String role,
  ) async {
    final path = _getRolePath(role);
    final uri = Uri.parse('$baseUrl/$path/notifications?role=$role');
    final response = await http.get(uri, headers: _getHeaders(token));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List data = jsonResponse['data'] ?? [];
      return data.map((item) => NotificationModel.fromJson(item)).toList();
    }
    throw Exception('Failed to fetch notifications: ${response.statusCode}');
  }

  /// Marks all notifications as read for the current [role].
  Future<void> markAllAsRead(String token, String role) async {
    final path = _getRolePath(role);
    final uri = Uri.parse('$baseUrl/$path/notifications/mark-all-read');
    final response = await http.patch(
      uri,
      headers: _getHeaders(token),
      body: jsonEncode({'role': role}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark all as read: ${response.statusCode}');
    }
  }

  /// Marks a specific notification as read by its [notificationId].
  Future<void> markAsRead(String token, String role, int notificationId) async {
    final path = _getRolePath(role);
    final uri = Uri.parse('$baseUrl/$path/notifications/$notificationId/read');
    final response = await http.patch(
      uri,
      headers: _getHeaders(token),
      body: jsonEncode({'role': role}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark as read: ${response.statusCode}');
    }
  }

  /// Retrieves the current count of unread notifications for a [role].
  Future<int> getUnreadCount(String token, String role) async {
    final path = _getRolePath(role);
    final uri = Uri.parse(
      '$baseUrl/$path/notifications/unread-count?role=$role',
    );
    final response = await http.get(uri, headers: _getHeaders(token));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['data']['count'] ?? 0;
    }
    return 0;
  }
}
