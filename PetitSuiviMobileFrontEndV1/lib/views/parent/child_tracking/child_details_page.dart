import 'package:newv/theme_manager.dart';
import 'package:newv/utils/api_constants.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:newv/app_theme.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/models/signalement.dart';
import 'package:newv/views/parent/child_tracking/competences/competences_tab.dart';
import 'package:newv/views/parent/child_tracking/presence/presence_tab.dart';
import 'package:newv/views/parent/child_tracking/suivi/suivi_tab.dart';
import 'package:provider/provider.dart';

// File: child_details_page.dart
// Purpose: Feature-rich dashboard for a specific child's school life.
// Usage: Navigated from ChildSelectionPage.
// API Usage: Yes, GET /api/children/{childId}/signalements.
// Dependencies: Signalement, CompetencesTab, PresenceTab, SuiviTab, AuthSession.

/// A multi-tab page displaying a child's tracking data, attendance, and skills.
class ChildDetailsPage extends StatefulWidget {
  final Map<String, dynamic> childData;
  final int initialTabIndex;

  const ChildDetailsPage({
    super.key,
    required this.childData,
    this.initialTabIndex = 0,
  });

  @override
  State<ChildDetailsPage> createState() => _ChildDetailsPageState();
}

class _ChildDetailsPageState extends State<ChildDetailsPage>
    with SingleTickerProviderStateMixin {
  static const String _apiBaseUrl = ApiConstants.baseUrl;

  late TabController _tabController;
  late DateTime _focusedDay;
  late final int? _childId;
  late final int? _classId;
  DateTime? _activePlanningStart;
  DateTime? _activePlanningEnd;

  // Today's signalement alerts
  List<Signalement> _todaySignalements = [];
  bool _alertDismissed = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 2),
    );
    _focusedDay = DateTime.now();
    _childId = _resolveChildId(widget.childData);
    _classId = _resolveClassId(widget.childData);
    _resolvePlanningDates(widget.childData);
    _tabController.addListener(_handleTabChanged);
    _loadTodaySignalements();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _persistCurrentRouteState();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChanged() {
    if (_tabController.indexIsChanging) return;
    _persistCurrentRouteState();
  }

  Future<void> _persistCurrentRouteState() async {
    if (_childId == null) return;
    await context.read<AuthSession>().saveParentChildRoute(
      childId: _childId!,
      tabIndex: _tabController.index,
    );
  }

  Future<void> _handleBackNavigation() async {
    await context.read<AuthSession>().clearParentChildRoute();
    if (!mounted) return;
    Navigator.pop(context);
  }

  int? _resolveChildId(Map<String, dynamic> childData) {
    final directId = int.tryParse(childData['id']?.toString() ?? '');
    if (directId != null) return directId;

    final extraData = childData['extraData'];
    if (extraData is Map) {
      final nestedId = int.tryParse(extraData['id']?.toString() ?? '');
      if (nestedId != null) return nestedId;
    }

    return null;
  }

  int? _resolveClassId(Map<String, dynamic> childData) {
    final extraData = childData['extraData'];
    if (extraData is Map) {
      final classes = extraData['classes'];
      if (classes is List && classes.isNotEmpty) {
        final latest = classes.first;
        if (latest is Map) {
          return int.tryParse(latest['id']?.toString() ?? '');
        }
      }

      final inscriptions = extraData['inscriptions'];
      if (inscriptions is List && inscriptions.isNotEmpty) {
        final latest = inscriptions.last;
        if (latest is Map) {
          final clazz = latest['class'];
          if (clazz is Map) {
            return int.tryParse(clazz['id']?.toString() ?? '');
          }
          return int.tryParse(latest['class_id']?.toString() ?? '');
        }
      }
    }
    return null;
  }

  void _resolvePlanningDates(Map<String, dynamic> childData) {
    final extraData = childData['extraData'];
    if (extraData is Map) {
      final classes = extraData['classes'];
      if (classes is List && classes.isNotEmpty) {
        final latest = classes.first;
        if (latest is Map) {
          final startStr = latest['planning_start']?.toString();
          final endStr = latest['planning_end']?.toString();
          if (startStr != null)
            _activePlanningStart = DateTime.tryParse(startStr);
          if (endStr != null) _activePlanningEnd = DateTime.tryParse(endStr);
          _focusedDay = _clampFocusedDayToPlanning(_focusedDay);
          return;
        }
      }
    }

    _focusedDay = _clampFocusedDayToPlanning(_focusedDay);
  }

  DateTime _clampFocusedDayToPlanning(DateTime day) {
    final start = _activePlanningStart;
    final end = _activePlanningEnd;

    if (start != null && day.isBefore(start)) {
      return DateTime(start.year, start.month, 1);
    }

    if (end != null && day.isAfter(end)) {
      return DateTime(end.year, end.month, 1);
    }

    return day;
  }

  Future<void> _loadTodaySignalements() async {
    if (_childId == null) return;
    final session = context.read<AuthSession>();
    final token = session.token;
    if (token == null || token.isEmpty) return;

    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/api/children/$_childId/signalements'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (!mounted) return;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'];
        if (data is List) {
          final now = DateTime.now();
          final all = data
              .whereType<Map<String, dynamic>>()
              .map((e) => Signalement.fromJson(e))
              .toList();
          final today = all
              .where(
                (s) =>
                    !s.isRead &&
                    s.incidentTime.year == now.year &&
                    s.incidentTime.month == now.month &&
                    s.incidentTime.day == now.day,
              )
              .toList();
          setState(() => _todaySignalements = today);
        }
      }
    } catch (e) {
      debugPrint('[ChildDetails] Failed to load signalements: $e');
    }
  }

  Future<void> _dismissTodaySignalements() async {
    if (_childId == null || _todaySignalements.isEmpty) {
      if (mounted) {
        setState(() => _alertDismissed = true);
      }
      return;
    }

    final session = context.read<AuthSession>();
    final token = session.token;
    if (token == null || token.isEmpty) {
      if (mounted) {
        setState(() => _alertDismissed = true);
      }
      return;
    }

    try {
      final response = await http.patch(
        Uri.parse('$_apiBaseUrl/api/children/$_childId/signalements/read'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'signalement_ids': _todaySignalements.map((s) => s.id).toList(),
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Failed to mark signalements as read: ${response.statusCode}',
        );
      }

      if (!mounted) return;
      setState(() {
        _alertDismissed = true;
        _todaySignalements = [];
      });
    } catch (e) {
      debugPrint('[ChildDetails] Failed to dismiss signalements: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de masquer le signalement pour le moment.'),
        ),
      );
    }
  }

  IconData _alertTypeIcon(String alertType) {
    switch (alertType) {
      case 'Humeur':
        return Icons.mood_bad;
      case 'Isolement':
        return Icons.person_off;
      case 'Pleurs':
        return Icons.water_drop;
      case 'Agressivité':
        return Icons.flash_on;
      default:
        return Icons.more_horiz;
    }
  }

  Color _alertTypeColor(String alertType) {
    switch (alertType) {
      case 'Humeur':
        return const Color(0xFFFFA726);
      case 'Isolement':
        return const Color(0xFF7E57C2);
      case 'Pleurs':
        return const Color(0xFF42A5F5);
      case 'Agressivité':
        return const Color(0xFFEF5350);
      default:
        return const Color(0xFF78909C);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    // Modern Theme Colors - dynamic for light/dark mode
    final bool isLight = ThemeManager.instance.isLightMode;
    final Color baseDark = isLight
        ? const Color(0xFFF0F2F5)
        : const Color(0xFF141B2D);
    final Color tealAccent = isLight
        ? const Color(0xFF009688)
        : const Color(0xFF4CCEAC);
    final Color indigoAccent = isLight
        ? const Color(0xFF3F51B5)
        : const Color(0xFF6870FA);
    final Color lightText = isLight
        ? const Color(0xFF212529)
        : const Color(0xFFF2F0F0);
    final Color mutedText = isLight
        ? const Color(0xFF6C757D)
        : const Color(0xFFA1A4AB);

    return Container(
      color: baseDark,
      child: PopScope(
        canPop: true,
        onPopInvokedWithResult: (bool didPop, dynamic result) async {
          if (didPop) {
            await context.read<AuthSession>().clearParentChildRoute();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              widget.childData['firstName'],
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: lightText,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: lightText),
              onPressed: _handleBackNavigation,
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: tealAccent,
              unselectedLabelColor: mutedText,
              indicatorColor: tealAccent,
              indicatorWeight: 2.5,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: const TextStyle(
                fontFamily: AppTheme.fontName,
                fontWeight: FontWeight.bold,
              ),
              isScrollable: false,
              tabs: const [
                Tab(text: 'Suivi', icon: Icon(Icons.show_chart)),
                Tab(text: 'Présence', icon: Icon(Icons.calendar_today)),
                Tab(text: 'Compétences', icon: Icon(Icons.star)),
              ],
            ),
          ),
          body: Column(
            children: [
              // ── Today's signalement alert banner ──
              if (_todaySignalements.isNotEmpty && !_alertDismissed)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.redAccent.withValues(alpha: 0.15),
                        Colors.orange.withValues(alpha: 0.10),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.redAccent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.notification_important,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Signalements du jour',
                              style: TextStyle(
                                fontFamily: AppTheme.fontName,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${_todaySignalements.length}',
                              style: const TextStyle(
                                fontFamily: AppTheme.fontName,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _dismissTodaySignalements,
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: mutedText.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ..._todaySignalements.map(
                        (s) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                _alertTypeIcon(s.alertType),
                                size: 16,
                                color: _alertTypeColor(s.alertType),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s.alertType,
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontName,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: _alertTypeColor(s.alertType),
                                      ),
                                    ),
                                    if (s.comment != null &&
                                        s.comment!.isNotEmpty)
                                      Text(
                                        s.comment!,
                                        style: TextStyle(
                                          fontFamily: AppTheme.fontName,
                                          fontSize: 12,
                                          color: lightText,
                                        ),
                                      ),
                                    if (s.teacher != null)
                                      Text(
                                        'Par ${s.teacher!.fullName}',
                                        style: TextStyle(
                                          fontFamily: AppTheme.fontName,
                                          fontSize: 11,
                                          color: mutedText,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Tab content ──
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    ChildTrackingSuiviTab(classId: _classId),
                    ChildTrackingPresenceTab(
                      focusedDay: _focusedDay,
                      minDate:
                          _activePlanningStart ??
                          DateTime(DateTime.now().year, 8, 1),
                      maxDate:
                          _activePlanningEnd ??
                          DateTime(DateTime.now().year + 1, 7, 31),
                      onFocusedDayChanged: (newDay) {
                        setState(() {
                          _focusedDay = newDay;
                        });
                      },
                      childId: _childId,
                    ),
                    ChildTrackingCompetencesTab(
                      childName: widget.childData['firstName'] as String,
                      minDate:
                          _activePlanningStart ??
                          DateTime(DateTime.now().year, 8, 1),
                      maxDate:
                          _activePlanningEnd ??
                          DateTime(DateTime.now().year + 1, 7, 31),
                      childId: _childId,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
