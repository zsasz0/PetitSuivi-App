/// activities_calendar_page.dart
///
/// A comprehensive calendar and list view for managing classroom activities
/// within the current academic year (planning). Teachers can browse months,
/// select days, and mark activities as executed or not executed.
///
/// ## State Management
/// - [_ActivitiesCalendarPageState] holds classes, activities, calendar
///   navigation, and local execution-status overrides.
/// - Uses [AuthSession] via Provider for authentication tokens and teacher CIN.
/// - Listens to [ThemeManager] for light/dark mode reactivity.
///
/// ## Backend API Endpoints
///
/// ### GET /api/teachers/{cin}/classes/by-planning
/// Fetches the list of classes assigned to the authenticated teacher for the
/// current planning period.
/// - **Headers:** `Authorization: Bearer {token}`
/// - **Response 200:**
/// ```json
/// {
///   "data": [
///     { "id": 1, "name": "Moyenne Section B" }
///   ],
///   "planning_label": "2025/2026",
///   "planning_start": "2025-09-01",
///   "planning_end": "2026-06-30",
///   "planning_is_archived": false
/// }
/// ```
///
/// ### GET /api/teachers/{cin}/classes/{classId}/activities
/// Fetches all scheduled activities for a specific class, optionally filtered
/// by planning label via query parameter `?planning_label=2025/2026`.
/// - **Headers:** `Authorization: Bearer {token}`
/// - **Response 200:**
/// ```json
/// {
///   "data": [
///     {
///       "id": 10, "plan_day_id": 5, "title": "Atelier peinture",
///       "description": "...", "date": "2026-03-05",
///       "start_time": "09:00", "end_time": "10:00",
///       "status": "en_cours", "teacher_name": "Fatma Mrad"
///     }
///   ]
/// }
/// ```
///
/// ### PATCH /api/teachers/{cin}/classes/{classId}/activities/{activityId}/status
/// Updates the execution status of a specific activity (executed / not_executed).
/// - **Headers:** `Authorization: Bearer {token}`, `Content-Type: application/json`
/// - **Body:**
/// ```json
/// {
///   "plan_day_id": 5,
///   "status": "executed",
///   "planning_label": "2025/2026"
/// }
/// ```
/// - **Response 200:** `{ "message": "Status updated." }`
///
/// ## Dependencies
/// [AuthSession], [TeacherTheme], [ApiConstants], [UnauthorizedHandler], [ClassRoom].
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/models/teacher_models.dart';
import 'package:newv/theme_colors.dart';
import 'package:newv/theme_manager.dart';
import 'package:newv/utils/api_constants.dart';
import 'package:newv/utils/unauthorized_handler.dart';
import 'package:newv/views/teacher/teacher_theme.dart';
import 'package:provider/provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

String _currentPlanningLabel() {
  final now = DateTime.now();
  final start = now.month >= 9 ? now.year : now.year - 1;
  return '$start/${start + 1}';
}

String _normalizeActivityStatus(String? rawStatus) {
  final normalized = (rawStatus ?? '').trim().toLowerCase();
  switch (normalized) {
    case 'approved':
    case 'rejected':
    case 'executed':
    case 'not_executed':
      return normalized;
    case 'pending':
    case 'en cours':
    case 'encours':
    case 'en_cours':
    case 'in progress':
    case 'in_progress':
      return 'en_cours';
    default:
      return 'en_cours';
  }
}

const List<String> _monthsFr = [
  'Janvier',
  'Février',
  'Mars',
  'Avril',
  'Mai',
  'Juin',
  'Juillet',
  'Août',
  'Septembre',
  'Octobre',
  'Novembre',
  'Décembre',
];

const List<String> _weekdaysFr = [
  'Lun',
  'Mar',
  'Mer',
  'Jeu',
  'Ven',
  'Sam',
  'Dim',
];

