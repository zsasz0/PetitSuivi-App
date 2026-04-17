import 'package:flutter/material.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/models/teacher_models.dart';
import 'package:newv/utils/unauthorized_handler.dart';
import 'package:newv/views/teacher/activities/apis/activities_api.dart';
import 'package:provider/provider.dart';

class ActivitiesCalendarController extends ChangeNotifier {
  // --- State Variables ---
  bool loadingClasses = true;
  String? classesError;
  List<ClassRoom> classes = [];
  ClassRoom? selectedClass;

  String? fetchedPlanningLabel;
  DateTime? planningStartDate;
  DateTime? planningEndDate;
  bool planningIsArchived = false;

  bool loadingActivities = false;
  String? activitiesError;
  List<ApiActivity> activities = [];

  int visibleYear = DateTime.now().month >= 9
      ? DateTime.now().year
      : DateTime.now().year - 1;
  int? expandedMonth;
  DateTime? selectedDay;

  final Map<String, String> localStatus = {};
  final Set<String> statusUpdatesInFlight = {};

  // --- Getters ---
  String currentPlanningLabel() {
    final now = DateTime.now();
    final start = now.month >= 9 ? now.year : now.year - 1;
    return '$start/${start + 1}';
  }

  List<int> get availableYears {
    if (planningStartDate != null && planningEndDate != null) {
      if (planningStartDate!.year == planningEndDate!.year) {
        return [planningStartDate!.year, planningStartDate!.year];
      }
      return [planningStartDate!.year, planningEndDate!.year];
    }

    final label = fetchedPlanningLabel ?? currentPlanningLabel();
    final parts = label.split('/');
    if (parts.length == 2) {
      final y1 = int.tryParse(parts[0]);
      final y2 = int.tryParse(parts[1]);
      if (y1 != null && y2 != null) return [y1, y2];
    }

    final singleYear = int.tryParse(label);
    if (singleYear != null) return [singleYear, singleYear];

    return [DateTime.now().year];
  }

  bool isPlanningMonth(int year, int month) {
    if (planningStartDate != null && planningEndDate != null) {
      final targetDate = DateTime(year, month, 15);
      final startBoundary = DateTime(planningStartDate!.year, planningStartDate!.month, 1);
      final endBoundary = DateTime(planningEndDate!.year, planningEndDate!.month, 28);

      return targetDate.isAfter(startBoundary.subtract(const Duration(days: 1))) &&
          targetDate.isBefore(endBoundary.add(const Duration(days: 1)));
    }

    if (availableYears.length < 2) return true;
    final startYear = availableYears.first;
    final endYear = availableYears.last;

    if (startYear == endYear) return year == startYear;
    if (year == startYear) return month >= 9 && month <= 12;
    if (year == endYear) return month >= 1 && month <= 5;
    return false;
  }

  List<ApiActivity> get todayActivities {
    final now = DateTime.now();
    final today = activities.where(
      (a) => a.date.year == now.year && a.date.month == now.month && a.date.day == now.day,
    );
    return today.toList()..sort((a, b) => (a.startTime ?? '').compareTo(b.startTime ?? ''));
  }

  bool get canGoPrev => visibleYear > availableYears.first;
  bool get canGoNext => visibleYear < availableYears.last;

  Map<String, List<ApiActivity>> get activityByDay {
    final map = <String, List<ApiActivity>>{};
    for (final a in activities) {
      final key = '${a.date.year}-${a.date.month.toString().padLeft(2, '0')}-${a.date.day.toString().padLeft(2, '0')}';
      (map[key] ??= []).add(a);
    }
    return map;
  }

  String dayKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  List<ApiActivity> activitiesForDay(DateTime d) => activityByDay[dayKey(d)] ?? [];

  int activityCountForMonth(int year, int month) {
    final prefix = '$year-${month.toString().padLeft(2, '0')}';
    return activityByDay.entries
        .where((e) => e.key.startsWith(prefix))
        .fold(0, (sum, e) => sum + e.value.length);
  }

  String activityStatusKey(ApiActivity activity) => '${activity.planDayId}_${activity.id}';

  String effectiveStatus(ApiActivity a) => localStatus[activityStatusKey(a)] ?? a.status;

  bool isStatusUpdateInFlight(ApiActivity a) => statusUpdatesInFlight.contains(activityStatusKey(a));

  // --- Actions ---

