import 'package:newv/utils/api_constants.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:newv/app_theme.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/utils/unauthorized_handler.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:newv/theme_manager.dart';
import 'package:newv/theme_colors.dart';

// File: presence_tab.dart
// Purpose: Interactive calendar showing a child's attendance history.
// Usage: Tab item in ChildDetailsPage.
// API Usage: Yes, GET /api/children/{childId}/presences?month=X&year=Y.
// Dependencies: AuthSession, UnauthorizedHandler, ApiConstants.

/// A calendar-based view for tracking a child's presence and absence.
class ChildTrackingPresenceTab extends StatefulWidget {
  static const String _apiBaseUrl = ApiConstants.baseUrl;

  final DateTime focusedDay;
  final ValueChanged<DateTime> onFocusedDayChanged;
  final int? childId;
  final DateTime minDate;
  final DateTime maxDate;

  const ChildTrackingPresenceTab({
    super.key,
    required this.focusedDay,
    required this.onFocusedDayChanged,
    required this.childId,
    required this.minDate,
    required this.maxDate,
  });

  @override
  State<ChildTrackingPresenceTab> createState() =>
      _ChildTrackingPresenceTabState();
}

class _ChildTrackingPresenceTabState extends State<ChildTrackingPresenceTab> {
  // Modern Theme Colors
  static Color get _baseDark => ThemeManager.instance.isLightMode
      ? const Color(0xFFF0F2F5)
      : const Color(0xFF141B2D);
  static Color get _tealAccent => ThemeManager.instance.isLightMode
      ? const Color(0xFF009688)
      : const Color(0xFF4CCEAC);
  static Color get _indigoAccent => ThemeManager.instance.isLightMode
      ? const Color(0xFF3F51B5)
      : const Color(0xFF6870FA);
  static Color get _lightText => ThemeManager.instance.isLightMode
      ? const Color(0xFF212529)
      : const Color(0xFFF2F0F0);
  static Color get _mutedText => ThemeManager.instance.isLightMode
      ? const Color(0xFF6C757D)
      : const Color(0xFFA1A4AB);

