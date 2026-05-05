import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/views/parent/child_tracking/components/child_tracking/competences_tab.dart';
import 'package:newv/views/parent/child_tracking/components/child_tracking/presence_tab.dart';
import 'package:newv/views/parent/child_tracking/components/child_tracking/suivi_tab.dart';
import 'package:newv/views/parent/child_tracking/controllers/child_tracking_controller.dart';
import 'package:newv/views/parent/child_tracking/themes/child_tracking_theme.dart';
import 'package:provider/provider.dart';

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
  late TabController _tabController;
  late DateTime _focusedDay;
  late final int? _childId;
  late final int? _classId;
  DateTime? _activePlanningStart;
  DateTime? _activePlanningEnd;
  late ChildTrackingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ChildTrackingController();
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
    
    if (_childId != null) {
      _controller.loadTodaySignalements(context, _childId);
    }
    
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
      childId: _childId,
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
    // Try extraData first (legacy), then top-level (new toJson format)
    final extraData = childData['extraData'];
    final classes = (extraData is Map ? extraData['classes'] : null) ?? childData['classes'];
    final inscriptions = (extraData is Map ? extraData['inscriptions'] : null) ?? childData['inscriptions'];

    if (classes is List && classes.isNotEmpty) {
      final latest = classes.first;
      if (latest is Map) {
        return int.tryParse(latest['id']?.toString() ?? '');
      }
    }

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
    return null;
  }

  void _resolvePlanningDates(Map<String, dynamic> childData) {
    final extraData = childData['extraData'];
    final classes = (extraData is Map ? extraData['classes'] : null) ?? childData['classes'];

    if (classes is List && classes.isNotEmpty) {
      final latest = classes.first;
      if (latest is Map) {
        final planning = latest['planning'];
        if (planning is Map) {
          final start = planning['startDate'] ?? planning['start_date'];
          final end = planning['endDate'] ?? planning['end_date'];
          if (start != null) _activePlanningStart = DateTime.tryParse(start.toString());
          if (end != null) _activePlanningEnd = DateTime.tryParse(end.toString());
        } else {
          final startStr = (latest['planning_start'] ?? latest['planningStart'])?.toString();
          final endStr = (latest['planning_end'] ?? latest['planningEnd'])?.toString();
          if (startStr != null) {
            _activePlanningStart = DateTime.tryParse(startStr);
          }
          if (endStr != null) _activePlanningEnd = DateTime.tryParse(endStr);
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Container(
          color: ChildTrackingTheme.baseDark,
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
                  widget.childData['firstName'] ?? '',
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: ChildTrackingTheme.lightText,
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: ChildTrackingTheme.lightText),
                  onPressed: _handleBackNavigation,
                ),
                bottom: TabBar(
                  controller: _tabController,
                  labelColor: ChildTrackingTheme.tealAccent,
                  unselectedLabelColor: ChildTrackingTheme.mutedText,
                  indicatorColor: ChildTrackingTheme.tealAccent,
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
                  if (_controller.todaySignalements.isNotEmpty && !_controller.alertDismissed)
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
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${_controller.todaySignalements.length}',
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
                                onTap: () => _controller.dismissTodaySignalements(context, _childId!),
                                child: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: ChildTrackingTheme.mutedText.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ..._controller.todaySignalements.map(
                            (s) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    _alertTypeIcon(s.alertType),
                                    size: 16,
                                    color: ChildTrackingTheme.alertTypeColor(s.alertType),
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
                                            color: ChildTrackingTheme.alertTypeColor(s.alertType),
                                          ),
                                        ),
                                        if (s.comment != null && s.comment!.isNotEmpty)
                                          Text(
                                            s.comment!,
                                            style: TextStyle(
                                              fontFamily: AppTheme.fontName,
                                              fontSize: 12,
                                              color: ChildTrackingTheme.lightText,
                                            ),
                                          ),
                                        if (s.teacher != null)
                                          Text(
                                            'Par ${s.teacher!.fullName}',
                                            style: TextStyle(
                                              fontFamily: AppTheme.fontName,
                                              fontSize: 11,
                                              color: ChildTrackingTheme.mutedText,
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
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        ChildTrackingSuiviTab(classId: _classId),
                        ChildTrackingPresenceTab(
                          focusedDay: _focusedDay,
                          minDate: _activePlanningStart ?? DateTime(DateTime.now().month >= 9 ? DateTime.now().year : DateTime.now().year - 1, 9, 1),
                          maxDate: _activePlanningEnd ?? DateTime(DateTime.now().month >= 9 ? DateTime.now().year + 1 : DateTime.now().year, 7, 31),
                          onFocusedDayChanged: (newDay) {
                            setState(() {
                              _focusedDay = newDay;
                            });
                          },
                          childId: _childId,
                        ),
                        ChildTrackingCompetencesTab(
                          childName: widget.childData['firstName']?.toString() ?? '',
                          minDate: _activePlanningStart ?? DateTime(DateTime.now().month >= 9 ? DateTime.now().year : DateTime.now().year - 1, 9, 1),
                          maxDate: _activePlanningEnd ?? DateTime(DateTime.now().month >= 9 ? DateTime.now().year + 1 : DateTime.now().year, 7, 31),
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
      },
    );
  }
}
