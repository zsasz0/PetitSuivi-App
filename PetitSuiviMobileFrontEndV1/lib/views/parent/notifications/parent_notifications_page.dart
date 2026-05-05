import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/views/themes/theme_manager.dart';
import 'package:provider/provider.dart';

// Modular Architecture Imports
import 'package:newv/views/parent/notifications/controllers/notification_controller.dart';
import 'package:newv/views/parent/notifications/themes/notification_theme.dart';
import 'package:newv/views/parent/notifications/components/notifications/empty_notifications.dart';
import 'package:newv/views/parent/notifications/components/notifications/notification_card.dart';

/// A page that fetches and displays notifications specific to the parent's children.
/// Standardized into the PetitSuivi Modular Architecture.
class ParentNotificationsPage extends StatefulWidget {
  const ParentNotificationsPage({super.key});

  @override
  State<ParentNotificationsPage> createState() =>
      _ParentNotificationsPageState();
}

class _ParentNotificationsPageState extends State<ParentNotificationsPage> {
  late NotificationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = NotificationController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadNotifications(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch ThemeManager to rebuild on theme changes
    context.watch<ThemeManager>();

    return ChangeNotifierProvider<NotificationController>.value(
      value: _controller,
      child: Container(
        color: NotificationTheme.baseDark,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: _buildAppBar(),
          body: Consumer<NotificationController>(
            builder: (context, controller, child) {
              return _buildBody(controller);
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      centerTitle: true,
      title: Text(
        'Notifications',
        style: TextStyle(
          fontFamily: AppTheme.fontName,
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: NotificationTheme.lightText,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: NotificationTheme.tealAccent),
          onPressed: () => _controller.loadNotifications(context),
          tooltip: 'Rafraîchir',
        ),
        Consumer<NotificationController>(
          builder: (context, controller, child) {
            if (controller.unreadCount > 0) {
              return TextButton.icon(
                onPressed: () => controller.markAllAsRead(context),
                icon: Icon(
                  Icons.done_all_rounded,
                  color: NotificationTheme.tealAccent,
                  size: 20,
                ),
                label: Text(
                  'Tout lu',
                  style: TextStyle(
                    color: NotificationTheme.tealAccent,
                    fontFamily: AppTheme.fontName,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildBody(NotificationController controller) {
    if (controller.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: NotificationTheme.tealAccent),
      );
    }

    if (controller.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: NotificationTheme.errorColor,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              controller.error!,
              style: TextStyle(color: NotificationTheme.lightText),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.loadNotifications(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: NotificationTheme.indigoAccent,
              ),
              child: const Text(
                'Réessayer',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (controller.notifications.isEmpty) {
      return const EmptyNotifications();
    }

    return RefreshIndicator(
      onRefresh: () => controller.loadNotifications(context),
      color: NotificationTheme.tealAccent,
      backgroundColor: NotificationTheme.baseDark,
      child: Column(
        children: [
          if (controller.unreadCount > 0)
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
                      color: NotificationTheme.indigoAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: NotificationTheme.indigoAccent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '${controller.unreadCount} non lue(s)',
                      style: TextStyle(
                        fontFamily: AppTheme.fontName,
                        color: NotificationTheme.indigoAccent,
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
              itemCount: controller.notifications.length,
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 8,
                bottom: 100,
              ),
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final alert = controller.notifications[index];
                return NotificationCard(
                  alert: alert,
                  onMarkAsRead: () => controller.markAsRead(context, alert.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