  bool _isLoading = true;
  String? _errorMessage;
  Map<int, String> _attendanceStatus = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMonthPresence());
  }

  @override
  void didUpdateWidget(covariant ChildTrackingPresenceTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    final monthChanged =
        oldWidget.focusedDay.month != widget.focusedDay.month ||
        oldWidget.focusedDay.year != widget.focusedDay.year;
    final childChanged = oldWidget.childId != widget.childId;

    if (monthChanged || childChanged) {
      _loadMonthPresence();
    }
  }

  Future<void> _loadMonthPresence() async {
    final childId = widget.childId;
    final session = context.read<AuthSession>();
    final token = session.token;
    final requestedMonth = widget.focusedDay.month;
    final requestedYear = widget.focusedDay.year;

    if (childId == null) {
      setState(() {
        _isLoading = false;
        _attendanceStatus = {};
        _errorMessage = 'Enfant introuvable.';
      });
      return;
    }

    if (token == null || token.isEmpty) {
      setState(() {
        _isLoading = false;
        _attendanceStatus = {};
        _errorMessage = 'Session parent introuvable. Reconnectez-vous.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final uri = Uri.parse(
      '${ChildTrackingPresenceTab._apiBaseUrl}/api/children/$childId/presences?month=$requestedMonth&year=$requestedYear',
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
      ))
        return;

      if (requestedMonth != widget.focusedDay.month ||
          requestedYear != widget.focusedDay.year) {
        return;
      }

      final body = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          body['data'] is! List) {
        setState(() {
          _isLoading = false;
          _attendanceStatus = {};
          _errorMessage =
              body['message']?.toString() ??
              'Impossible de charger les présences.';
        });
        return;
      }

      final statuses = <int, String>{};
      for (final rawItem in body['data'] as List) {
        if (rawItem is! Map) continue;
        final item = rawItem.cast<String, dynamic>();
        final date = DateTime.tryParse(item['date']?.toString() ?? '');
        if (date == null) continue;

        final statusRaw = item['status'];
        final statusName = statusRaw is Map
            ? statusRaw['name']?.toString().toLowerCase()
            : null;
        if (statusName == 'present' || statusName == 'absent') {
          statuses[date.day] = statusName == 'present' ? 'Présent' : 'Absent';
        }
      }

      setState(() {
        _isLoading = false;
        _attendanceStatus = statuses;
        _errorMessage = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _attendanceStatus = {};
        _errorMessage = 'Erreur réseau. Vérifiez la connexion à l\'API.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    final now = DateTime.now();
    final focusedDay = widget.focusedDay;
    final daysInMonth = DateUtils.getDaysInMonth(
      focusedDay.year,
      focusedDay.month,
    );
    final firstDayOfMonth = DateTime(focusedDay.year, focusedDay.month, 1);
    final int firstWeekday = firstDayOfMonth.weekday;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios, size: 18, color: _lightText),
                onPressed: () {
                  final prevMonth = DateTime(
                    focusedDay.year,
                    focusedDay.month - 1,
                    1,
                  );

                  // Blocks navigating further backward than the month of the active planning start date.
                  if (prevMonth.isAfter(
                    DateTime(widget.minDate.year, widget.minDate.month - 1, 31),
                  )) {
                    widget.onFocusedDayChanged(prevMonth);
                  }
                },
              ),
              GestureDetector(
                onTap: () async {
                  DateTime last = widget.maxDate;
                  if (last.isBefore(widget.minDate)) last = widget.minDate;

                  DateTime initial = focusedDay;
                  if (initial.isBefore(widget.minDate))
                    initial = widget.minDate;
                  if (initial.isAfter(last)) initial = last;

                  final picked = await showDatePicker(
                    context: context,
                    initialDate: initial,
                    firstDate: widget.minDate,
                    lastDate: last,
                    builder: (context, child) {
                      final isLight = ThemeManager.instance.isLightMode;
                      return Theme(
                        data: (isLight ? ThemeData.light() : ThemeData.dark())
                            .copyWith(
                              colorScheme:
                                  (isLight
                                          ? const ColorScheme.light()
                                          : const ColorScheme.dark())
                                      .copyWith(
                                        primary: _tealAccent,
                                        onPrimary: isLight
                                            ? Colors.white
                                            : _baseDark,
                                        surface: _baseDark,
                                        onSurface: _lightText,
                                      ),
                            ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    widget.onFocusedDayChanged(picked);
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_getMonthName(focusedDay.month)} ${focusedDay.year}',
                      style: TextStyle(
                        fontFamily: AppTheme.fontName,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _lightText,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down, color: _lightText),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: _lightText,
                ),
                onPressed: () {
                  final nextMonth = DateTime(
                    focusedDay.year,
                    focusedDay.month + 1,
                    1,
                  );

                  // Blocks navigating further forward than the month of the active planning end date.
                  if (nextMonth.isBefore(
                    DateTime(widget.maxDate.year, widget.maxDate.month + 1, 1),
                  )) {
                    widget.onFocusedDayChanged(nextMonth);
                  }
                },
              ),
            ],
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(
                minHeight: 2,
                valueColor: AlwaysStoppedAnimation<Color>(_tealAccent),
                backgroundColor: ThemeColors.glassBorder,
              ),
            ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.redAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.redAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _loadMonthPresence,
                      child: Text(
                        'Réessayer',
                        style: TextStyle(color: _tealAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ThemeColors.glassBackgroundSubtle,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ThemeColors.glassBorderWithOpacity(0.08),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['D', 'L', 'M', 'M', 'J', 'V', 'S'].map((day) {
                    return SizedBox(
                      width: 32,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _mutedText,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: daysInMonth + (firstWeekday % 7),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    final int startOffset = firstWeekday % 7;
                    if (index < startOffset) {
                      return const SizedBox();
                    }
                    final int day = index - startOffset + 1;
                    String? status = _attendanceStatus[day];

                    Color bgColor = Colors.transparent;
                    Color textColor = _lightText;

                    if (status == 'Présent') {
                      bgColor = const Color(0xFF00C853);
                      textColor = Colors.white;
                    } else if (status == 'Absent') {
                      bgColor = const Color(0xFFFF3D00);
                      textColor = Colors.white;
                    } else if (status == 'Pas d\'école') {
                      bgColor = ThemeColors.glassBorder;
                      textColor = _mutedText;
                    } else {
                      final date = DateTime(
                        focusedDay.year,
                        focusedDay.month,
                        day,
                      );
                      final isWeekend =
                          date.weekday == DateTime.saturday ||
                          date.weekday == DateTime.sunday;
                      final isFuture = date.isAfter(
                        DateTime(now.year, now.month, now.day),
                      );
                      if (isWeekend) {
                        status = 'Pas d\'école';
                        bgColor = ThemeColors.glassBorder;
                        textColor = _mutedText;
                      } else if (isFuture) {
                        status = 'Pas encore';
                        textColor = _mutedText.withValues(alpha: 0.5);
                      }
                    }

                    return Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(8),
                        border: bgColor == Colors.transparent
                            ? Border.all(color: ThemeColors.glassBorder)
                            : null,
                      ),
                      child: Text(
                        '$day',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildLegendItem('Présent', const Color(0xFF00C853)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildLegendItem('Absent', const Color(0xFFFF3D00)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildLegendItem(
                      'Pas d\'école',
                      ThemeColors.glassBorder,
                      textColor: _mutedText,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildLegendItem(
                      'Pas encore',
                      Colors.transparent,
                      borderColor: ThemeColors.glassBorder,
                      textColor: _mutedText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    String label,
    Color color, {
    Color textColor = Colors.white,
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ThemeColors.glassBackgroundSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.glassBorderWithOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: borderColor != null
                  ? Border.all(color: borderColor)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w500, color: _lightText),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
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
    return months[month - 1];
  }
}