  Future<void> loadClasses(BuildContext context) async {
    final session = context.read<AuthSession>();
    if (session.token == null || session.cin == null) {
      loadingClasses = false;
      classesError = 'Session introuvable. Reconnectez-vous.';
      notifyListeners();
      return;
    }

    loadingClasses = true;
    classesError = null;
    notifyListeners();

    try {
      final result = await ActivitiesApi.fetchClasses(session.cin!.toString(), session.token!);
      
      if (!context.mounted) return;
      if (UnauthorizedHandler.handle(context: context, statusCode: result['statusCode'])) return;

      if (result['statusCode'] >= 200 && result['statusCode'] < 300 && result['data'] is List) {
        classes = (result['data'] as List)
            .whereType<Map>()
            .map((e) => _mapClassroom(e.cast<String, dynamic>()))
            .toList();
        fetchedPlanningLabel = result['planning_label']?.toString();
        planningIsArchived = result['planning_is_archived'] == true;

        final pStartStr = result['planning_start']?.toString();
        final pEndStr = result['planning_end']?.toString();
        if (pStartStr != null && pEndStr != null) {
          planningStartDate = DateTime.tryParse(pStartStr);
          planningEndDate = DateTime.tryParse(pEndStr);
        }
        loadingClasses = false;
        notifyListeners();
        
        if (classes.isNotEmpty) selectClass(context, classes.first);
      } else {
        loadingClasses = false;
        classesError = result['message']?.toString() ?? 'Impossible de charger les classes.';
        notifyListeners();
      }
    } catch (_) {
      loadingClasses = false;
      classesError = 'Erreur réseau.';
      notifyListeners();
    }
  }

  void selectClass(BuildContext context, ClassRoom cls) {
    selectedClass = cls;
    notifyListeners();
    loadActivities(context, cls);
  }

  Future<void> loadActivities(BuildContext context, ClassRoom cls) async {
    final session = context.read<AuthSession>();
    final classId = int.tryParse(cls.id);
    if (session.token == null || session.cin == null || classId == null) return;

    loadingActivities = true;
    activitiesError = null;
    activities = [];
    localStatus.clear();
    statusUpdatesInFlight.clear();
    selectedDay = null;
    expandedMonth = null;
    notifyListeners();

    try {
      final result = await ActivitiesApi.fetchActivities(
        cin: session.cin!.toString(),
        token: session.token!,
        classId: classId,
        planningLabel: fetchedPlanningLabel,
      );

      if (!context.mounted) return;
      if (UnauthorizedHandler.handle(context: context, statusCode: result['statusCode'])) return;

      if (result['statusCode'] >= 200 && result['statusCode'] < 300 && result['data'] is List) {
        activities = (result['data'] as List)
            .whereType<Map>()
            .map((e) => ApiActivity.fromJson(e.cast<String, dynamic>()))
            .toList()
          ..sort((a, b) {
            final dc = a.date.compareTo(b.date);
            return dc != 0 ? dc : (a.startTime ?? '').compareTo(b.startTime ?? '');
          });
        loadingActivities = false;
        notifyListeners();
      } else {
        loadingActivities = false;
        activitiesError = result['message']?.toString() ?? 'Impossible de charger les activités.';
        notifyListeners();
      }
    } catch (_) {
      loadingActivities = false;
      activitiesError = 'Erreur réseau.';
      notifyListeners();
    }
  }

  Future<void> updateStatus({
    required BuildContext context,
    required ApiActivity activity,
    required String status,
  }) async {
    final session = context.read<AuthSession>();
    final classId = int.tryParse(selectedClass?.id ?? '');
    if (session.token == null || session.cin == null || classId == null) return;

    final key = activityStatusKey(activity);
    statusUpdatesInFlight.add(key);
    notifyListeners();

    try {
      final result = await ActivitiesApi.updateActivityStatus(
        cin: session.cin!.toString(),
        token: session.token!,
        classId: classId,
        activityId: activity.id,
        planDayId: activity.planDayId,
        status: status,
        planningLabel: fetchedPlanningLabel ?? currentPlanningLabel(),
      );

      if (!context.mounted) return;
      if (UnauthorizedHandler.handle(context: context, statusCode: result['statusCode'])) return;

      if (result['statusCode'] >= 200 && result['statusCode'] < 300) {
        localStatus[key] = status;
        activities = activities.map((a) {
          if (a.id == activity.id && a.planDayId == activity.planDayId) {
            return a.copyWith(status: status);
          }
          return a;
        }).toList();
      } else {
        final errorText = _extractApiErrorMessage(result, 'Impossible de mettre à jour le statut.');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorText)));
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur réseau lors de la mise à jour du statut.')),
      );
    } finally {
      statusUpdatesInFlight.remove(key);
      notifyListeners();
    }
  }

  void updateVisibleYear(int year) {
    visibleYear = year;
    notifyListeners();
  }

  void updateExpandedMonth(int? month) {
    expandedMonth = month;
    notifyListeners();
  }

  void updateSelectedDay(DateTime? day) {
    selectedDay = day;
    notifyListeners();
  }

  ClassRoom _mapClassroom(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    return ClassRoom(
      id: id,
      name: json['name']?.toString() ?? 'Classe',
      children: [],
    );
  }

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
}
