/// teacher_notifications_page.dart
///
/// Unified notification center for teachers combining pickup alerts
/// (parent arrival notifications) and general system notifications
/// (events, signalements, payments, etc.).
///
/// ## State Management
/// - [_TeacherNotificationsPageState] merges data from two independent
///   services into [CombinedNotification] objects, sorted by date descending.
/// - Supports pull-to-refresh and "mark all as read" with optimistic UI.
///
/// ## Backend API Endpoints
///
/// ### GET /api/teacher/teacher/pickups (via [PickupNotificationService])
/// Fetches pending pickup notifications assigned to this teacher.
/// - **Headers:** `Authorization: Bearer {token}`
/// - **Response 200:**
/// ```json
/// {
///   "data": [
///     {
///       "id": 1, "duration_minutes": 15, "created_at": "2026-03-05T14:30:00",
///       "child": { "firstName": "Sami", "lastName": "Ben Ali" },
///       "parent": { "firstName": "Ahmed", "lastName": "Ben Ali" }
///     }
///   ]
/// }
/// ```
///
/// ### PATCH /api/teacher/teacher/pickups/{id}/complete (via [PickupNotificationService])
/// Marks a pickup notification as completed.
/// - **Response 200:** `{ "message": "Pickup completed." }`
///
/// ### GET /api/notifications?role=teacher (via [NotificationService])
/// Fetches general notifications for the teacher role.
/// - **Response 200:** `{ "data": [ { "id": 1, "type": "event", "title": "...", "message": "...", "is_read": false, "created_at": "..." } ] }`
///
/// ### PATCH /api/notifications/{id}/read (via [NotificationService])
/// Marks a single notification as read.
///
/// ### PATCH /api/notifications/mark-all-read?role=teacher (via [NotificationService])
/// Marks all teacher notifications as read.
///
/// ## Dependencies
/// [PickupNotificationService], [NotificationService], [AuthSession],
/// [TeacherTheme], [ThemeManager], [EventDetailPage].
library teacher_notifications_page;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/services/notification_service.dart';
import 'package:newv/services/pickup_notification_service.dart';
import 'package:newv/theme_manager.dart';
import 'package:newv/views/shared/event_detail_page.dart';
import 'package:newv/views/teacher/teacher_theme.dart';
import 'package:provider/provider.dart';

/// Internal model for merging different notification sources.
class CombinedNotification {
  final String id;
  final String type;
  final String title;
  final String message;
  final DateTime date;
  final bool isRead;
  final dynamic originalData; // Maps for pickup, NotificationModel for unified

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

/// A scrollable list of notifications with real-time refresh and action handling (reading, confirming).
class TeacherNotificationsPage extends StatefulWidget {
  const TeacherNotificationsPage({Key? key}) : super(key: key);

  @override
  _TeacherNotificationsPageState createState() =>
      _TeacherNotificationsPageState();
}

class _TeacherNotificationsPageState extends State<TeacherNotificationsPage> {
  final PickupNotificationService _pickupService = PickupNotificationService();
  final NotificationService _unifiedService = NotificationService();

