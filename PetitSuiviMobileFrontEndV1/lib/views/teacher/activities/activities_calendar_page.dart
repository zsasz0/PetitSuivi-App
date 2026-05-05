import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:newv/views/themes/theme_manager.dart';
import 'package:newv/views/teacher/teacher_theme.dart';
import 'package:newv/views/teacher/activities/controllers/activities_calendar_controller.dart';
import 'package:newv/views/teacher/activities/components/common/activities_class_selector.dart';
import 'package:newv/views/teacher/activities/components/common/activities_archived_view.dart';
import 'package:newv/views/teacher/activities/components/activities_calendar/activities_calendar_header.dart';
import 'package:newv/views/teacher/activities/components/activities_calendar/activities_month_card.dart';
import 'package:newv/views/teacher/activities/components/activities_calendar/activities_day_grid_view.dart';
import 'package:newv/views/teacher/activities/components/activities_calendar/activities_day_activities_list.dart';
import 'package:newv/views/teacher/activities/components/activities_calendar/activities_today_quick_access.dart';

class ActivitiesCalendarPage extends StatefulWidget {
  const ActivitiesCalendarPage({super.key});

  @override
  State<ActivitiesCalendarPage> createState() => _ActivitiesCalendarPageState();
}

class _ActivitiesCalendarPageState extends State<ActivitiesCalendarPage> {
  late ActivitiesCalendarController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ActivitiesCalendarController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadClasses(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ActivitiesCalendarController>.value(
      value: _controller,
      child: Consumer<ActivitiesCalendarController>(
        builder: (context, controller, child) {
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
                  onPressed: () => controller.loadClasses(context),
                  tooltip: 'Rafraîchir',
                ),
              ],
            ),
            body: controller.planningIsArchived
                ? ActivitiesArchivedView(planningLabel: controller.fetchedPlanningLabel)
                : Column(
                    children: [
                      ActivitiesClassSelector(
                        classes: controller.classes,
                        selectedClass: controller.selectedClass,
                        isLoading: controller.loadingClasses,
                        error: controller.classesError,
                        onClassSelected: (cls) => controller.selectClass(context, cls),
                        onRefresh: () => controller.loadClasses(context),
                      ),
                      Expanded(child: _buildContent(controller)),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildContent(ActivitiesCalendarController controller) {
    if (controller.loadingActivities && controller.activities.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.activitiesError != null && controller.activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: TeacherTheme.mutedText, size: 48),
            const SizedBox(height: 16),
            Text(
              controller.activitiesError!,
              style: TextStyle(color: TeacherTheme.mutedText),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (controller.selectedClass != null) {
                  controller.loadActivities(context, controller.selectedClass!);
                }
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 30),
      children: [
        ActivitiesCalendarHeader(
          visibleYear: controller.visibleYear,
          canGoPrev: controller.canGoPrev,
          canGoNext: controller.canGoNext,
          onYearChanged: (year) => controller.updateVisibleYear(year),
        ),
        ...List.generate(12, (index) {
          final month = index + 1;
          if (!controller.isPlanningMonth(controller.visibleYear, month)) {
            return const SizedBox.shrink();
          }

          final isExpanded = controller.expandedMonth == month;
          final count = controller.activityCountForMonth(controller.visibleYear, month);

          return ActivitiesMonthCard(
            year: controller.visibleYear,
            month: month,
            isExpanded: isExpanded,
            activityCount: count,
            onTap: () {
              controller.updateExpandedMonth(isExpanded ? null : month);
              controller.updateSelectedDay(null);
            },
            child: Column(
              children: [
                ActivitiesDayGridView(
                  year: controller.visibleYear,
                  month: month,
                  selectedDay: controller.selectedDay,
                  activityByDay: controller.activityByDay,
                  onDaySelected: (day) => controller.updateSelectedDay(day),
                ),
                if (controller.selectedDay != null &&
                    controller.selectedDay!.month == month &&
                    controller.selectedDay!.year == controller.visibleYear)
                  ActivitiesDayActivitiesList(
                    day: controller.selectedDay!,
                    dayActivities: controller.activitiesForDay(controller.selectedDay!),
                    onStatusUpdate: (a, status) => controller.updateStatus(
                      context: context,
                      activity: a,
                      status: status,
                    ),
                    isUpdating: (a) => controller.isStatusUpdateInFlight(a),
                    effectiveStatus: (a) => controller.effectiveStatus(a),
                  ),
              ],
            ),
          );
        }),
        if (controller.selectedDay == null)
          ActivitiesTodayQuickAccess(
            day: DateTime.now(),
            activities: controller.todayActivities,
            onStatusUpdate: (a, status) => controller.updateStatus(
              context: context,
              activity: a,
              status: status,
            ),
            isUpdating: (a) => controller.isStatusUpdateInFlight(a),
            effectiveStatus: (a) => controller.effectiveStatus(a),
          ),
      ],
    );
  }

}
