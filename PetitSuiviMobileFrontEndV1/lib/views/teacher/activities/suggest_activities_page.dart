/// suggest_activities_page.dart
///
/// Allows teachers to submit new activity proposals for administrative approval.
/// Displays a list of historical suggestions with their statuses and provides
/// a floating action button to open a new suggestion dialog.
///
/// ## State Management
/// - [_SuggestActivitiesPageState] holds teacher classes, suggestion list,
///   form controllers, and submission state.
/// - [_TeacherClassOption] / [_TeacherSuggestionItem] are internal models.
///
/// ## Backend API Endpoints
///
/// ### GET /api/teachers/{cin}/classes
/// Fetches the list of classes assigned to the teacher (for the class selector).
/// - **Headers:** `Authorization: Bearer {token}`
/// - **Response 200:** `{ "data": [ { "id": 1, "name": "Moyenne Section B" } ] }`
///
/// ### GET /api/teacher/activities/suggestions
/// Retrieves the teacher's previously submitted activity suggestions.
/// - **Headers:** `Authorization: Bearer {token}`
/// - **Response 200:**
/// ```json
/// {
///   "data": [
///     {
///       "id": "42", "title": "Atelier musique", "description": "...",
///       "date": "2026-04-10", "start_time": "10:00", "end_time": "11:00",
///       "status": "en_cours",
///       "classes": [ { "name": "Moyenne Section B" } ]
///     }
///   ]
/// }
/// ```
///
/// ### POST /api/teacher/activities/suggestions
/// Submits a new activity suggestion for admin review.
/// - **Headers:** `Authorization: Bearer {token}`, `Content-Type: application/json`
/// - **Body:**
/// ```json
/// {
///   "title": "Atelier musique", "description": "...",
///   "date": "2026-04-10", "start_time": "10:00", "end_time": "11:00",
///   "class_ids": [1]
/// }
/// ```
/// - **Response 201:** `{ "message": "Suggestion created." }`
///
/// ## Dependencies
/// [AuthSession], [ApiConstants], [UnauthorizedHandler], [AppTheme], [ThemeManager].
library suggest_activities_page;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:newv/app_theme.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/theme_manager.dart';
import 'package:newv/utils/api_constants.dart';
import 'package:newv/utils/unauthorized_handler.dart';
import 'package:provider/provider.dart';
class SuggestActivitiesPage extends StatefulWidget {
  const SuggestActivitiesPage({super.key});

  @override
  State<SuggestActivitiesPage> createState() => _SuggestActivitiesPageState();
}

class _TeacherClassOption {
  final int id;
  final String name;

  const _TeacherClassOption({required this.id, required this.name});
}

class _TeacherSuggestionItem {
  final String id;
  final String name;
  final String description;
  final String day;
  final String dateLabel;
  final String time;
  final String classLabel;
  final String status;

