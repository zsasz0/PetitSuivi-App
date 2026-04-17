import 'package:flutter/material.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/services/notification_service.dart';
import 'package:newv/views/parent/notifications/apis/notification_apis.dart';
import 'package:provider/provider.dart';

class NotificationController extends ChangeNotifier {
  final NotificationApis _apis = NotificationApis();
  
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications(BuildContext context) async {
    final token = context.read<AuthSession>().token;
    if (token == null) {
      _error = 'Session expirée';
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final results = await _apis.fetchNotifications(token);
      
      results.sort((a, b) {
        final dateCompare = b.createdAt.compareTo(a.createdAt);
        if (dateCompare != 0) return dateCompare;
        return b.id.compareTo(a.id);
      });

      _notifications = results;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(BuildContext context, int id) async {
    final token = context.read<AuthSession>().token;
    if (token == null) return;

    // Optimistic update
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      final old = _notifications[idx];
      _notifications[idx] = NotificationModel(
        id: old.id,
        recipientId: old.recipientId,
        recipientRole: old.recipientRole,
        type: old.type,
        title: old.title,
        message: old.message,
        data: old.data,
        isRead: true,
        createdAt: old.createdAt,
      );
      notifyListeners();
    }

    try {
      await _apis.markAsRead(token, id);
    } catch (e) {
      if (context.mounted) {
        await loadNotifications(context); // Reload on error
      }
    }
  }

  Future<void> markAllAsRead(BuildContext context) async {
    final token = context.read<AuthSession>().token;
    if (token == null) return;

    // Optimistic update
    _notifications = _notifications.map((n) {
      return NotificationModel(
        id: n.id,
        recipientId: n.recipientId,
        recipientRole: n.recipientRole,
        type: n.type,
        title: n.title,
        message: n.message,
        data: n.data,
        isRead: true,
        createdAt: n.createdAt,
      );
    }).toList();
    notifyListeners();

    try {
      await _apis.markAllAsRead(token);
    } catch (e) {
      if (context.mounted) {
        await loadNotifications(context); // Reload on error
      }
    }
  }
}
