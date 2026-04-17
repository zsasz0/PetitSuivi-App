import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/views/auth/register/entities/child.dart';
import 'package:newv/views/auth/register/entities/inscription.dart';

import 'package:newv/views/auth/register/entities/class.dart' as entities;
import 'package:newv/models/signalement.dart';
import 'package:newv/utils/unauthorized_handler.dart';
import 'package:newv/services/pickup_notification_service.dart';
import 'package:newv/views/parent/child_tracking/apis/child_tracking_apis.dart';
import 'package:provider/provider.dart';

class ChildTrackingController extends ChangeNotifier {
  /// children list
  List<Child> children = [];
  /// loading indicator
  bool isLoadingChildren = true;
  /// error message
  String? errorMessage;
  /// inscriptions open
  bool inscriptionsOpen = true;

  // Signalement logic
  List<Signalement> todaySignalements = [];
  /// alert dismissed
  bool alertDismissed = false;
  /// last seen children version
  int lastSeenChildrenVersion = -1;
  /// last seen sync version
  int lastSeenSyncVersion = -1;
  /// pickup notified child keys
  final Set<String> _pickupNotifiedChildKeys = <String>{};
  /// check inscriptions open
  Future<void> checkInscriptionsOpen() async {
    try {
      final response = await ChildTrackingApis.checkInscriptionsOpen();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        final params = data is List ? data : (data['data'] ?? []);
        for (final p in params) {
          if (p['name'] == 'inscriptions_open') {
            inscriptionsOpen = p['value'] == 'true' || p['value'] == '1';
            /// notify listeners 
            notifyListeners();
            break;
          }
        }
      }
    } catch (_) {}
  }

  Future<void> loadChildren(BuildContext context) async {
    final session = context.read<AuthSession>();
    final token = session.token;
    final parentCin = session.cin;

    if (token == null || token.isEmpty || parentCin == null) {
      isLoadingChildren = false;
      errorMessage = 'Session parent introuvable. Reconnectez-vous.';
      notifyListeners();
      return;
    }

    isLoadingChildren = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await ChildTrackingApis.loadChildren(parentCin.toString(), token);

      if (!context.mounted) return;
      if (UnauthorizedHandler.handle(
        context: context,
        statusCode: response.statusCode,
      )) {
        return;
      }

      final body = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final rawChildren = body['data'];
        if (rawChildren is List) {
          children = rawChildren.whereType<Map>().map((item) {
            final map = item.cast<String, dynamic>();
            return Child(
              id: map['id'] is int ? map['id'] as int : int.tryParse(map['id']?.toString() ?? ''),
              firstName: (map['firstName'] ?? '').toString(),
              lastName: (map['lastName'] ?? '').toString(),
              birthDate: map['birthdate'] != null
                  ? DateTime.tryParse(map['birthdate'].toString()) ?? DateTime.now()
                  : DateTime.now(),
              inscriptions: (map['inscriptions'] as List?)
                  ?.whereType<Map>()
                  .map((i) => Inscription.fromJson(i.cast<String, dynamic>()))
                  .toList() ?? [],
              classes: (map['classes'] as List?)
                  ?.whereType<Map>()
                  .map((c) => entities.SchoolClass.fromJson(c.cast<String, dynamic>()))
                  .toList() ?? [],
            );
          }).toList();
          isLoadingChildren = false;
          notifyListeners();
        } else {
          isLoadingChildren = false;
          errorMessage = 'Format de réponse invalide.';
          notifyListeners();
        }
      } else {
        isLoadingChildren = false;
        errorMessage = body['message']?.toString() ?? 'Impossible de charger les enfants.';
        notifyListeners();
      }
    } catch (_) {
      isLoadingChildren = false;
      errorMessage = 'Erreur réseau. Vérifiez l\'API Laravel.';
      notifyListeners();
    }
  }

  Future<void> loadTodaySignalements(BuildContext context, int childId) async {
    final session = context.read<AuthSession>();
    final token = session.token;
    if (token == null || token.isEmpty) return;

    try {
      final response = await ChildTrackingApis.loadSignalements(childId, token);
      if (!context.mounted) return;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'];
        if (data is List) {
          final now = DateTime.now();
          final all = data
              .whereType<Map<String, dynamic>>()
              .map((e) => Signalement.fromJson(e))
              .toList();
          todaySignalements = all.where((s) =>
              !s.isRead &&
              s.incidentTime.year == now.year &&
              s.incidentTime.month == now.month &&
              s.incidentTime.day == now.day).toList();
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('[ChildTrackingController] Failed to load signalements: $e');
    }
  }

  Future<void> dismissTodaySignalements(BuildContext context, int childId) async {
    if (todaySignalements.isEmpty) {
      alertDismissed = true;
      notifyListeners();
      return;
    }

    final session = context.read<AuthSession>();
    final token = session.token;
    if (token == null || token.isEmpty) {
      alertDismissed = true;
      notifyListeners();
      return;
    }

    try {
      final ids = todaySignalements.map((s) => s.id).toList();
      final response = await ChildTrackingApis.markSignalementsAsRead(childId, token, ids);

      if (!context.mounted) return;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        alertDismissed = true;
        todaySignalements = [];
        notifyListeners();
      } else {
        throw Exception('Failed to mark as read');
      }
    } catch (e) {
      debugPrint('[ChildTrackingController] Failed to dismiss signalements: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de masquer le signalement pour le moment.')),
        );
      }
    }
  }

  bool isPickupNotified(Child child) {
    return _pickupNotifiedChildKeys.contains(_childKey(child));
  }

  String _childKey(Child child) {
    final id = child.id?.toString();
    if (id != null && id.isNotEmpty) {
      return 'id:$id';
    }
    return '${child.firstName}|${child.lastName}|${child.birthDate.toIso8601String()}';
  }

  bool needsReRegistration(Child child) {
    if (child.inscriptions.isEmpty) return false;
    final latest = child.inscriptions.last;
    final status = latest.status?.name.toLowerCase() ?? '';
    return status == 'inscription_requise';
  }

  bool isChildApproved(Child child) {
    if (child.inscriptions.isEmpty) return false;
    final latest = child.inscriptions.last;
    final status = latest.status?.name.toLowerCase() ?? '';
    return status == 'approved';
  }

  int calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  String? getCurrentClassName(Child child) {
    if (child.classes.isEmpty) return null;
    return child.classes.first.name;
  }

  Future<void> handlePickupNotification({
    required BuildContext context,
    required Child child,
    required int durationMinutes,
  }) async {
    final session = context.read<AuthSession>();
    final token = session.token;
    final childId = child.id;

    if (token == null || token.isEmpty || childId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Erreur : données de session ou enfant manquantes.'),
          backgroundColor: Colors.red.shade800,
        ),
      );
      return;
    }

    try {
      final service = PickupNotificationService();
      await service.sendNotification(
        childId,
        token,
        durationMinutes: durationMinutes,
      );

      if (!context.mounted) return;
      _pickupNotifiedChildKeys.add(_childKey(child));
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Enseignants informés ! Veuillez arriver dans $durationMinutes minutes pour récupérer ${child.firstName}.',
          ),
          backgroundColor: Colors.green.shade800,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'envoi: $e'),
          backgroundColor: Colors.red.shade800,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}
