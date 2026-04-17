import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newv/utils/api_constants.dart';

class ApiActivity {
  final int id;
  final int planDayId;
  final String title;
  final String description;
  final DateTime date;
  final String? startTime;
  final String? endTime;
  final String status; // en_cours | approved | rejected | executed | not_executed
  final String? teacherName;

  const ApiActivity({
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

  factory ApiActivity.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['date']?.toString() ?? '');
    } catch (_) {
      parsedDate = DateTime(2000);
    }
    return ApiActivity(
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

  ApiActivity copyWith({String? status}) {
    return ApiActivity(
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

  static String _normalizeActivityStatus(String? rawStatus) {
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
}

class ActivitiesApi {
  static const String _apiBaseUrl = ApiConstants.baseUrl;

  static Map<String, String> _getHeaders(String token) => {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  static Future<Map<String, dynamic>> fetchClasses(String cin, String token) async {
    final uri = Uri.parse('$_apiBaseUrl/api/teachers/$cin/classes/by-planning');
    final res = await http.get(uri, headers: _getHeaders(token));
    
    if (res.body.isEmpty) return {'error': 'Response was empty', 'statusCode': res.statusCode};
    final body = jsonDecode(res.body);
    return {...body, 'statusCode': res.statusCode};
  }

  static Future<Map<String, dynamic>> fetchActivities({
    required String cin,
    required String token,
    required int classId,
    String? planningLabel,
  }) async {
    Uri uri = Uri.parse('$_apiBaseUrl/api/teachers/$cin/classes/$classId/activities');
    if (planningLabel != null && planningLabel.isNotEmpty) {
      uri = uri.replace(queryParameters: {'planning_label': planningLabel});
    }

    final res = await http.get(uri, headers: _getHeaders(token));
    if (res.body.isEmpty) return {'error': 'Response was empty', 'statusCode': res.statusCode};
    final body = jsonDecode(res.body);
    return {...body, 'statusCode': res.statusCode};
  }

  static Future<Map<String, dynamic>> updateActivityStatus({
    required String cin,
    required String token,
    required int classId,
    required int activityId,
    required int planDayId,
    required String status,
    required String planningLabel,
  }) async {
    final uri = Uri.parse(
      '$_apiBaseUrl/api/teachers/$cin/classes/$classId/activities/$activityId/status',
    );

    final res = await http.patch(
      uri,
      headers: {
        ..._getHeaders(token),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'plan_day_id': planDayId,
        'status': status,
        'planning_label': planningLabel,
      }),
    );

    if (res.body.isEmpty) return {'error': 'Response was empty', 'statusCode': res.statusCode};
    final body = jsonDecode(res.body);
    return {...body, 'statusCode': res.statusCode};
  }
}
