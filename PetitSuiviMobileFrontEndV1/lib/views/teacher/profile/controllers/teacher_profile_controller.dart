import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/utils/unauthorized_handler.dart';
import 'package:newv/views/auth/login/login_page.dart';
import 'package:newv/views/teacher/profile/apis/teacher_profile_api.dart';
import 'package:provider/provider.dart';

class TeacherProfileController {
  final BuildContext context;
  
  TeacherProfileController(this.context);

  bool _isMounted = true;

  void dispose() {
    _isMounted = false;
  }

  bool get mounted => _isMounted;

  Future<Map<String, int>?> fetchStats() async {
    final session = context.read<AuthSession>();
    final token = session.token;
    final teacherCin = session.cin;

    if (token == null || token.isEmpty || teacherCin == null) {
      return null;
    }

    try {
      final response = await TeacherProfileApi.fetchStats(
        token: token,
        teacherCin: teacherCin.toString(),
      );

      if (!context.mounted) return null;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};
        final data = body['data'];

        if (data is List) {
          int totalClasses = data.length;
          int totalStudents = 0;
          for (var c in data) {
            if (c is Map && c['students'] is List) {
              totalStudents += (c['students'] as List).length;
            }
          }
          return {
            'classes': totalClasses,
            'enfants': totalStudents,
          };
        }
      }
    } catch (_) {}

    return null;
  }

  void handleLogout() {
    context.read<AuthSession>().clear();
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  int calculateAge(String? birthDateString) {
    if (birthDateString == null || birthDateString.isEmpty) return 0;
    try {
      final birthDate = DateTime.parse(birthDateString);
      final today = DateTime.now();
      var age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return 0;
    }
  }

  int calculateYearsOfTeaching(String? inscriptionDateString) {
    if (inscriptionDateString == null || inscriptionDateString.isEmpty) {
      return 0;
    }
    try {
      final startDate = DateTime.parse(inscriptionDateString);
      final today = DateTime.now();
      var years = today.year - startDate.year;
      if (today.month < startDate.month ||
          (today.month == startDate.month && today.day < startDate.day)) {
        years--;
      }
      return years < 0 ? 0 : years;
    } catch (_) {
      return 0;
    }
  }

  Future<bool> changePassword(String newPassword) async {
    final session = context.read<AuthSession>();
    final token = session.token;

    if (token == null || token.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session invalide. Reconnectez-vous.')),
        );
      }
      return false;
    }

    try {
      final response = await TeacherProfileApi.changePassword(
        token: token,
        newPassword: newPassword,
      );

      if (!context.mounted) return false;

      if (UnauthorizedHandler.handle(
        context: context,
        statusCode: response.statusCode,
      )) {
        return false;
      }

      final body = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                body['message']?.toString() ?? 'Mot de passe modifié.',
              ),
            ),
          );
        }
        return true;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              body['message']?.toString() ??
                  'Échec du changement de mot de passe.',
            ),
          ),
        );
      }
      return false;
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur réseau.')),
        );
      }
      return false;
    }
  }
}
