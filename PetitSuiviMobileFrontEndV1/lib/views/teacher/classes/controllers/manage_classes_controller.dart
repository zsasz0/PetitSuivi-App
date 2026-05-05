import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:newv/models/teacher_models.dart';
import 'package:newv/models/planning.dart';
import 'package:newv/utils/unauthorized_handler.dart';
import 'package:newv/views/teacher/classes/apis/teacher_classes_api.dart';

class ManageClassesController {
  bool isLoading = true;
  String? error;
  List<ClassRoom> classrooms = [];

  Future<void> loadTeacherClasses({
    required BuildContext context,
    required String? token,
    required int? teacherCin,
    required Function(VoidCallback fn) setState,
    required bool Function() isMounted,
  }) async {
    if (token == null || token.isEmpty || teacherCin == null) {
      if (isMounted()) {
        setState(() {
          isLoading = false;
          error = 'Session enseignant introuvable. Reconnectez-vous.';
        });
      }
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await TeacherClassesApi.getTeacherClasses(teacherCin.toString(), token);

      if (!isMounted() || !context.mounted) {
        return;
      }

      if (UnauthorizedHandler.handle(
        context: context,
        statusCode: response.statusCode,
      )) {
        return;
      }

      final body = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          body['data'] is List) {
        final String? pStartStr = body['planning_start']?.toString();
        final String? pEndStr = body['planning_end']?.toString();
        final String? pLabel = body['planning_label']?.toString();
        final bool pArchived = body['planning_is_archived'] == true;
        
        final DateTime? pStart = pStartStr != null ? DateTime.tryParse(pStartStr) : null;
        final DateTime? pEnd = pEndStr != null ? DateTime.tryParse(pEndStr) : null;

        final fetchedClassrooms = (body['data'] as List)
            .whereType<Map>()
            .map(
              (item) => ClassMapper.mapClassroom(
                item.cast<String, dynamic>(),
                pStart,
                pEnd,
                pLabel,
                pArchived,
              ),
            )
            .toList();

        setState(() {
          classrooms = fetchedClassrooms;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          error = body['message']?.toString() ?? 'Impossible de charger les classes.';
        });
      }
    } catch (_) {
      if (!isMounted()) return;
      setState(() {
        isLoading = false;
        error = 'Erreur réseau. Vérifiez la connexion à l\'API.';
      });
    }
  }
}

class ClassMapper {
  static ClassRoom mapClassroom(
    Map<String, dynamic> json, [
    DateTime? pStart,
    DateTime? pEnd,
    String? pLabel,
    bool? pArchived,
  ]) {
    final classId = json['id']?.toString() ?? '';
    final rawStudents = (json['students'] is List) ? json['students'] as List : const [];

    final children = rawStudents.whereType<Map>().map((item) {
      final child = item.cast<String, dynamic>();
      final rawFirst = child['first_name']?.toString() ?? child['firstName']?.toString() ?? '';
      final rawLast = child['last_name']?.toString() ?? child['lastName']?.toString() ?? '';

      return MockChild(
        id: child['id']?.toString() ?? '',
        firstName: rawFirst.trim().isEmpty ? 'U' : rawFirst.trim(),
        lastName: rawLast.trim().isEmpty ? 'U' : rawLast.trim(),
        age: _calculateAge(child['birthdate']?.toString()),
        classId: classId,
      );
    }).toList();

    return ClassRoom(
      id: classId,
      name: json['name']?.toString() ?? 'Classe',
      children: children,
      planning: (pStart != null && pEnd != null)
          ? Planning(
              label: pLabel ?? '',
              startDate: pStart,
              endDate: pEnd,
              isArchived: pArchived ?? false,
            )
          : null,
    );
  }

  static int _calculateAge(String? birthDateString) {
    if (birthDateString == null || birthDateString.isEmpty) return 0;
    try {
      final birthDate = DateTime.parse(birthDateString);
      final today = DateTime.now();
      var age = today.year - birthDate.year;
      if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age < 0 ? 0 : age;
    } catch (_) {
      return 0;
    }
  }
}
