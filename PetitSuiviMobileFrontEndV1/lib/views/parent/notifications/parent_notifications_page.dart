import 'package:flutter/material.dart';
import 'package:newv/app_theme.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:newv/theme_manager.dart';
import 'widgets/notification_card.dart';
import 'widgets/empty_notifications.dart';

// File: parent_notifications_page.dart
// Purpose: Centralized list of alerts and messages for parents.
// Usage: Accessed via the "Notifications" tab or drawer.
// API Usage:
//   - GET /api/notifications (Fetch notifications)
//   - POST /api/notifications/{id}/read (Mark as read)
//   - POST /api/notifications/mark-all-read
// Dependencies: AuthSession, NotificationService, EventDetailPage.

/// A page that fetches and displays notifications specific to the parent's children.
class ParentNotificationsPage extends StatefulWidget {
  const ParentNotificationsPage({super.key});

  @override
  State<ParentNotificationsPage> createState() =>
      _ParentNotificationsPageState();
}

class _ParentNotificationsPageState extends State<ParentNotificationsPage> {
  // Modern Theme Colors
  static Color get _baseDark => ThemeManager.instance.isLightMode
      ? const Color(0xFFF0F2F5)
      : const Color(0xFF141B2D);
  static Color get _tealAccent => ThemeManager.instance.isLightMode
      ? const Color(0xFF009688)
      : const Color(0xFF4CCEAC);
  static Color get _indigoAccent => ThemeManager.instance.isLightMode
      ? const Color(0xFF3F51B5)
      : const Color(0xFF6870FA);
  static Color get _lightText => ThemeManager.instance.isLightMode
      ? const Color(0xFF212529)
      : const Color(0xFFF2F0F0);

  final NotificationService _notificationService = NotificationService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  Future<void> _loadNotifications() async {
    if (!mounted) return;
    final token = context.read<AuthSession>().token;
    if (token == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Session expirée';
        });
      }
      return;
    }

    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }
      final notifications = await _notificationService.getNotifications(
        token,
        'parent',
      );
      notifications.sort((a, b) {
        final dateCompare = b.createdAt.compareTo(a.createdAt);
        if (dateCompare != 0) return dateCompare;
        return b.id.compareTo(a.id);
      });
      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erreur: $e';
          _isLoading = false;
        });
      }
    }
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> _markAsRead(int id) async {
    final token = context.read<AuthSession>().token;
    if (token == null) return;

    // Optimistic update
    setState(() {
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
      }
    });

    try {
      await _notificationService.markAsRead(token, 'parent', id);
    } catch (e) {
      _loadNotifications(); // Reload on error
    }
  }

  Future<void> _markAllAsRead() async {
    final token = context.read<AuthSession>().token;
    if (token == null) return;

    // Optimistic update
    setState(() {
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
    });

    try {
      await _notificationService.markAllAsRead(token, 'parent');
    } catch (e) {
      _loadNotifications(); // Reload on error
    }
  }

  // Removed individual formatters (moved to NotificationCard)

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return Container(
      color: _baseDark,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Notifications',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: _lightText,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: _tealAccent),
              onPressed: _loadNotifications,
              tooltip: 'Rafraîchir',
            ),
            if (_unreadCount > 0)
              TextButton.icon(
                onPressed: _markAllAsRead,
                icon: Icon(
                  Icons.done_all_rounded,
                  color: _tealAccent,
                  size: 20,
                ),
                label: Text(
                  'Tout lu',
                  style: TextStyle(
                    color: _tealAccent,
                    fontFamily: AppTheme.fontName,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: _tealAccent));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(_error!, style: TextStyle(color: _lightText)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNotifications,
              style: ElevatedButton.styleFrom(backgroundColor: _indigoAccent),
              child: const Text(
                'Réessayer',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return const EmptyNotifications();
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      color: _tealAccent,
      backgroundColor: _baseDark,
      child: Column(
        children: [
          if (_unreadCount > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _indigoAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _indigoAccent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '$_unreadCount non lue(s)',
                      style: TextStyle(
                        fontFamily: AppTheme.fontName,
                        color: _indigoAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.separated(
              itemCount: _notifications.length,
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 8,
                bottom: 100,
              ),
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final alert = _notifications[index];
                return NotificationCard(
                  alert: alert,
                  onMarkAsRead: () => _markAsRead(alert.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