  List<CombinedNotification> _notifications = [];
  bool _isLoading = true;
  String? _error;

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  Future<void> _loadNotifications() async {
    final token = context.read<AuthSession>().token;
    if (token == null || token.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Session expirée';
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      // Fetch both sources independently – don't let one failure kill the page
      List<dynamic> rawPickups = [];
      List<NotificationModel> rawUnified = [];

      try {
        rawPickups = await _pickupService.getTeacherNotifications(token);
      } catch (e) {
        debugPrint('Pickup notifications fetch failed: $e');
      }

      try {
        rawUnified = await _unifiedService.getNotifications(token, 'teacher');
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

      if (mounted) {
        setState(() {
          _notifications = combined;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erreur lors du chargement des notifications.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleAction(CombinedNotification notification) async {
    final token = context.read<AuthSession>().token;
    if (token == null || token.isEmpty) return;

    try {
      if (notification.type == 'pickup') {
        final p = notification.originalData;
        await _pickupService.markAsCompleted(p['id'], token);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Récupération confirmée')),
          );
        }
      } else {
        final u = notification.originalData as NotificationModel;
        if (!u.isRead) {
          await _unifiedService.markAsRead(token, 'teacher', u.id);
        }
      }
      _loadNotifications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    return 'Il y a ${diff.inDays} j';
  }

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'pickup':
        return Icons.emoji_people_rounded;
      case 'signalement':
        return Icons.psychology_alt_outlined;
      case 'payment':
        return Icons.account_balance_wallet_outlined;
      case 'event':
      case 'upcomingevent':
        return Icons.event;
      default:
        return Icons.notifications;
    }
  }

  Color _colorForType(String type) {
    switch (type.toLowerCase()) {
      case 'pickup':
        return Colors.greenAccent;
      case 'signalement':
        return Colors.redAccent;
      case 'payment':
        return Colors.orangeAccent;
      case 'event':
      case 'upcomingevent':
        return Colors.purpleAccent;
      default:
        return TeacherTheme.indigoAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return Scaffold(
      backgroundColor: TeacherTheme.baseDark,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            fontFamily: TeacherTheme.fontName,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: TeacherTheme.lightText,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios, color: TeacherTheme.lightText),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: TeacherTheme.tealAccent),
            onPressed: _loadNotifications,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: RefreshIndicator(
        color: TeacherTheme.tealAccent,
        backgroundColor: TeacherTheme.surfaceDark,
        onRefresh: _loadNotifications,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: TeacherTheme.tealAccent),
      );
    }

    if (_error != null) {
      return Center(
        child: Text(_error!, style: TextStyle(color: TeacherTheme.mutedText)),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 48,
              color: TeacherTheme.mutedText.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Aucune notification.',
              style: TextStyle(
                fontFamily: TeacherTheme.fontName,
                fontSize: 15,
                color: TeacherTheme.mutedText,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_unreadCount > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: TeacherTheme.indigoAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: TeacherTheme.indigoAccent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '$_unreadCount non lue(s)',
                    style: TextStyle(
                      fontFamily: TeacherTheme.fontName,
                      color: TeacherTheme.indigoAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: _notifications.length,
            padding: EdgeInsets.only(
              top: 8,
              bottom: 100 + MediaQuery.of(context).padding.bottom,
            ),
            itemBuilder: (context, index) {
              final notification = _notifications[index];
              final typeColor = _colorForType(notification.type);

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Container(
                  decoration: TeacherTheme.surfaceCard(borderRadius: 14),
                  child: ListTile(
                    onTap: () {
                      if (!notification.isRead) {
                        _handleAction(notification);
                      }
                      if (notification.type.toLowerCase() == 'event' ||
                          notification.type.toLowerCase() == 'upcomingevent') {
                        final rawData =
                            notification.originalData is NotificationModel
                            ? (notification.originalData as NotificationModel)
                                  .data
                            : null;

                        Map<String, dynamic> parsedData = {};
                        if (rawData is Map) {
                          parsedData = Map<String, dynamic>.from(
                            rawData as Map,
                          );
                        } else if (rawData is String) {
                          try {
                            parsedData = jsonDecode(rawData as String);
                          } catch (_) {}
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EventDetailPage(eventData: parsedData),
                          ),
                        );
                      }
                    },
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _iconForType(notification.type),
                        color: typeColor,
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontFamily: TeacherTheme.fontName,
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              fontSize: 16,
                              color: notification.isRead
                                  ? TeacherTheme.mutedText
                                  : TeacherTheme.lightText,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: typeColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: typeColor.withValues(alpha: 0.5),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.message,
                            style: TextStyle(
                              fontFamily: TeacherTheme.fontName,
                              fontSize: 13,
                              color: TeacherTheme.mutedText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _timeAgo(notification.date),
                            style: TextStyle(
                              fontFamily: TeacherTheme.fontName,
                              fontSize: 11,
                              color: TeacherTheme.mutedText.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: notification.isRead
                        ? null
                        : IconButton(
                            icon: Icon(
                              notification.type == 'pickup'
                                  ? Icons.check_circle_outline
                                  : Icons.done,
                              color: TeacherTheme.tealAccent,
                            ),
                            onPressed: () => _handleAction(notification),
                            tooltip: notification.type == 'pickup'
                                ? 'Confirmer récupération'
                                : 'Marquer comme lu',
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
