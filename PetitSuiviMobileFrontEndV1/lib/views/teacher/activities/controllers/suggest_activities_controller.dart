import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/utils/api_constants.dart';
import 'package:newv/utils/unauthorized_handler.dart';
import 'package:provider/provider.dart';

class TeacherClassOption {
  final int id;
  final String name;
  const TeacherClassOption({required this.id, required this.name});
}

class TeacherSuggestionItem {
  final String id;
  final String name;
  final String description;
  final String day;
  final String dateLabel;
  final String time;
  final String classLabel;
  final String status;

  const TeacherSuggestionItem({
    required this.id,
    required this.name,
    required this.description,
    required this.day,
    required this.dateLabel,
    required this.time,
    required this.classLabel,
    required this.status,
  });
}

class SuggestActivitiesController extends ChangeNotifier {
  static const String _apiBaseUrl = ApiConstants.baseUrl;

  bool isLoadingSuggestions = true;
  bool isSubmittingSuggestion = false;
  String? suggestionsError;
  String? lastSubmitSuggestionError;
  List<TeacherClassOption> teacherClasses = [];
  List<TeacherSuggestionItem> teacherSuggestions = [];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  String get _normalizedApiBaseUrl => _apiBaseUrl.endsWith('/')
      ? _apiBaseUrl.substring(0, _apiBaseUrl.length - 1)
      : _apiBaseUrl;

  Map<String, String> _authHeaders(String token, {bool withJson = false}) {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
    if (withJson) headers['Content-Type'] = 'application/json';
    return headers;
  }

  Future<void> loadData(BuildContext context, {bool showLoader = true}) async {
    final session = context.read<AuthSession>();
    final token = session.token;
    final teacherCin = session.cin;

    if (token == null || token.isEmpty || teacherCin == null) {
      isLoadingSuggestions = false;
      suggestionsError = 'Session enseignant introuvable. Reconnectez-vous.';
      notifyListeners();
      return;
    }

    if (showLoader) {
      isLoadingSuggestions = true;
      suggestionsError = null;
      notifyListeners();
    }

    final classesUri = Uri.parse('$_normalizedApiBaseUrl/api/teachers/$teacherCin/classes');
    final suggestionsUri = Uri.parse('$_normalizedApiBaseUrl/api/teacher/activities/suggestions');

    try {
      final responses = await Future.wait([
        http.get(classesUri, headers: _authHeaders(token)),
        http.get(suggestionsUri, headers: _authHeaders(token)),
      ]);

      if (!context.mounted) return;

      final classesResponse = responses[0];
      final suggestionsResponse = responses[1];

      if (UnauthorizedHandler.handle(context: context, statusCode: classesResponse.statusCode)) return;
      if (UnauthorizedHandler.handle(context: context, statusCode: suggestionsResponse.statusCode)) return;

      final classesPayload = classesResponse.body.isNotEmpty ? jsonDecode(classesResponse.body) : <String, dynamic>{};
      final suggestionsPayload = suggestionsResponse.body.isNotEmpty ? jsonDecode(suggestionsResponse.body) : <String, dynamic>{};

      final classesData = classesPayload is Map<String, dynamic> ? classesPayload['data'] : null;
      final suggestionsData = suggestionsPayload is Map<String, dynamic> ? suggestionsPayload['data'] : null;

      teacherClasses = _parseTeacherClasses(classesData);
      teacherSuggestions = _parseTeacherSuggestions(suggestionsData);
      
      String? errorMessage;
      if (classesResponse.statusCode < 200 || classesResponse.statusCode >= 300) {
        errorMessage = classesPayload is Map<String, dynamic> ? classesPayload['message']?.toString() : null;
      } else if (suggestionsResponse.statusCode < 200 || suggestionsResponse.statusCode >= 300) {
        errorMessage = suggestionsPayload is Map<String, dynamic> ? suggestionsPayload['message']?.toString() : null;
      }

      isLoadingSuggestions = false;
      suggestionsError = errorMessage;
      notifyListeners();
    } catch (_) {
      isLoadingSuggestions = false;
      suggestionsError = 'Erreur réseau. Vérifiez la connexion à l\'API.';
      notifyListeners();
    }
  }

