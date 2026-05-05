/// teacher_notifications_page.dart
///
/// Unified notification center for teachers combining pickup alerts
/// (parent arrival notifications) and general system notifications
/// (events, signalements, payments, etc.).
library;

import 'package:flutter/material.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/services/notification_service.dart';
import 'package:newv/views/themes/theme_manager.dart';
import 'package:newv/views/shared/event_detail_page.dart';
import 'package:newv/views/teacher/notifications/components/notifications/empty_notifications.dart';
import 'package:newv/views/teacher/notifications/components/notifications/notification_card.dart';
import 'package:newv/views/teacher/notifications/components/notifications/unread_badge.dart';
import 'package:newv/views/teacher/notifications/controllers/teacher_notifications_controller.dart';
import 'package:newv/views/teacher/notifications/themes/teacher_notifications_theme.dart';
import 'package:provider/provider.dart';

/// A scrollable list of notifications with real-time refresh and action handling (reading, confirming).
class TeacherNotificationsPage extends StatefulWidget {
  const TeacherNotificationsPage({super.key});

  @override
  State<TeacherNotificationsPage> createState() => _TeacherNotificationsPageState();
}

class _TeacherNotificationsPageState extends State<TeacherNotificationsPage> {
  late final TeacherNotificationsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TeacherNotificationsController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final token = context.read<AuthSession>().token;
    if (token != null) {
      _controller.loadNotifications(token);
    }
  }

  Future<void> _handleNotificationTap(CombinedNotification notification) async {
    final token = context.read<AuthSession>().token;
    if (token == null) return;

    if (!notification.isRead) {
      await _controller.handleAction(notification, token);
    }

    if (!mounted) return;

    if (notification.type.toLowerCase() == 'event' || notification.type.toLowerCase() == 'upcomingevent') {
      final rawData = notification.originalData is NotificationModel ? (notification.originalData as NotificationModel).data : null;

      if (rawData != null) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(rawData);
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailPage(eventData: data),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return ChangeNotifierProvider<TeacherNotificationsController>.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: TeacherNotificationsTheme.backgroundColor,
        appBar: AppBar(
          title: Text('Notifications', style: TeacherNotificationsTheme.titleStyle),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Navigator.canPop(context)
              ? IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: TeacherNotificationsTheme.lightText),
                  onPressed: () => Navigator.pop(context),
                )
              : null,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: TeacherNotificationsTheme.accentColor),
              onPressed: _loadData,
              tooltip: 'Rafraîchir',
            ),
          ],
        ),
        body: RefreshIndicator(
          color: TeacherNotificationsTheme.accentColor,
          backgroundColor: TeacherNotificationsTheme.surfaceColor,
          onRefresh: () async => _loadData(),
          child: Consumer<TeacherNotificationsController>(
            builder: (context, controller, child) {
              if (controller.isLoading) {
                return Center(
                  child: CircularProgressIndicator(color: TeacherNotificationsTheme.accentColor),
                );
              }

              if (controller.error != null) {
                return Center(
                  child: Text(
                    controller.error!,
                    style: TextStyle(color: TeacherNotificationsTheme.mutedText),
                  ),
                );
              }

              if (controller.notifications.isEmpty) {
                return const EmptyNotifications();
              }

              return Column(
                children: [
                  UnreadBadge(count: controller.unreadCount),
                  Expanded(
                    child: ListView.builder(
                      itemCount: controller.notifications.length,
                      padding: EdgeInsets.only(
                        top: 8,
                        bottom: 100 + MediaQuery.of(context).padding.bottom,
                      ),
                      itemBuilder: (context, index) {
                        final notification = controller.notifications[index];
                        return NotificationCard(
                          notification: notification,
                          timeAgo: controller.timeAgo(notification.date),
                          onTap: () => _handleNotificationTap(notification),
                          onAction: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final token = context.read<AuthSession>().token;
                            if (token != null) {
                              final success = await controller.handleAction(notification, token);
                              if (success) {
                                if (notification.type == 'pickup') {
                                  messenger.showSnackBar(
                                    const SnackBar(content: Text('Récupération confirmée')),
                                  );
                                }
                              } else {
                                messenger.showSnackBar(
                                  const SnackBar(content: Text('Erreur lors de l\'action')),
                                );
                              }
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