  const _TeacherSuggestionItem({
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

class _SuggestActivitiesPageState extends State<SuggestActivitiesPage> {
  static const String _apiBaseUrl = ApiConstants.baseUrl;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  DateTime _selectedSuggestionDate = DateTime.now();
  String? _selectedSuggestionClassId;

  bool _isLoadingSuggestions = true;
  bool _isSubmittingSuggestion = false;
  String? _suggestionsError;
  String? _lastSubmitSuggestionError;
  List<_TeacherClassOption> _teacherClasses = [];
  List<_TeacherSuggestionItem> _teacherSuggestions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _loadTeacherSuggestionData(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  String get _normalizedApiBaseUrl => _apiBaseUrl.endsWith('/')
      ? _apiBaseUrl.substring(0, _apiBaseUrl.length - 1)
      : _apiBaseUrl;

  Map<String, String> _authHeaders(String token, {bool withJson = false}) {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
    if (withJson) {
      headers['Content-Type'] = 'application/json';
    }
    return headers;
  }

  Future<void> _loadTeacherSuggestionData({bool showLoader = true}) async {
    final session = context.read<AuthSession>();
    final token = session.token;
    final teacherCin = session.cin;

    if (token == null || token.isEmpty || teacherCin == null) {
      setState(() {
        _isLoadingSuggestions = false;
        _suggestionsError = 'Session enseignant introuvable. Reconnectez-vous.';
      });
      return;
    }

    if (showLoader) {
      setState(() {
        _isLoadingSuggestions = true;
        _suggestionsError = null;
      });
    }

    final classesUri = Uri.parse(
      '$_normalizedApiBaseUrl/api/teachers/$teacherCin/classes',
    );
    final suggestionsUri = Uri.parse(
      '$_normalizedApiBaseUrl/api/teacher/activities/suggestions',
    );

    try {
      final responses = await Future.wait([
        http.get(classesUri, headers: _authHeaders(token)),
        http.get(suggestionsUri, headers: _authHeaders(token)),
      ]);

      if (!mounted) return;

      final classesResponse = responses[0];
      final suggestionsResponse = responses[1];

      if (UnauthorizedHandler.handle(
        context: context,
        statusCode: classesResponse.statusCode,
      ))
        return;
      if (UnauthorizedHandler.handle(
        context: context,
        statusCode: suggestionsResponse.statusCode,
      ))
        return;

      final classesPayload = classesResponse.body.isNotEmpty
          ? jsonDecode(classesResponse.body)
          : <String, dynamic>{};
      final suggestionsPayload = suggestionsResponse.body.isNotEmpty
          ? jsonDecode(suggestionsResponse.body)
          : <String, dynamic>{};

      final classesData = classesPayload is Map<String, dynamic>
          ? classesPayload['data']
          : null;
      final suggestionsData = suggestionsPayload is Map<String, dynamic>
          ? suggestionsPayload['data']
          : null;

      final loadedClasses = _parseTeacherClasses(classesData);
      final loadedSuggestions = _parseTeacherSuggestions(suggestionsData);

      String? errorMessage;
      if (classesResponse.statusCode < 200 ||
          classesResponse.statusCode >= 300) {
        errorMessage = classesPayload is Map<String, dynamic>
            ? classesPayload['message']?.toString()
            : null;
      } else if (suggestionsResponse.statusCode < 200 ||
          suggestionsResponse.statusCode >= 300) {
        errorMessage = suggestionsPayload is Map<String, dynamic>
            ? suggestionsPayload['message']?.toString()
            : null;
      }

      setState(() {
        _teacherClasses = loadedClasses;
        _teacherSuggestions = loadedSuggestions;
        _selectedSuggestionClassId =
            _selectedSuggestionClassId ??
            (loadedClasses.isNotEmpty
                ? loadedClasses.first.id.toString()
                : null);
        _isLoadingSuggestions = false;
        _suggestionsError = errorMessage;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingSuggestions = false;
        _suggestionsError = 'Erreur réseau. Vérifiez la connexion à l\'API.';
      });
    }
  }

  List<_TeacherClassOption> _parseTeacherClasses(dynamic rawData) {
    if (rawData is! List) return [];

    return rawData
        .whereType<Map>()
        .map((row) => row.cast<String, dynamic>())
        .map((row) {
          final id = int.tryParse(row['id']?.toString() ?? '');
          if (id == null) return null;

          return _TeacherClassOption(
            id: id,
            name: (row['name']?.toString() ?? '').trim().isEmpty
                ? 'Classe #$id'
                : row['name'].toString(),
          );
        })
        .whereType<_TeacherClassOption>()
        .toList();
  }

  List<_TeacherSuggestionItem> _parseTeacherSuggestions(dynamic rawData) {
    if (rawData is! List) return [];

    return rawData
        .whereType<Map>()
        .map((row) => row.cast<String, dynamic>())
        .map(_mapSuggestionFromApi)
        .toList();
  }

  _TeacherSuggestionItem _mapSuggestionFromApi(Map<String, dynamic> row) {
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

    return _TeacherSuggestionItem(
      id: row['id']?.toString() ?? '',
      name: (row['title']?.toString() ?? '').trim().isEmpty
          ? 'Activité'
          : row['title'].toString(),
      description: row['description']?.toString() ?? '',
      day: _formatDayFromIsoDate(dateValue),
      dateLabel: _formatDateFromIsoDate(dateValue),
      time: _formatTimeRangeForDisplay(startTimeValue, endTimeValue),
      classLabel: classNames.isEmpty
          ? 'Toutes les classes'
          : classNames.join(', '),
      status: _normalizeActivityStatus(row['status']?.toString()),
    );
  }

  String _formatDayFromIsoDate(String value) {
    if (value.trim().isEmpty) return '-';
    try {
      final parsed = DateTime.parse(value);
      return _capitalize(DateFormat('EEEE', 'fr').format(parsed));
    } catch (_) {
      return value;
    }
  }

  String _formatDateFromIsoDate(String value) {
    if (value.trim().isEmpty) return '-';
    try {
      final parsed = DateTime.parse(value);
      return DateFormat('dd/MM/yyyy').format(parsed);
    } catch (_) {
      return value;
    }
  }

  String _formatTimeForDisplay(String value) {
    final match = RegExp(r'^(\d{2}):(\d{2})').firstMatch(value);
    if (match == null) return value.isEmpty ? '-' : value;
    return '${match.group(1)}h${match.group(2)}';
  }

  String _formatTimeRangeForDisplay(String startValue, String endValue) {
    final startLabel = _formatTimeForDisplay(startValue);
    final endLabel = _formatTimeForDisplay(endValue);

    if (startLabel != '-' && endLabel != '-') {
      return '$startLabel — $endLabel';
    }
    if (startLabel != '-') return startLabel;
    if (endLabel != '-') return endLabel;
    return '-';
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

  String _statusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'Confirmée';
      case 'rejected':
        return 'Rejetée';
      case 'en_cours':
        return 'En cours';
      default:
        return 'En cours';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'en_cours':
        return AppTheme.nearlyDarkBlue;
      default:
        return AppTheme.nearlyDarkBlue;
    }
  }

  Color _statusTextColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green.shade700;
      case 'rejected':
        return Colors.red.shade700;
      case 'en_cours':
        return AppTheme.nearlyDarkBlue;
      default:
        return AppTheme.nearlyDarkBlue;
    }
  }

  int? _parseTimeToMinutes(String value) {
    final match = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(value.trim());
    if (match == null) return null;

    final hours = int.tryParse(match.group(1)!);
    final minutes = int.tryParse(match.group(2)!);
    if (hours == null || minutes == null) return null;
    if (hours < 0 || hours > 23 || minutes < 0 || minutes > 59) return null;
    return (hours * 60) + minutes;
  }

  String _minutesToTime(int totalMinutes) {
    final safeMinutes = totalMinutes.clamp(0, (23 * 60) + 59);
    final hours = (safeMinutes ~/ 60).toString().padLeft(2, '0');
    final minutes = (safeMinutes % 60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  bool _isEndTimeAfterStartTime(String startTime, String endTime) {
    final startMinutes = _parseTimeToMinutes(startTime);
    final endMinutes = _parseTimeToMinutes(endTime);
    if (startMinutes == null || endMinutes == null) return false;
    return endMinutes > startMinutes;
  }

  String _suggestedEndTimeFromStart(
    String startTime, {
    int offsetMinutes = 60,
  }) {
    final startMinutes = _parseTimeToMinutes(startTime);
    if (startMinutes == null) return '11:00';
    return _minutesToTime(startMinutes + offsetMinutes);
  }

  String? _durationLabel(String startTime, String endTime) {
    final startMinutes = _parseTimeToMinutes(startTime);
    final endMinutes = _parseTimeToMinutes(endTime);
    if (startMinutes == null ||
        endMinutes == null ||
        endMinutes <= startMinutes)
      return null;

    final diff = endMinutes - startMinutes;
    final hours = diff ~/ 60;
    final minutes = diff % 60;
    return minutes == 0
        ? '${hours}h'
        : '${hours}h${minutes.toString().padLeft(2, '0')}';
  }

  String _formatIsoDate(DateTime value) {
    return DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime(value.year, value.month, value.day));
  }

  String _extractApiErrorMessage(Map<String, dynamic> body, String fallback) {
    final topMessage = body['message']?.toString().trim();
    final errorsRaw = body['errors'];

    if (errorsRaw is Map) {
      for (final entry in errorsRaw.entries) {
        final value = entry.value;
        if (value is List && value.isNotEmpty) {
          final first = value.first?.toString().trim() ?? '';
          if (first.isNotEmpty) {
            return first;
          }
        }
        final single = value?.toString().trim() ?? '';
        if (single.isNotEmpty) {
          return single;
        }
      }
    }

    if (topMessage != null && topMessage.isNotEmpty) {
      return topMessage;
    }

    return fallback;
  }

  Future<bool> _submitSuggestion({
    required int classId,
    required DateTime selectedDate,
    required String startTime,
    required String endTime,
  }) async {
    final session = context.read<AuthSession>();
    final token = session.token;
    if (token == null || token.isEmpty) {
      _lastSubmitSuggestionError = 'Session expirée. Reconnectez-vous.';
      return false;
    }

    final title = _nameController.text.trim();
    if (title.isEmpty) {
      _lastSubmitSuggestionError = 'Le nom de l\'activité est obligatoire.';
      return false;
    }

    final payload = <String, dynamic>{
      'title': title,
      'description': _descController.text.trim(),
      'date': _formatIsoDate(selectedDate),
      'start_time': startTime,
      'end_time': endTime,
      'class_ids': [classId],
    };

    setState(() {
      _isSubmittingSuggestion = true;
      _lastSubmitSuggestionError = null;
    });

    try {
      final uri = Uri.parse(
        '$_normalizedApiBaseUrl/api/teacher/activities/suggestions',
      );
      final response = await http.post(
        uri,
        headers: _authHeaders(token, withJson: true),
        body: jsonEncode(payload),
      );

      if (!mounted) return false;
      if (UnauthorizedHandler.handle(
        context: context,
        statusCode: response.statusCode,
      ))
        return false;

      final decodedBody = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : null;
      final body = decodedBody is Map<String, dynamic>
          ? decodedBody
          : <String, dynamic>{};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await _loadTeacherSuggestionData(showLoader: false);
        return true;
      }

      _lastSubmitSuggestionError = _extractApiErrorMessage(
        body,
        'Impossible de proposer l\'activité.',
      );
      return false;
    } catch (_) {
      _lastSubmitSuggestionError =
          'Erreur réseau. Vérifiez la connexion à l\'API.';
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingSuggestion = false;
        });
      }
    }
  }

  void _showAddDialog() {
    if (_teacherClasses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune classe assignée pour proposer une activité.'),
        ),
      );
      return;
    }

    final pageMessenger = ScaffoldMessenger.of(context);

    _nameController.clear();
    _descController.clear();
    _selectedSuggestionDate = DateTime.now();
    var selectedSuggestionClassId =
        _selectedSuggestionClassId ?? _teacherClasses.first.id.toString();
    var selectedSuggestionDate = DateTime(
      _selectedSuggestionDate.year,
      _selectedSuggestionDate.month,
      _selectedSuggestionDate.day,
    );
    var selectedStartTime = '10:00';
    var selectedEndTime = '11:00';
    var isDialogSubmitting = false;
    String? dialogError;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Proposer une activité',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkerText,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nom de l\'activité',
                    labelStyle: TextStyle(fontFamily: AppTheme.fontName),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  style: TextStyle(fontFamily: AppTheme.fontName),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(fontFamily: AppTheme.fontName),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  style: TextStyle(fontFamily: AppTheme.fontName),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBDBDBD)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    title: Text(
                      'Date',
                      style: TextStyle(
                        fontFamily: AppTheme.fontName,
                        fontSize: 13,
                        color: AppTheme.grey,
                      ),
                    ),
                    subtitle: Text(
                      DateFormat('dd/MM/yyyy').format(selectedSuggestionDate),
                      style: TextStyle(
                        fontFamily: AppTheme.fontName,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkerText,
                      ),
                    ),
                    trailing: Icon(
                      Icons.calendar_today,
                      color: AppTheme.nearlyDarkBlue,
                      size: 18,
                    ),
                    onTap: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedSuggestionDate,
                        firstDate: DateTime(now.year - 1, 1, 1),
                        lastDate: DateTime(now.year + 3, 12, 31),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          selectedSuggestionDate = DateTime(
                            picked.year,
                            picked.month,
                            picked.day,
                          );
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 12),
                _buildTimeRangePicker(
                  startTime: selectedStartTime,
                  endTime: selectedEndTime,
                  onStartChange: (nextStartTime) {
                    final nextEndTime =
                        _isEndTimeAfterStartTime(nextStartTime, selectedEndTime)
                        ? selectedEndTime
                        : _suggestedEndTimeFromStart(nextStartTime);
                    setDialogState(() {
                      selectedStartTime = nextStartTime;
                      selectedEndTime = nextEndTime;
                      dialogError = null;
                    });
                  },
                  onEndChange: (nextEndTime) {
                    setDialogState(() {
                      selectedEndTime = nextEndTime;
                      if (_isEndTimeAfterStartTime(
                        selectedStartTime,
                        nextEndTime,
                      )) {
                        dialogError = null;
                      } else {
                        dialogError =
                            'L\'heure de fin doit être après l\'heure de début.';
                      }
                    });
                  },
                ),
                if (dialogError != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      dialogError!,
                      style: TextStyle(
                        fontFamily: AppTheme.fontName,
                        fontSize: 12,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedSuggestionClassId,
                  decoration: InputDecoration(
                    labelText: 'Classe',
                    labelStyle: TextStyle(fontFamily: AppTheme.fontName),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: _teacherClasses
                      .map(
                        (classroom) => DropdownMenuItem(
                          value: classroom.id.toString(),
                          child: Text(
                            classroom.name,
                            style: TextStyle(fontFamily: AppTheme.fontName),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setDialogState(() {
                    if (v != null) selectedSuggestionClassId = v;
                  }),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Annuler',
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  color: AppTheme.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: isDialogSubmitting
                  ? null
                  : () async {
                      final title = _nameController.text.trim();
                      if (title.isEmpty) {
                        setDialogState(() {
                          dialogError =
                              'Le nom de l\'activité est obligatoire.';
                        });
                        return;
                      }

                      final classId = int.tryParse(selectedSuggestionClassId);
                      if (classId == null) {
                        setDialogState(() {
                          dialogError = 'Choisissez une classe.';
                        });
                        return;
                      }
                      if (!_isEndTimeAfterStartTime(
                        selectedStartTime,
                        selectedEndTime,
                      )) {
                        setDialogState(() {
                          dialogError =
                              'Choisissez une plage horaire valide (fin > début).';
                        });
                        return;
                      }

                      setDialogState(() {
                        isDialogSubmitting = true;
                        dialogError = null;
                      });

                      final submitted = await _submitSuggestion(
                        classId: classId,
                        selectedDate: selectedSuggestionDate,
                        startTime: selectedStartTime,
                        endTime: selectedEndTime,
                      );
                      if (!context.mounted) return;

                      if (submitted) {
                        setState(() {
                          _selectedSuggestionClassId =
                              selectedSuggestionClassId;
                          _selectedSuggestionDate = selectedSuggestionDate;
                        });
                        Navigator.pop(dialogContext);
                        pageMessenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Activité proposée !',
                              style: TextStyle(fontFamily: AppTheme.fontName),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        setDialogState(() {
                          isDialogSubmitting = false;
                          dialogError =
                              _lastSubmitSuggestionError ??
                              'Impossible de proposer l\'activité.';
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.nearlyDarkBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isDialogSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Proposer',
                      style: TextStyle(
                        fontFamily: AppTheme.fontName,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRangePicker({
    required String startTime,
    required String endTime,
    required ValueChanged<String> onStartChange,
    required ValueChanged<String> onEndChange,
  }) {
    final duration = _durationLabel(startTime, endTime);
    final isValid = duration != null;

    final durationBadge = isValid
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.nearlyDarkBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              duration,
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: AppTheme.nearlyDarkBlue,
              ),
            ),
          )
        : Icon(Icons.arrow_forward, color: AppTheme.grey, size: 18);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBDBDBD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Horaire',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontSize: 13,
              color: AppTheme.grey,
            ),
          ),
          const SizedBox(height: 10),
          _buildTimePickerField(
            label: 'Heure début',
            value: startTime,
            onChange: onStartChange,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(child: durationBadge),
          ),
          _buildTimePickerField(
            label: 'Heure fin',
            value: endTime,
            onChange: onEndChange,
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerField({
    required String label,
    required String value,
    required ValueChanged<String> onChange,
  }) {
    const minuteSteps = <int>[0, 15, 30, 45];
    final totalMinutes = _parseTimeToMinutes(value) ?? (10 * 60);
    final currentHour = totalMinutes ~/ 60;
    final rawMinute = totalMinutes % 60;
    final currentMinute = minuteSteps.contains(rawMinute) ? rawMinute : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTheme.fontName,
            fontSize: 12,
            color: AppTheme.grey,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: currentHour,
                isExpanded: true,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  color: AppTheme.darkerText,
                  fontWeight: FontWeight.w600,
                ),
                items: List.generate(24, (hour) {
                  return DropdownMenuItem<int>(
                    value: hour,
                    child: Text(hour.toString().padLeft(2, '0')),
                  );
                }),
                onChanged: (hour) {
                  if (hour == null) return;
                  onChange(_minutesToTime((hour * 60) + currentMinute));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                ':',
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.darkerText,
                ),
              ),
            ),
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: currentMinute,
                isExpanded: true,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  color: AppTheme.darkerText,
                  fontWeight: FontWeight.w600,
                ),
                items: minuteSteps
                    .map(
                      (minute) => DropdownMenuItem<int>(
                        value: minute,
                        child: Text(minute.toString().padLeft(2, '0')),
                      ),
                    )
                    .toList(),
                onChanged: (minute) {
                  if (minute == null) return;
                  onChange(_minutesToTime((currentHour * 60) + minute));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return Container(
      color: AppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _isSubmittingSuggestion ? null : _showAddDialog,
          backgroundColor: AppTheme.nearlyDarkBlue,
          icon: _isSubmittingSuggestion
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.add, color: Colors.white),
          label: Text(
            'Proposer',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        appBar: AppBar(
          title: Text(
            'Gestion des activités',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: AppTheme.darkerText,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Navigator.canPop(context)
              ? IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: AppTheme.darkerText),
                  onPressed: () => Navigator.pop(context),
                )
              : null,
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            const SizedBox(height: 8),
            Expanded(child: _buildTeacherSuggestions()),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherSuggestions() {
    if (_isLoadingSuggestions) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_suggestionsError != null && _teacherSuggestions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _suggestionsError!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _loadTeacherSuggestionData(),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '${_teacherSuggestions.length} activité${_teacherSuggestions.length > 1 ? 's' : ''}',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontSize: 14,
              color: AppTheme.grey,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _teacherSuggestions.length,
            itemBuilder: (context, index) {
              final activity = _teacherSuggestions[index];
              final statusColor = _statusColor(activity.status);
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.grey.withValues(alpha: 0.12),
                      offset: const Offset(0, 2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.lightbulb,
                          color: statusColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    activity.name,
                                    style: TextStyle(
                                      fontFamily: AppTheme.fontName,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppTheme.darkerText,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _statusLabel(activity.status),
                                    style: TextStyle(
                                      fontFamily: AppTheme.fontName,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: _statusTextColor(activity.status),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              activity.description,
                              style: TextStyle(
                                fontFamily: AppTheme.fontName,
                                fontSize: 14,
                                color: AppTheme.grey,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: AppTheme.nearlyDarkBlue,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    '${activity.day} • ${activity.dateLabel}',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: AppTheme.fontName,
                                      fontSize: 13,
                                      color: AppTheme.nearlyDarkBlue,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: AppTheme.nearlyDarkBlue,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  activity.time,
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontName,
                                    fontSize: 13,
                                    color: AppTheme.nearlyDarkBlue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.groups_2_outlined,
                                  size: 14,
                                  color: AppTheme.nearlyDarkBlue,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    activity.classLabel,
                                    style: TextStyle(
                                      fontFamily: AppTheme.fontName,
                                      fontSize: 13,
                                      color: AppTheme.nearlyDarkBlue,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}
