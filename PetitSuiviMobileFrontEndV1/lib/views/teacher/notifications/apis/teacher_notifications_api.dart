import 'package:newv/services/notification_service.dart';
import 'package:newv/services/pickup_notification_service.dart';

class TeacherNotificationsApi {
  final PickupNotificationService _pickupService = PickupNotificationService();
  final NotificationService _unifiedService = NotificationService();

  Future<List<dynamic>> getPickupNotifications(String token) async {
    return await _pickupService.getTeacherNotifications(token);
  }

  Future<List<NotificationModel>> getUnifiedNotifications(String token) async {
    return await _unifiedService.getNotifications(token, 'teacher');
  }

  Future<void> markPickupAsCompleted(dynamic pickupId, String token) async {
    await _pickupService.markAsCompleted(pickupId, token);
  }

  Future<void> markNotificationAsRead(int notificationId, String token) async {
    await _unifiedService.markAsRead(token, 'teacher', notificationId);
  }
}
