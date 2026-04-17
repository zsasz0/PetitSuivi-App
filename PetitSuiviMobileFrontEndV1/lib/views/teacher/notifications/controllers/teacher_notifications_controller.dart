import 'package:flutter/material.dart';
import 'package:newv/services/notification_service.dart';
import 'package:newv/views/teacher/notifications/apis/teacher_notifications_api.dart';

class CombinedNotification {
  final String id;
  final String type;
  final String title;
  final String message;
  final DateTime date;
  final bool isRead;
  final dynamic originalData;

  CombinedNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.date,
    required this.isRead,
    this.originalData,
  });
}

class TeacherNotificationsController extends ChangeNotifier {
  final TeacherNotificationsApi _api = TeacherNotificationsApi();

  List<CombinedNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<CombinedNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications(String token) async {
    if (token.isEmpty) {
      _error = 'Session expirée';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      List<dynamic> rawPickups = [];
      List<NotificationModel> rawUnified = [];

      try {
        rawPickups = await _api.getPickupNotifications(token);
      } catch (e) {
        debugPrint('Pickup notifications fetch failed: $e');
      }

      try {
        rawUnified = await _api.getUnifiedNotifications(token);
      } catch (e) {
        debugPrint('Unified notifications fetch failed: $e');
      }

      final List<CombinedNotification> combined = [];

      // Parse pickups
      for (var p in rawPickups) {
        final childName = p['child'] != null
            ? '${p['child']['firstName']} ${p['child']['lastName']}'
            : 'Unknown Child';
        final parentName = p['parent'] != null
            ? '${p['parent']['firstName']} ${p['parent']['lastName']}'
            : 'Unknown Parent';
        final durationMinutes = p['duration_minutes'] is int
            ? p['duration_minutes'] as int
            : int.tryParse(p['duration_minutes']?.toString() ?? '') ?? 15;

        combined.add(
          CombinedNotification(
            id: 'pickup_${p['id']}',
            type: 'pickup',
            title: 'Récupération - $childName',
            message:
                '$parentName récupérera $childName dans $durationMinutes minutes.',
            date: _parseNotificationDate(p['created_at']),
            isRead: false,
            originalData: p,
          ),
        );
      }

      // Parse unified
      for (var u in rawUnified) {
        combined.add(
          CombinedNotification(
            id: 'unified_${u.id}',
            type: u.type,
            title: u.title,
            message: u.message,
            date: u.createdAt,
            isRead: u.isRead,
            originalData: u,
          ),
        );
      }

      // Sort descending by date
      combined.sort((a, b) {
        final dateCompare = b.date.compareTo(a.date);
        if (dateCompare != 0) return dateCompare;
        return _notificationSortKey(b).compareTo(_notificationSortKey(a));
      });

      _notifications = combined;
      _isLoading = false;
    } catch (e) {
      _error = 'Erreur lors du chargement des notifications.';
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<bool> handleAction(CombinedNotification notification, String token) async {
    try {
      if (notification.type == 'pickup') {
        final p = notification.originalData;
        await _api.markPickupAsCompleted(p['id'], token);
      } else {
        final u = notification.originalData as NotificationModel;
        if (!u.isRead) {
          await _api.markNotificationAsRead(u.id, token);
        }
      }
      await loadNotifications(token);
      return true;
    } catch (e) {
      debugPrint('Error handling notification action: $e');
      return false;
    }
  }

  DateTime _parseNotificationDate(dynamic rawDate) {
    final parsed = DateTime.tryParse(rawDate?.toString() ?? '');
    return parsed ?? DateTime.now();
  }

  int _notificationSortKey(CombinedNotification notification) {
    if (notification.type == 'pickup') {
      final rawId = notification.originalData?['id'];
      return int.tryParse(rawId?.toString() ?? '') ?? 0;
    }

    final data = notification.originalData;
    if (data is NotificationModel) {
      return data.id;
    }

    return int.tryParse(notification.id.replaceAll(RegExp(r'\D'), '')) ?? 0;
  }

  String timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    return 'Il y a ${diff.inDays} j';
  }
}