const List<IconData> _monthIcons = [
  Icons.ac_unit,
  Icons.favorite,
  Icons.eco,
  Icons.local_florist,
  Icons.wb_sunny,
  Icons.beach_access,
  Icons.wb_sunny,
  Icons.park,
  Icons.school,
  Icons.park,
  Icons.cloud,
  Icons.star,
];

// Theme-aware colors - use TeacherTheme getters for light/dark mode
Color get _primaryBlue => TeacherTheme.tealAccent;
Color get _softBlue => TeacherTheme.surfaceDark;
Color get _mutedBlue => ThemeManager.instance.isLightMode
    ? const Color(0xFFE0E4EB)
    : const Color(0xFF2B364E);

// ─────────────────────────────────────────────────────────────────────────────
// Activity model
// ─────────────────────────────────────────────────────────────────────────────

class _ApiActivity {
  final int id;
  final int planDayId;
  final String title;
  final String description;
  final DateTime date;
  final String? startTime;
  final String? endTime;
  final String
  status; // en_cours | approved | rejected | executed | not_executed
  final String? teacherName;

  const _ApiActivity({
    required this.id,
    required this.planDayId,
    required this.title,
    required this.description,
    required this.date,
    this.startTime,
    this.endTime,
    required this.status,
    this.teacherName,
  });

