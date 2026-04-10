import 'package:newv/theme_manager.dart';
import 'package:newv/utils/api_constants.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/models/teacher_models.dart';
import 'package:newv/utils/unauthorized_handler.dart';
import 'package:newv/views/teacher/classes/appel/appel_tab.dart';
import 'package:newv/views/teacher/classes/evaluation/class_evaluation_tab.dart';
import 'package:newv/views/teacher/teacher_theme.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

/// File: class_detail_page.dart
/// Purpose: Detailed view for a specific class, providing attendance and evaluation tabs.
/// Usage: Navigated from ManageClassesPage.
/// API Usage:
///   - GET /api/classes/{id}/presences
///     Fetches the presence list for a specific class on a specific month and year.
///   - POST /api/classes/{id}/presences
///     Records a new presence.
///   - PUT /api/classes/{id}/presences/{presence_id}
///     Updates an existing presence.
/// Dependencies: AppelTab, ClassEvaluationTab, TeacherTheme, AuthSession.

/// A tabbed page managing child attendance and skill evaluations for a specific classroom.
class ClassDetailPage extends StatefulWidget {
  final ClassRoom classroom;

  const ClassDetailPage({super.key, required this.classroom});

  @override
  State<ClassDetailPage> createState() => _ClassDetailPageState();
}

