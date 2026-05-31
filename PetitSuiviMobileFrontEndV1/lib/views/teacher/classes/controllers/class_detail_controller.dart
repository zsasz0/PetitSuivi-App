import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:newv/models/teacher_models.dart';
import 'package:newv/utils/unauthorized_handler.dart';
import 'package:newv/views/teacher/classes/apis/teacher_classes_api.dart';
import 'package:newv/views/teacher/classes/themes/teacher_classes_theme.dart';

class ClassDetailController {
  DateTime selectedDate = _nearestWeekday(DateTime.now());
  Map<String, bool> attendance = {};
  Map<String, int> presenceIdByChild = {};
  Map<String, String> presenceStatusByChild = {};
  bool isLoadingAttendance = false;
  bool isSavingAttendance = false;
  String? attendanceError;

  static DateTime _nearestWeekday(DateTime date) {
    if (date.weekday == DateTime.saturday) {
      return date.subtract(const Duration(days: 1)); // Friday
    } else if (date.weekday == DateTime.sunday) {
      return date.subtract(const Duration(days: 2)); // Friday
    }
    return date;
  }

  bool isWeekend(DateTime date) =>
      date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

  int getPresentCount() => attendance.values.where((v) => v).length;
  int getAbsentCount() => attendance.values.where((v) => !v).length;