  Future<bool> submitSuggestion({
    required BuildContext context,
    required int classId,
    required DateTime selectedDate,
    required String startTime,
    required String endTime,
  }) async {
    final session = context.read<AuthSession>();
    final token = session.token;
    if (token == null || token.isEmpty) {
      lastSubmitSuggestionError = 'Session expirée. Reconnectez-vous.';
      notifyListeners();
      return false;
    }

    final title = nameController.text.trim();
    if (title.isEmpty) {
      lastSubmitSuggestionError = 'Le nom de l\'activité est obligatoire.';
      notifyListeners();
      return false;
    }

    final payload = <String, dynamic>{
      'title': title,
      'description': descController.text.trim(),
      'date': DateFormat('yyyy-MM-dd').format(selectedDate),
      'start_time': startTime,
      'end_time': endTime,
      'class_ids': [classId],
    };

    isSubmittingSuggestion = true;
    lastSubmitSuggestionError = null;
    notifyListeners();

    try {
      final uri = Uri.parse('$_normalizedApiBaseUrl/api/teacher/activities/suggestions');
      final response = await http.post(
        uri,
        headers: _authHeaders(token, withJson: true),
        body: jsonEncode(payload),
      );

      if (!context.mounted) return false;
      if (UnauthorizedHandler.handle(context: context, statusCode: response.statusCode)) return false;

      final decodedBody = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      final body = decodedBody is Map<String, dynamic> ? decodedBody : <String, dynamic>{};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await loadData(context, showLoader: false);
        return true;
      }

      lastSubmitSuggestionError = _extractApiErrorMessage(body, 'Impossible de proposer l\'activité.');
      notifyListeners();
      return false;
    } catch (_) {
      lastSubmitSuggestionError = 'Erreur réseau. Vérifiez la connexion à l\'API.';
      notifyListeners();
      return false;
    } finally {
      isSubmittingSuggestion = false;
      notifyListeners();
    }
  }

  List<TeacherClassOption> _parseTeacherClasses(dynamic rawData) {
    if (rawData is! List) return [];
    return rawData
        .whereType<Map>()
        .map((row) => row.cast<String, dynamic>())
        .map((row) {
          final id = int.tryParse(row['id']?.toString() ?? '');
          if (id == null) return null;
          return TeacherClassOption(
            id: id,
            name: (row['name']?.toString() ?? '').trim().isEmpty ? 'Classe #$id' : row['name'].toString(),
          );
        })
        .whereType<TeacherClassOption>()
        .toList();
  }

  List<TeacherSuggestionItem> _parseTeacherSuggestions(dynamic rawData) {
    if (rawData is! List) return [];
    return rawData
        .whereType<Map>()
        .map((row) => row.cast<String, dynamic>())
        .map(_mapSuggestionFromApi)
        .toList();
  }

  TeacherSuggestionItem _mapSuggestionFromApi(Map<String, dynamic> row) {
    final classesRaw = row['classes'];
    final classNames = classesRaw is List
        ? classesRaw
              .whereType<Map>()
              .map((entry) => entry['name']?.toString() ?? '')
              .where((name) => name.trim().isNotEmpty)
              .toList()
        : <String>[];

    final dateValue = row['date']?.toString() ?? '';
    final startTimeValue = row['start_time']?.toString() ?? '';
    final endTimeValue = row['end_time']?.toString() ?? '';

    return TeacherSuggestionItem(
      id: row['id']?.toString() ?? '',
      name: (row['title']?.toString() ?? '').trim().isEmpty ? 'Activité' : row['title'].toString(),
      description: row['description']?.toString() ?? '',
      day: _formatDayFromIsoDate(dateValue),
      dateLabel: _formatDateFromIsoDate(dateValue),
      time: _formatTimeRangeForDisplay(startTimeValue, endTimeValue),
      classLabel: classNames.isEmpty ? 'Toutes les classes' : classNames.join(', '),
      status: _normalizeActivityStatus(row['status']?.toString()),
    );
  }

  String _formatDayFromIsoDate(String value) {
    if (value.trim().isEmpty) return '-';
    try {
      final parsed = DateTime.parse(value);
      final day = DateFormat('EEEE', 'fr').format(parsed);
      return day[0].toUpperCase() + day.substring(1);
    } catch (_) { return value; }
  }

  String _formatDateFromIsoDate(String value) {
    if (value.trim().isEmpty) return '-';
    try {
      final parsed = DateTime.parse(value);
      return DateFormat('dd/MM/yyyy').format(parsed);
    } catch (_) { return value; }
  }

  String _formatTimeRangeForDisplay(String startValue, String endValue) {
    String formatTime(String v) {
      final match = RegExp(r'^(\d{2}):(\d{2})').firstMatch(v);
      if (match == null) return v.isEmpty ? '-' : v;
      return '${match.group(1)}h${match.group(2)}';
    }
    final startLabel = formatTime(startValue);
    final endLabel = formatTime(endValue);
    if (startLabel != '-' && endLabel != '-') return '$startLabel — $endLabel';
    if (startLabel != '-') return startLabel;
    if (endLabel != '-') return endLabel;
    return '-';
  }

  String _normalizeActivityStatus(String? rawStatus) {
    final normalized = (rawStatus ?? '').trim().toLowerCase();
    switch (normalized) {
      case 'approved': case 'rejected': case 'executed': case 'not_executed': return normalized;
      case 'pending': case 'en cours': case 'encours': case 'en_cours': case 'in progress': case 'in_progress': return 'en_cours';
      default: return 'en_cours';
    }
  }

  String _extractApiErrorMessage(Map<String, dynamic> body, String fallback) {
    final topMessage = body['message']?.toString().trim();
    final errorsRaw = body['errors'];
    if (errorsRaw is Map) {
      for (final entry in errorsRaw.entries) {
        final value = entry.value;
        if (value is List && value.isNotEmpty) {
          final first = value.first?.toString().trim() ?? '';
          if (first.isNotEmpty) return first;
        }
        final single = value?.toString().trim() ?? '';
        if (single.isNotEmpty) return single;
      }
    }
    if (topMessage != null && topMessage.isNotEmpty) return topMessage;
    return fallback;
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    super.dispose();
  }
}
