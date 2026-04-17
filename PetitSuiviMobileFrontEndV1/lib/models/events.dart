import 'notification.dart';

class Events {
  final int? id;
  final DateTime date;
  final String description;
  final DateTime endTime;
  final String name;
  final bool notificationSend;
  final int starttime;
  final String status;

  // Associations
  final List<Notification> notifications;

  Events({
    this.id,
    required this.date,
    required this.description,
    required this.endTime,
    required this.name,
    required this.notificationSend,
    required this.starttime,
    required this.status,
    this.notifications = const [],
  });

  // Derived Attribute
  int get duration {
    return endTime.millisecondsSinceEpoch - starttime;
  }

  factory Events.fromJson(Map<String, dynamic> json) {
    return Events(
      id: json['id'] as int?,
      date: DateTime.parse(json['date']),
      description: json['description'] as String,
      endTime: DateTime.parse(json['endTime']),
      name: json['name'] as String,
      notificationSend: json['notificationSend'] as bool,
      starttime: json['starttime'] as int,
      status: json['status'] as String,
      notifications: json['notifications'] != null
          ? (json['notifications'] as List)
              .map((e) => Notification.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'description': description,
      'endTime': endTime.toIso8601String(),
      'name': name,
      'notificationSend': notificationSend,
      'starttime': starttime,
      'status': status,
      'notifications': notifications.map((e) => e.toJson()).toList(),
    };
  }
}