  Future<void> loadAttendance({
    required BuildContext context,
    required ClassRoom classroom,
    required String? token,
    required Function(VoidCallback fn) setState,
    required bool Function() isMounted,
  }) async {
    final requestedDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final defaultAttendance = <String, bool>{
      for (final child in classroom.children) child.id: true,
    };

    final classId = int.tryParse(classroom.id);

    if (token == null || token.isEmpty || classId == null) {
      setState(() {
        attendance = defaultAttendance;
        presenceIdByChild = {};
        presenceStatusByChild = {};
        attendanceError =
            'Session invalide ou identifiant de classe incorrect.';
        isLoadingAttendance = false;
      });
      return;
    }

    setState(() {
      isLoadingAttendance = true;
      attendanceError = null;
      attendance = defaultAttendance;
      presenceIdByChild = {};
      presenceStatusByChild = {};
    });

    try {
      final response = await TeacherClassesApi.getAttendance(
        classId,
        requestedDate.month,
        requestedDate.year,
        token,
      );

      if (!isMounted() || !context.mounted) {
        return;
      }
      if (UnauthorizedHandler.handle(
        context: context,
        statusCode: response.statusCode,
      )) {
        return;
      }

      if (!_isSameDay(requestedDate, selectedDate)) {
        return;
      }

      final body = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          body['data'] is! List) {
        setState(() {
          isLoadingAttendance = false;
          attendanceError =
              body['message']?.toString() ??
              'Impossible de charger les présences.';
        });
        return;
      }

      final nextAttendance = Map<String, bool>.from(defaultAttendance);
      final nextPresenceIds = <String, int>{};
      final nextPresenceStatuses = <String, String>{};

      for (final rawItem in body['data'] as List) {
        if (rawItem is! Map) continue;
        final item = rawItem.cast<String, dynamic>();

        final date = DateTime.tryParse(item['date']?.toString() ?? '');
        if (date == null || !_isSameDay(date, requestedDate)) continue;

        final childRaw = item['child'];
        String childId = (childRaw is Map)
            ? (childRaw['id']?.toString() ?? '')
            : '';
        childId = childId.isNotEmpty
            ? childId
            : (item['child_id']?.toString() ?? '');

        if (childId.isEmpty || !nextAttendance.containsKey(childId)) continue;

        final statusRaw = item['status'];
        final statusName = statusRaw is Map
            ? statusRaw['name']?.toString().toLowerCase()
            : null;
        if (statusName == null ||
            (statusName != 'present' && statusName != 'absent'))
          continue;

        final presenceId = int.tryParse(item['id']?.toString() ?? '');
        if (presenceId == null) continue;

        nextAttendance[childId] = statusName == 'present';
        nextPresenceIds[childId] = presenceId;
        nextPresenceStatuses[childId] = statusName;
      }

      setState(() {
        attendance = nextAttendance;
        presenceIdByChild = nextPresenceIds;
        presenceStatusByChild = nextPresenceStatuses;
        isLoadingAttendance = false;
        attendanceError = null;
      });
    } catch (_) {
      if (!isMounted()) return;
      setState(() {
        isLoadingAttendance = false;
        attendanceError = 'Erreur réseau. Vérifiez la connexion à l\'API.';
      });
    }
  }

  void toggleAttendance(
    String childId,
    BuildContext context,
    Function(VoidCallback fn) setState,
  ) {
    if (isWeekend(selectedDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de marquer la présence le week-end.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    final now = DateTime.now();
    if (!_isSameDay(selectedDate, now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vous ne pouvez modifier que l\'appel d\'aujourd\'hui.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() {
      attendance[childId] = !(attendance[childId] ?? true);
    });
  }

  Future<void> saveAttendance({
    required BuildContext context,
    required ClassRoom classroom,
    required String? token,
    required Function(VoidCallback fn) setState,
    required bool Function() isMounted,
  }) async {
    if (isSavingAttendance) return;

    if (isWeekend(selectedDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'enregistrer la présence le week-end.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final now = DateTime.now();
    if (!_isSameDay(selectedDate, now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vous ne pouvez modifier que l\'appel d\'aujourd\'hui.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final classId = int.tryParse(classroom.id);
    if (token == null || token.isEmpty || classId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session invalide. Reconnectez-vous.')),
      );
      return;
    }

    setState(() {
      isSavingAttendance = true;
      attendanceError = null;
    });

    final dateString = _formatDate(selectedDate);
    final failures = <String>[];

    for (final child in classroom.children) {
      final childId = int.tryParse(child.id);
      if (childId == null) {
        failures.add('ID enfant invalide: ${child.fullName}');
        continue;
      }

      final isPresent = attendance[child.id] ?? true;
      final desiredStatus = isPresent ? 'present' : 'absent';
      final existingPresenceId = presenceIdByChild[child.id];
      final existingStatus = presenceStatusByChild[child.id];

      if (existingPresenceId == null) {
        final response = await TeacherClassesApi.postAttendance(classId, {
          'child_id': childId,
          'date': dateString,
          'status': desiredStatus,
        }, token);

        if (!isMounted() || !context.mounted) {
          return;
        }
        if (UnauthorizedHandler.handle(
          context: context,
          statusCode: response.statusCode,
        )) {
          setState(() => isSavingAttendance = false);
          return;
        }

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final body = response.body.isNotEmpty
              ? jsonDecode(response.body) as Map<String, dynamic>
              : <String, dynamic>{};
          final data = body['data'];
          if (data is Map) {
            final createdId = int.tryParse(data['id']?.toString() ?? '');
            if (createdId != null) {
              presenceIdByChild[child.id] = createdId;
              presenceStatusByChild[child.id] = desiredStatus;
            }
          }
        } else {
          failures.add(_extractErrorMessage(response.body, child.fullName));
        }
        continue;
      }

      if (existingStatus == desiredStatus) continue;

      final response = await TeacherClassesApi.putAttendance(
        classId,
        existingPresenceId,
        {'date': dateString, 'status': desiredStatus},
        token,
      );

      if (!isMounted() || !context.mounted) {
        return;
      }
      if (UnauthorizedHandler.handle(
        context: context,
        statusCode: response.statusCode,
      )) {
        setState(() => isSavingAttendance = false);
        return;
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        presenceStatusByChild[child.id] = desiredStatus;
      } else {
        failures.add(_extractErrorMessage(response.body, child.fullName));
      }
    }

    if (!isMounted() || !context.mounted) {
      return;
    }

    setState(() => isSavingAttendance = false);

    if (failures.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Présence enregistrée avec succès !',
            style: TextStyle(fontFamily: TeacherClassesTheme.fontName),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(failures.first),
          backgroundColor: Colors.redAccent,
        ),
      );
    }

    await loadAttendance(
      context: context,
      classroom: classroom,
      token: token,
      setState: setState,
      isMounted: isMounted,
    );
  }

  Future<void> pickDate({
    required BuildContext context,
    required ClassRoom classroom,
    required String? token,
    required Function(VoidCallback fn) setState,
    required bool Function() isMounted,
  }) async {
    final DateTime now = DateTime.now();
    final DateTime firstDate =
        classroom.planning?.startDate ??
        DateTime(now.year - 1, now.month, now.day);
    DateTime lastDate = classroom.planning?.endDate ?? now;

    if (lastDate.isBefore(firstDate))
      lastDate = firstDate.add(const Duration(days: 365));

    DateTime initial = selectedDate;
    if (initial.isBefore(firstDate)) {
      initial = firstDate;
    } else if (initial.isAfter(lastDate)) {
      initial = lastDate;
    }

    if (isWeekend(initial)) {
      initial = _nearestWeekday(initial);
      if (initial.isBefore(firstDate)) initial = firstDate;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('fr', 'FR'),
      selectableDayPredicate: (DateTime day) => !isWeekend(day),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: TeacherClassesTheme.tealAccent,
              onPrimary: TeacherClassesTheme.baseDark,
              surface: TeacherClassesTheme.cardDark,
              onSurface: TeacherClassesTheme.lightText,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
      if (!context.mounted) return;
      await loadAttendance(
        context: context,
        classroom: classroom,
        token: token,
        setState: setState,
        isMounted: isMounted,
      );
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _extractErrorMessage(String responseBody, String childName) {
    if (responseBody.isNotEmpty) {
      try {
        final body = jsonDecode(responseBody) as Map<String, dynamic>;
        final message = body['message']?.toString();
        if (message != null && message.isNotEmpty)
          return '$childName: $message';
      } catch (_) {}
    }
    return '$childName: erreur lors de l\'enregistrement.';
  }
}
