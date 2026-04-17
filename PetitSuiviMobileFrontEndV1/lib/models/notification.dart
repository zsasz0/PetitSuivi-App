import 'account.dart';
import 'notification_type.dart';
import 'events.dart';

class Notification {
  // Attributes
  final int? id;
  final bool isRead;
  final String message;
  final String title;

  // Associations
  final Account recipient;
  final NotificationType type;
  final Events? relatedEvent;

  Notification({
    this.id,
    required this.isRead,
    required this.message,
    required this.title,
    required this.recipient,
    required this.type,
    this.relatedEvent,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as int?,
      isRead: json['isRead'] as bool,
      message: json['message'] as String,
      title: json['title'] as String,
      recipient: Account.fromJson(json['recipient'] as Map<String, dynamic>),
      type: NotificationType.fromJson(json['type'] as Map<String, dynamic>),
      relatedEvent: json['relatedEvent'] != null
          ? Events.fromJson(json['relatedEvent'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isRead': isRead,
      'message': message,
      'title': title,
      'recipient': recipient.toJson(),
      'type': type.toJson(),
      'relatedEvent': relatedEvent?.toJson(),
    };
  }
}