  factory _ApiActivity.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['date']?.toString() ?? '');
    } catch (_) {
      parsedDate = DateTime(2000);
    }
    return _ApiActivity(
      id: (json['id'] as num?)?.toInt() ?? 0,
      planDayId: (json['plan_day_id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      date: parsedDate,
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      status: _normalizeActivityStatus(json['status']?.toString()),
      teacherName: json['teacher_name']?.toString(),
    );
  }

  _ApiActivity copyWith({String? status}) {
    return _ApiActivity(
      id: id,
      planDayId: planDayId,
      title: title,
      description: description,
      date: date,
      startTime: startTime,
      endTime: endTime,
      status: status ?? this.status,
      teacherName: teacherName,
    );
  }

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String get timeLabel {
    if (startTime == null) return '';
    if (endTime == null) return startTime!;
    return '$startTime → $endTime';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────────

class ActivitiesCalendarPage extends StatefulWidget {
  const ActivitiesCalendarPage({super.key});

  @override
  State<ActivitiesCalendarPage> createState() => _ActivitiesCalendarPageState();
}

class _ActivitiesCalendarPageState extends State<ActivitiesCalendarPage> {
  static const String _apiBaseUrl = ApiConstants.baseUrl;

  // ── Classes ───────────────────────────────────────────────────────────────
  bool _loadingClasses = true;
  String? _classesError;
  List<ClassRoom> _classes = [];
  ClassRoom? _selectedClass;
  String? _fetchedPlanningLabel;
  DateTime? _planningStartDate;
  DateTime? _planningEndDate;
  bool _planningIsArchived = false;

  // ── Activities ────────────────────────────────────────────────────────────
  bool _loadingActivities = false;
  String? _activitiesError;
  List<_ApiActivity> _activities = [];

  // ── Calendar navigation ───────────────────────────────────────────────────
  int _visibleYear = DateTime.now().month >= 9
      ? DateTime.now().year
      : DateTime.now().year - 1;
  int? _expandedMonth; // 1-12
  DateTime? _selectedDay;

  // ── Local execution-status overrides ─────────────────────────────────────
  final Map<String, String> _localStatus = {};
  final Set<String> _statusUpdatesInFlight = <String>{};

  final DateFormat _longDate = DateFormat('EEEE d MMMM yyyy', 'fr');

  // ── School year years (the two years of the planning label) ───────────────
  List<int> get _availableYears {
    if (_planningStartDate != null && _planningEndDate != null) {
      if (_planningStartDate!.year == _planningEndDate!.year) {
        return [_planningStartDate!.year, _planningStartDate!.year];
      }
      return [_planningStartDate!.year, _planningEndDate!.year];
    }

    final label = _fetchedPlanningLabel ?? _currentPlanningLabel(); // fallback
    final parts = label.split('/');
    if (parts.length == 2) {
      final y1 = int.tryParse(parts[0]);
      final y2 = int.tryParse(parts[1]);
      if (y1 != null && y2 != null) return [y1, y2];
    }

    // Fallback for single-year plannings like "2026"
    final singleYear = int.tryParse(label);
    if (singleYear != null) return [singleYear, singleYear];

    return [DateTime.now().year];
  }

  bool _isPlanningMonth(int year, int month) {
    if (_planningStartDate != null && _planningEndDate != null) {
      final targetDate = DateTime(year, month, 15);
      final startBoundary = DateTime(
        _planningStartDate!.year,
        _planningStartDate!.month,
        1,
      );
      final endBoundary = DateTime(
        _planningEndDate!.year,
        _planningEndDate!.month,
        28,
      );

      return targetDate.isAfter(
            startBoundary.subtract(const Duration(days: 1)),
          ) &&
          targetDate.isBefore(endBoundary.add(const Duration(days: 1)));
    }

    if (_availableYears.length < 2) return true;
    final startYear = _availableYears.first;
    final endYear = _availableYears.last;

    if (startYear == endYear) {
      return year == startYear;
    }

    if (year == startYear) {
      return month >= 9 && month <= 12;
    }
    if (year == endYear) {
      return month >= 1 && month <= 5;
    }
    return false;
  }

  List<_ApiActivity> get _todayActivities {
    final now = DateTime.now();
    final today = _activities.where(
      (a) =>
          a.date.year == now.year &&
          a.date.month == now.month &&
          a.date.day == now.day,
    );
    return today.toList()
      ..sort((a, b) => (a.startTime ?? '').compareTo(b.startTime ?? ''));
  }

  bool get _canGoPrev => _visibleYear > _availableYears.first;
  bool get _canGoNext => _visibleYear < _availableYears.last;

  // ── Activity maps ─────────────────────────────────────────────────────────

  // Count of activities per "day key" (yyyy-mm-dd)
  Map<String, List<_ApiActivity>> get _activityByDay {
    final map = <String, List<_ApiActivity>>{};
    for (final a in _activities) {
      final key =
          '${a.date.year}-${a.date.month.toString().padLeft(2, '0')}-${a.date.day.toString().padLeft(2, '0')}';
      (map[key] ??= []).add(a);
    }
    return map;
  }

  String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  List<_ApiActivity> activitiesForDay(DateTime d) =>
      _activityByDay[_dayKey(d)] ?? [];

  int activityCountForMonth(int year, int month) {
    final prefix = '$year-${month.toString().padLeft(2, '0')}';
    return _activityByDay.entries
        .where((e) => e.key.startsWith(prefix))
        .fold(0, (sum, e) => sum + e.value.length);
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadClasses());
  }

  // ── API calls ─────────────────────────────────────────────────────────────

  Map<String, String> get _authHeaders {
    final token = context.read<AuthSession>().token ?? '';
    return {'Accept': 'application/json', 'Authorization': 'Bearer $token'};
  }

  Future<void> _loadClasses() async {
    final session = context.read<AuthSession>();
    if (session.token == null || session.cin == null) {
      setState(() {
        _loadingClasses = false;
        _classesError = 'Session introuvable. Reconnectez-vous.';
      });
      return;
    }

    setState(() {
      _loadingClasses = true;
      _classesError = null;
    });

    final uri = Uri.parse(
      '$_apiBaseUrl/api/teachers/${session.cin}/classes/by-planning',
    );

    try {
      final res = await http.get(uri, headers: _authHeaders);
      if (!mounted) return;
      if (UnauthorizedHandler.handle(
        context: context,
        statusCode: res.statusCode,
      )) {
        return;
      }

      final body = res.body.isNotEmpty
          ? jsonDecode(res.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (res.statusCode >= 200 &&
          res.statusCode < 300 &&
          body['data'] is List) {
        final classes = (body['data'] as List)
            .whereType<Map>()
            .map((e) => _mapClassroom(e.cast<String, dynamic>()))
            .toList();
        setState(() {
          _loadingClasses = false;
          _classes = classes;
          _fetchedPlanningLabel = body['planning_label']?.toString();
          _planningIsArchived = body['planning_is_archived'] == true;

          final pStartStr = body['planning_start']?.toString();
          final pEndStr = body['planning_end']?.toString();
          if (pStartStr != null && pEndStr != null) {
            _planningStartDate = DateTime.tryParse(pStartStr);
            _planningEndDate = DateTime.tryParse(pEndStr);
          }
        });
        if (classes.isNotEmpty) _selectClass(classes.first);
      } else {
        setState(() {
          _loadingClasses = false;
          _classesError =
              body['message']?.toString() ??
              'Impossible de charger les classes.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingClasses = false;
          _classesError = 'Erreur réseau.';
        });
      }
    }
  }

  Future<void> _loadActivities(ClassRoom cls) async {
    final session = context.read<AuthSession>();
    final classId = int.tryParse(cls.id);
    if (session.token == null || session.cin == null || classId == null) {
      return;
    }

    setState(() {
      _loadingActivities = true;
      _activitiesError = null;
      _activities = [];
      _localStatus.clear();
      _statusUpdatesInFlight.clear();
      _selectedDay = null;
      _expandedMonth = null;
    });

    Uri uri = Uri.parse(
      '$_apiBaseUrl/api/teachers/${session.cin}/classes/$classId/activities',
    );
    if (_fetchedPlanningLabel != null && _fetchedPlanningLabel!.isNotEmpty) {
      uri = uri.replace(
        queryParameters: {'planning_label': _fetchedPlanningLabel},
      );
    }

    try {
      final res = await http.get(uri, headers: _authHeaders);
      if (!mounted) return;
      if (UnauthorizedHandler.handle(
        context: context,
        statusCode: res.statusCode,
      )) {
        return;
      }

      final body = res.body.isNotEmpty
          ? jsonDecode(res.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (res.statusCode >= 200 &&
          res.statusCode < 300 &&
          body['data'] is List) {
        final activities =
            (body['data'] as List)
                .whereType<Map>()
                .map((e) => _ApiActivity.fromJson(e.cast<String, dynamic>()))
                .toList()
              ..sort((a, b) {
                final dc = a.date.compareTo(b.date);
                return dc != 0
                    ? dc
                    : (a.startTime ?? '').compareTo(b.startTime ?? '');
              });
        setState(() {
          _loadingActivities = false;
          _activities = activities;
        });
      } else {
        setState(() {
          _loadingActivities = false;
          _activitiesError =
              body['message']?.toString() ??
              'Impossible de charger les activités.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingActivities = false;
          _activitiesError = 'Erreur réseau.';
        });
      }
    }
  }

  void _selectClass(ClassRoom cls) {
    setState(() => _selectedClass = cls);
    _loadActivities(cls);
  }

  ClassRoom _mapClassroom(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    return ClassRoom(
      id: id,
      name: json['name']?.toString() ?? 'Classe',
      children: [],
    );
  }

  // ── Mark execution ────────────────────────────────────────────────────────

  String _activityStatusKey(_ApiActivity activity) =>
      '${activity.planDayId}_${activity.id}';

  String _extractApiErrorMessage(Map<String, dynamic> body, String fallback) {
    final message = body['message']?.toString().trim();
    final errors = body['errors'];

    if (errors is Map) {
      for (final entry in errors.entries) {
        final value = entry.value;
        if (value is List && value.isNotEmpty) {
          final text = value.first?.toString().trim() ?? '';
          if (text.isNotEmpty) return text;
        }
        final text = value?.toString().trim() ?? '';
        if (text.isNotEmpty) return text;
      }
    }

    if (message != null && message.isNotEmpty) return message;
    return fallback;
  }

  Future<void> _markStatus(_ApiActivity activity, String status) async {
    final label = status == 'executed' ? 'exécutée' : 'non exécutée';
    final color = status == 'executed' ? Colors.green : Colors.red[700]!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmer'),
        content: Text('Marquer « ${activity.title} » comme $label ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;
    final session = context.read<AuthSession>();
    final classId = int.tryParse(_selectedClass?.id ?? '');
    if (session.token == null || session.cin == null || classId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session invalide. Reconnectez-vous.')),
      );
      return;
    }

    final key = _activityStatusKey(activity);
    setState(() {
      _statusUpdatesInFlight.add(key);
    });

    try {
      final uri = Uri.parse(
        '$_apiBaseUrl/api/teachers/${session.cin}/classes/$classId/activities/${activity.id}/status',
      );

      final res = await http.patch(
        uri,
        headers: {..._authHeaders, 'Content-Type': 'application/json'},
        body: jsonEncode({
          'plan_day_id': activity.planDayId,
          'status': status,
          'planning_label': _fetchedPlanningLabel ?? _currentPlanningLabel(),
        }),
      );

      if (!mounted) return;
      if (UnauthorizedHandler.handle(
        context: context,
        statusCode: res.statusCode,
      )) {
        return;
      }

      final decoded = res.body.isNotEmpty ? jsonDecode(res.body) : null;
      final body = decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{};

      if (res.statusCode >= 200 && res.statusCode < 300) {
        setState(() {
          _localStatus[key] = status;
          _activities = _activities.map((a) {
            if (a.id == activity.id && a.planDayId == activity.planDayId) {
              return a.copyWith(status: status);
            }
            return a;
          }).toList();
        });
        return;
      }

      final errorText = _extractApiErrorMessage(
        body,
        'Impossible de mettre à jour le statut.',
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorText)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur réseau lors de la mise à jour du statut.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _statusUpdatesInFlight.remove(key);
        });
      }
    }
  }

  String _effectiveStatus(_ApiActivity a) =>
      _localStatus[_activityStatusKey(a)] ?? a.status;

  bool _isStatusUpdateInFlight(_ApiActivity a) =>
      _statusUpdatesInFlight.contains(_activityStatusKey(a));

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return Scaffold(
      backgroundColor: TeacherTheme.baseDark,
      appBar: AppBar(
        title: Text(
          'Annuaires Activités',
          style: TextStyle(
            color: TeacherTheme.lightText,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? BackButton(color: TeacherTheme.lightText)
            : null,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: TeacherTheme.lightText),
            onPressed: _loadClasses,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: _planningIsArchived
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.archive_outlined,
                      color: const Color(0xFF42A5F5),
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Année scolaire archivée",
                      style: TextStyle(
                        fontFamily: TeacherTheme.fontName,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: TeacherTheme.lightText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "L'année scolaire ${_fetchedPlanningLabel ?? ''} est archivée.\nLes activités ne sont plus consultables.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: TeacherTheme.fontName,
                        fontSize: 14,
                        color: const Color(0xFF90CAF9),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                // ── Class selector ──────────────────────────────────────────────
                _buildClassSelector(),
                // ── Content ─────────────────────────────────────────────────────
                Expanded(child: _buildContent()),
              ],
            ),
    );
  }

  // ── Class selector ────────────────────────────────────────────────────────

  Widget _buildClassSelector() {
    if (_loadingClasses) {
      return const SizedBox(
        height: 56,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (_classesError != null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _classesError!,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: _loadClasses,
              child: Text(
                'Réessayer',
                style: TextStyle(color: TeacherTheme.tealAccent),
              ),
            ),
          ],
        ),
      );
    }
    if (_classes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          'Aucune classe pour ${_currentPlanningLabel()}.',
          style: TextStyle(color: TeacherTheme.mutedText, fontSize: 13),
        ),
      );
    }

    return Container(
      height: 60,
      margin: const EdgeInsets.only(top: 4),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: _classes.length,
        itemBuilder: (_, i) {
          final cls = _classes[i];
          final sel = _selectedClass?.id == cls.id;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                if (!sel) _selectClass(cls);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: sel
                      ? LinearGradient(
                          colors: [TeacherTheme.tealAccent, Color(0xFF6870FA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: sel ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  border: sel
                      ? null
                      : Border.all(
                          color: TeacherTheme.mutedText.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                  boxShadow: sel
                      ? [
                          BoxShadow(
                            color: TeacherTheme.tealAccent.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    cls.name,
                    style: TextStyle(
                      fontWeight: sel ? FontWeight.bold : FontWeight.w500,
                      fontSize: 14,
                      color: sel
                          ? Colors.white
                          : TeacherTheme.lightText.withValues(alpha: 0.8),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Main content ──────────────────────────────────────────────────────────

  Widget _buildContent() {
    if (_loadingActivities) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_activitiesError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red[400], size: 40),
            const SizedBox(height: 12),
            Text(_activitiesError!, style: TextStyle(color: Colors.red[700])),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _selectedClass != null
                  ? () => _loadActivities(_selectedClass!)
                  : null,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    final isSelectedToday =
        _selectedDay != null &&
        _selectedDay!.year == DateTime.now().year &&
        _selectedDay!.month == DateTime.now().month &&
        _selectedDay!.day == DateTime.now().day;

    return CustomScrollView(
      slivers: [
        // ── Year navigator ─────────────────────────────────────────────────
        SliverToBoxAdapter(child: _buildYearNav()),

        // ── Month grid ────────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.1,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, i) => _buildMonthCard(i + 1),
              childCount: 12,
            ),
          ),
        ),

        // ── Expanded month calendar ────────────────────────────────────────
        if (_expandedMonth != null)
          SliverToBoxAdapter(
            child: _buildMonthCalendar(_visibleYear, _expandedMonth!),
          ),

        // ── Day detail panel ──────────────────────────────────────────────
        if (_selectedDay != null)
          SliverToBoxAdapter(child: _buildDayDetail(_selectedDay!)),

        // ── Today quick access ─────────────────────────────────────────────
        if (!isSelectedToday)
          SliverToBoxAdapter(child: _buildTodayQuickAccess()),

        const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
      ],
    );
  }

  // ── Year navigator ────────────────────────────────────────────────────────

  Widget _buildYearNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryBlue, const Color(0xFF4F84FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryBlue.withValues(alpha: 0.28),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ← Prev year
          _yearNavBtn(Icons.chevron_left, _canGoPrev, () {
            setState(() {
              _visibleYear--;
              _expandedMonth = null;
              _selectedDay = null;
            });
          }),
          // Year display
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$_visibleYear',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _planningStartDate != null &&
                          _planningEndDate != null &&
                          _planningStartDate!.year != _planningEndDate!.year
                      ? 'Année scolaire ${_fetchedPlanningLabel ?? _currentPlanningLabel()} (${_planningStartDate!.year}/${_planningEndDate!.year})'
                      : 'Année scolaire ${_fetchedPlanningLabel ?? _currentPlanningLabel()}',
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ),
          // → Next year
          _yearNavBtn(Icons.chevron_right, _canGoNext, () {
            setState(() {
              _visibleYear++;
              _expandedMonth = null;
              _selectedDay = null;
            });
          }),
        ],
      ),
    );
  }

  Widget _yearNavBtn(IconData icon, bool enabled, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            color: enabled ? Colors.white : Colors.white38,
            size: 28,
          ),
        ),
      ),
    );
  }

  // ── Month card ────────────────────────────────────────────────────────────

  Widget _buildMonthCard(int month) {
    final count = activityCountForMonth(_visibleYear, month);
    final isPlanning = _isPlanningMonth(_visibleYear, month);
    final isExpanded = _expandedMonth == month;
    final now = DateTime.now();
    final isCurrent = _visibleYear == now.year && now.month == month;

    Color bg = TeacherTheme.surfaceDark;
    Color textColor = TeacherTheme.lightText;
    Color accentColor = _primaryBlue;

    if (!isPlanning) {
      bg = TeacherTheme.baseDark;
      textColor = _mutedBlue;
      accentColor = _mutedBlue;
    }

    if (isExpanded && isPlanning) {
      bg = _primaryBlue.withValues(alpha: 0.15);
      textColor = TeacherTheme.lightText;
      accentColor = _primaryBlue;
    } else if (isCurrent && isPlanning) {
      bg = TeacherTheme.baseDark;
    }

    return GestureDetector(
      onTap: () {
        if (!isPlanning) return;
        setState(() {
          _expandedMonth = isExpanded ? null : month;
          _selectedDay = null;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: isCurrent && !isExpanded
              ? Border.all(
                  color: _primaryBlue.withValues(alpha: 0.55),
                  width: 1.5,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: ThemeColors.shadow,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_monthIcons[month - 1], color: accentColor, size: 22),
            const SizedBox(height: 3),
            Text(
              _monthsFr[month - 1],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            if (count > 0) ...[
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isExpanded
                      ? ThemeColors.glassBorderStrong
                      : _primaryBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count activité${count > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isExpanded ? Colors.white : _primaryBlue,
                  ),
                ),
              ),
            ],
            if (!isPlanning) ...[
              const SizedBox(height: 4),
              Text(
                'Hors planning',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: _mutedBlue,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Month calendar (day grid) ─────────────────────────────────────────────

  Widget _buildMonthCalendar(int year, int month) {
    final firstDay = DateTime(year, month, 1);
    // Monday-based offset
    int startOffset = firstDay.weekday - 1; // 0=Mon
    final daysInMonth = DateUtils.getDaysInMonth(year, month);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: TeacherTheme.surfaceCard().copyWith(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Icon(_monthIcons[month - 1], color: _primaryBlue, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${_monthsFr[month - 1]} $year',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: TeacherTheme.lightText,
                  ),
                ),
              ],
            ),
          ),
          // Weekday headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: _weekdaysFr
                  .map(
                    (d) => Expanded(
                      child: Text(
                        d,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: TeacherTheme.mutedText,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 6),
          // Day cells
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: startOffset + daysInMonth,
              itemBuilder: (_, idx) {
                if (idx < startOffset) return const SizedBox.shrink();
                final day = idx - startOffset + 1;
                final date = DateTime(year, month, day);
                return _buildDayCell(date);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(DateTime date) {
    final count = activitiesForDay(date).length;
    final isSelected =
        _selectedDay != null &&
        _selectedDay!.year == date.year &&
        _selectedDay!.month == date.month &&
        _selectedDay!.day == date.day;
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;

    Color bg = Colors.transparent;
    Color numColor = TeacherTheme.lightText;
    Color dotColor = _primaryBlue;

    if (isSelected) {
      bg = _primaryBlue.withValues(alpha: 0.2);
      numColor = TeacherTheme.tealAccent;
      dotColor = TeacherTheme.tealAccent;
    } else if (isToday) {
      bg = _primaryBlue.withValues(alpha: 0.1);
      numColor = _primaryBlue;
    }

    return GestureDetector(
      onTap: count > 0 || isToday
          ? () => setState(() => _selectedDay = date)
          : null,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: isToday || isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: count == 0 && !isToday && !isSelected
                    ? Colors.grey[400]
                    : numColor,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(height: 2),
              Container(
                width: 18,
                height: 4,
                decoration: BoxDecoration(
                  color: dotColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Day detail panel ──────────────────────────────────────────────────────

  Widget _buildDayDetail(DateTime day) {
    final activities = activitiesForDay(day);
    final now = DateTime.now();
    final isToday =
        day.year == now.year && day.month == now.month && day.day == now.day;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      decoration: TeacherTheme.surfaceCard(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isToday ? _primaryBlue : _softBlue,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isToday ? Icons.today : Icons.calendar_today,
                  color: isToday ? Colors.white : TeacherTheme.lightText,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _capitalise(_longDate.format(day)),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isToday ? Colors.white : TeacherTheme.lightText,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isToday
                        ? ThemeColors.glassBorderStrong
                        : _primaryBlue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${activities.length} activité${activities.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isToday ? Colors.white : _primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Activity list
          if (activities.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Aucune activité ce jour.',
                style: TextStyle(color: TeacherTheme.mutedText),
              ),
            )
          else
            ...activities.map(_buildActivityRow),
        ],
      ),
    );
  }

  Widget _buildActivityRow(_ApiActivity activity) {
    final effStatus = _effectiveStatus(activity);
    final isSavingStatus = _isStatusUpdateInFlight(activity);
    Color statusColor;
    IconData statusIcon;
    switch (effStatus) {
      case 'executed':
        statusColor = Colors.green;
        statusIcon = Icons.task_alt;
        break;
      case 'not_executed':
        statusColor = Colors.red[700]!;
        statusIcon = Icons.cancel;
        break;
      case 'rejected':
        statusColor = Colors.orange;
        statusIcon = Icons.block;
        break;
      default:
        statusColor = _primaryBlue;
        statusIcon = Icons.event_note;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  activity.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: TeacherTheme.lightText,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          if (activity.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              activity.description,
              style: TextStyle(
                color: TeacherTheme.mutedText,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 6),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (activity.timeLabel.isNotEmpty) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 13,
                      color: TeacherTheme.mutedText,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      activity.timeLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: TeacherTheme.mutedText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusLabel(effStatus),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          // Action buttons — available for any selected day
          ...[
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStatusActionButton(
                  activity: activity,
                  targetStatus: 'executed',
                  label: 'Exécutée',
                  icon: Icons.check_circle_outline,
                  color: Colors.green[700]!,
                  isSelected: effStatus == 'executed',
                  isLoading: isSavingStatus,
                ),
                _buildStatusActionButton(
                  activity: activity,
                  targetStatus: 'not_executed',
                  label: 'Non exécutée',
                  icon: Icons.cancel_outlined,
                  color: Colors.red[700]!,
                  isSelected: effStatus == 'not_executed',
                  isLoading: isSavingStatus,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusActionButton({
    required _ApiActivity activity,
    required String targetStatus,
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required bool isLoading,
  }) {
    return OutlinedButton.icon(
      onPressed: (isSelected || isLoading)
          ? null
          : () => _markStatus(activity, targetStatus),
      icon: isLoading
          ? SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          : Icon(icon, size: 15),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        backgroundColor: isSelected
            ? color.withValues(alpha: 0.12)
            : TeacherTheme.surfaceDark,
        side: BorderSide(
          color: isSelected ? color : color.withValues(alpha: 0.35),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        textStyle: const TextStyle(fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildTodayQuickAccess() {
    final today = DateTime.now();
    final todayActivities = _todayActivities;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      decoration: TeacherTheme.surfaceCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _softBlue,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.today, color: _primaryBlue, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Activités d\'aujourd\'hui (accès rapide)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: TeacherTheme.lightText,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _primaryBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${todayActivities.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Text(
              _capitalise(_longDate.format(today)),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: TeacherTheme.mutedText,
              ),
            ),
          ),
          if (todayActivities.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
              child: Text(
                'Aucune activité prévue aujourd\'hui.',
                style: TextStyle(color: TeacherTheme.mutedText),
              ),
            )
          else
            ...todayActivities.map(_buildActivityRow),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'Approuvée';
      case 'rejected':
        return 'Rejetée';
      case 'executed':
        return 'Exécutée';
      case 'not_executed':
        return 'Non exécutée';
      case 'en_cours':
        return 'En cours';
      default:
        return 'En cours';
    }
  }

  String _capitalise(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