class _ClassDetailPageState extends State<ClassDetailPage>
    with SingleTickerProviderStateMixin {
  static const String _apiBaseUrl = ApiConstants.baseUrl;

  // ===========================================================================
  // STATE VARIABLES & CONTROLLERS
  // ===========================================================================
  late TabController _tabController;
  late DateTime _selectedDate;
  Map<String, bool> _attendance = {};
  Map<String, int> _presenceIdByChild = {};
  Map<String, String> _presenceStatusByChild = {};
  bool _isLoadingAttendance = false;
  bool _isSavingAttendance = false;
  String? _attendanceError;

  // ===========================================================================
  // DATE HELPERS
  // ===========================================================================

  /// Returns true if the given date falls on a Saturday or Sunday.
  bool _isWeekend(DateTime date) =>
      date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

  /// Shifts a date to the nearest past weekday (Friday) if it falls on a weekend.
  DateTime _nearestWeekday(DateTime date) {
    if (date.weekday == DateTime.saturday) {
      return date.subtract(const Duration(days: 1)); // Friday
    } else if (date.weekday == DateTime.sunday) {
      return date.subtract(const Duration(days: 2)); // Friday
    }
    return date;
  }

  // ===========================================================================
  // INIT & DISPOSE
  // ===========================================================================
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _selectedDate = _nearestWeekday(DateTime.now());
    _loadAttendance();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // DATA FETCHING & SAVING (ATTENDANCE)
  // ===========================================================================
  
  /// Loads the attendance data for the currently selected date.
  Future<void> _loadAttendance() async {
    final requestedDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    final defaultAttendance = <String, bool>{
      for (final child in widget.classroom.children) child.id: true,
    };

    final session = context.read<AuthSession>();
    final token = session.token;
    final classId = int.tryParse(widget.classroom.id);

    if (token == null || token.isEmpty || classId == null) {
      setState(() {
        _attendance = defaultAttendance;
        _presenceIdByChild = {};
        _presenceStatusByChild = {};
        _attendanceError =
            'Session invalide ou identifiant de classe incorrect.';
        _isLoadingAttendance = false;
      });
      return;
    }

    setState(() {
      _isLoadingAttendance = true;
      _attendanceError = null;
      _attendance = defaultAttendance;
      _presenceIdByChild = {};
      _presenceStatusByChild = {};
    });

    final uri = Uri.parse(
      '$_apiBaseUrl/api/classes/$classId/presences?month=${requestedDate.month}&year=${requestedDate.year}',
    );

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;
      if (UnauthorizedHandler.handle(
        context: context,
        statusCode: response.statusCode,
      )) {
        return;
      }

      if (!_isSameDay(requestedDate, _selectedDate)) {
        return;
      }

      final body = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          body['data'] is! List) {
        setState(() {
          _isLoadingAttendance = false;
          _attendanceError =
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
        if (date == null || !_isSameDay(date, requestedDate)) {
          continue;
        }

        final childRaw = item['child'];
        String childId = '';
        if (childRaw is Map) {
          childId = childRaw['id']?.toString() ?? '';
        }
        childId = childId.isNotEmpty
            ? childId
            : item['child_id']?.toString() ?? '';
        if (childId.isEmpty || !nextAttendance.containsKey(childId)) continue;

        final statusRaw = item['status'];
        final statusName = statusRaw is Map
            ? statusRaw['name']?.toString().toLowerCase()
            : null;
        if (statusName == null) continue;
        if (statusName != 'present' && statusName != 'absent') continue;

        final presenceId = int.tryParse(item['id']?.toString() ?? '');
        if (presenceId == null) continue;

        nextAttendance[childId] = statusName == 'present';
        nextPresenceIds[childId] = presenceId;
        nextPresenceStatuses[childId] = statusName;
      }

      setState(() {
        _attendance = nextAttendance;
        _presenceIdByChild = nextPresenceIds;
        _presenceStatusByChild = nextPresenceStatuses;
        _isLoadingAttendance = false;
        _attendanceError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingAttendance = false;
        _attendanceError = 'Erreur réseau. Vérifiez la connexion à l\'API.';
      });
    }
  }

  void _toggleAttendance(String childId) {
    if (_isWeekend(_selectedDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de marquer la présence le week-end.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() {
      _attendance[childId] = !(_attendance[childId] ?? true);
    });
  }

  Future<void> _saveAttendance() async {
    if (_isSavingAttendance) return;

    if (_isWeekend(_selectedDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'enregistrer la présence le week-end.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final session = context.read<AuthSession>();
    final token = session.token;
    final classId = int.tryParse(widget.classroom.id);
    if (token == null || token.isEmpty || classId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session invalide. Reconnectez-vous.')),
      );
      return;
    }

    setState(() {
      _isSavingAttendance = true;
      _attendanceError = null;
    });

    final dateString = _formatDate(_selectedDate);
    final failures = <String>[];

    for (final child in widget.classroom.children) {
      final childId = int.tryParse(child.id);
      if (childId == null) {
        failures.add('ID enfant invalide: ${child.fullName}');
        continue;
      }

      final isPresent = _attendance[child.id] ?? true;
      final desiredStatus = isPresent ? 'present' : 'absent';
      final existingPresenceId = _presenceIdByChild[child.id];
      final existingStatus = _presenceStatusByChild[child.id];

      if (existingPresenceId == null) {
        final uri = Uri.parse('$_apiBaseUrl/api/classes/$classId/presences');
        final response = await http.post(
          uri,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'child_id': childId,
            'date': dateString,
            'status': desiredStatus,
          }),
        );
        if (!mounted) return;
        if (UnauthorizedHandler.handle(
          context: context,
          statusCode: response.statusCode,
        )) {
          if (mounted) {
            setState(() {
              _isSavingAttendance = false;
            });
          }
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
              _presenceIdByChild[child.id] = createdId;
              _presenceStatusByChild[child.id] = desiredStatus;
            }
          }
        } else {
          failures.add(_extractErrorMessage(response.body, child.fullName));
        }

        continue;
      }

      if (existingStatus == desiredStatus) {
        continue;
      }

      final uri = Uri.parse(
        '$_apiBaseUrl/api/classes/$classId/presences/$existingPresenceId',
      );
      final response = await http.put(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'date': dateString, 'status': desiredStatus}),
      );
      if (!mounted) return;
      if (UnauthorizedHandler.handle(
        context: context,
        statusCode: response.statusCode,
      )) {
        if (mounted) {
          setState(() {
            _isSavingAttendance = false;
          });
        }
        return;
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _presenceStatusByChild[child.id] = desiredStatus;
      } else {
        failures.add(_extractErrorMessage(response.body, child.fullName));
      }
    }

    if (!mounted) return;

    setState(() {
      _isSavingAttendance = false;
    });

    if (failures.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Présence enregistrée avec succès !',
            style: TextStyle(fontFamily: TeacherTheme.fontName),
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

    await _loadAttendance();
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime firstDate =
        widget.classroom.planningStartDate ??
        DateTime(now.year - 1, now.month, now.day);
    DateTime lastDate = widget.classroom.planningEndDate ?? now;

    if (lastDate.isBefore(firstDate)) {
      lastDate = firstDate.add(const Duration(days: 365));
    }

    DateTime initial = _selectedDate;
    if (initial.isBefore(firstDate)) {
      initial = firstDate;
    } else if (initial.isAfter(lastDate)) {
      initial = lastDate;
    }

    // Ensure initial date is a weekday
    if (_isWeekend(initial)) {
      initial = _nearestWeekday(initial);
      if (initial.isBefore(firstDate)) initial = firstDate;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('fr', 'FR'),
      selectableDayPredicate: (DateTime day) => !_isWeekend(day),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: TeacherTheme.tealAccent,
              onPrimary: TeacherTheme.baseDark,
              surface: TeacherTheme.cardDark,
              onSurface: TeacherTheme.lightText,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      await _loadAttendance();
    }
  }

  int get _presentCount => _attendance.values.where((v) => v).length;
  int get _absentCount => _attendance.values.where((v) => !v).length;

  // ===========================================================================
  // UI BUILDING
  // ===========================================================================
  
  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return Scaffold(
      backgroundColor: TeacherTheme.baseDark,
      appBar: AppBar(
        title: Text(
          widget.classroom.name,
          style: TextStyle(
            fontFamily: TeacherTheme.fontName,
            fontWeight: FontWeight.bold,
            color: TeacherTheme.lightText,
            fontSize: 18,
          ),
        ),
        backgroundColor: TeacherTheme.surfaceDark,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: TeacherTheme.lightText),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: TeacherTheme.tealAccent,
          unselectedLabelColor: TeacherTheme.mutedText,
          indicatorColor: TeacherTheme.tealAccent,
          labelStyle: const TextStyle(
            fontFamily: TeacherTheme.fontName,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          tabs: const [
            Tab(icon: Icon(Icons.fact_check), text: 'Appel'),
            Tab(icon: Icon(Icons.assessment), text: 'Évaluation'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ClassAttendanceTab(
            classroom: widget.classroom,
            selectedDate: _selectedDate,
            onPickDate: _pickDate,
            attendance: _attendance,
            onToggleAttendance: _toggleAttendance,
            presentCount: _presentCount,
            absentCount: _absentCount,
            isBusy: _isLoadingAttendance || _isSavingAttendance,
            errorMessage: _attendanceError,
            onRetry: _loadAttendance,
          ),
          ClassEvaluationTab(
            classId: int.tryParse(widget.classroom.id) ?? 0,
            selectedDate: _selectedDate,
            onPickDate: _pickDate,
            token: context.read<AuthSession>().token ?? '',
            teacherCin: context.read<AuthSession>().cin ?? 0,
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: _saveAttendance,
              backgroundColor: TeacherTheme.tealAccent,
              foregroundColor: TeacherTheme.baseDark,
              icon: const Icon(Icons.save),
              label: const Text(
                'Enregistrer',
                style: TextStyle(
                  fontFamily: TeacherTheme.fontName,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null, // Évaluation tab has its own inline save button
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

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
        if (message != null && message.isNotEmpty) {
          return '$childName: $message';
        }
      } catch (_) {}
    }
    return '$childName: erreur lors de l\'enregistrement.';
  }
}
