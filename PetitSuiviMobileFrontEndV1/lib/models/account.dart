import 'role.dart';
import 'notification.dart';

class Account {
  // Stored Attributes
  final String adresse;
  final String approvalStatus;
  final DateTime birthdate;
  final int cin;
  final String email;
  final String firstName;
  final DateTime inscriptiondate;
  final bool isArchived;
  final String lastName;
  final String password;
  final int phone;

  // Associations
  final Role role;
  final List<Notification> notifications;

  Account({
    required this.adresse,
    required this.approvalStatus,
    required this.birthdate,
    required this.cin,
    required this.email,
    required this.firstName,
    required this.inscriptiondate,
    required this.isArchived,
    required this.lastName,
    required this.password,
    required this.phone,
    required this.role,
    this.notifications = const [],
  });

  // Derived Attributes
  String get fullName => '$firstName $lastName';

  int get age {
    final now = DateTime.now();
    int computedAge = now.year - birthdate.year;
    if (now.month < birthdate.month ||
        (now.month == birthdate.month && now.day < birthdate.day)) {
      computedAge--;
    }
    return computedAge;
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    // Helper to parse dates with multiple possible keys
    DateTime parseDate(List<String> keys) {
      for (final key in keys) {
        if (json[key] != null) {
          try {
            return DateTime.parse(json[key].toString());
          } catch (_) {}
        }
      }
      return DateTime.now();
    }

    return Account(
      adresse: (json['adresse'] ?? json['address'] ?? '').toString(),
      approvalStatus: (json['approvalStatus'] ?? json['approval_status'] ?? 'pending').toString(),
      birthdate: parseDate(['birthdate', 'birth_date']),
      cin: json['cin'] is int ? json['cin'] as int : int.tryParse(json['cin']?.toString() ?? '0') ?? 0,
      email: (json['email'] ?? '').toString(),
      firstName: (json['firstName'] ?? json['first_name'] ?? '').toString(),
      inscriptiondate: parseDate(['inscriptiondate', 'inscription_date', 'inscriptionDate']),
      isArchived: json['isArchived'] ?? json['is_archived'] ?? false,
      lastName: (json['lastName'] ?? json['last_name'] ?? '').toString(),
      password: (json['password'] ?? '').toString(),
      phone: json['phone'] is int ? json['phone'] as int : int.tryParse(json['phone']?.toString() ?? '0') ?? 0,
      role: Role.fromJson(json['role'] as Map<String, dynamic>),
      notifications: json['notifications'] != null
          ? (json['notifications'] as List)
              .map((e) => Notification.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'adresse': adresse,
      'approvalStatus': approvalStatus,
      'birthdate': birthdate.toIso8601String(),
      'cin': cin,
      'email': email,
      'firstName': firstName,
      'inscriptiondate': inscriptiondate.toIso8601String(),
      'isArchived': isArchived,
      'lastName': lastName,
      'password': password,
      'phone': phone,
      'role': role.toJson(),
      'notifications': notifications.map((e) => e.toJson()).toList(),
    };
  }
}
