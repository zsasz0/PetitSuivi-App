import 'package:flutter/material.dart';
import 'package:newv/views/teacher/teacher_theme.dart';
import 'package:newv/views/teacher/activities/apis/activities_api.dart';
import 'package:newv/views/teacher/activities/components/activities_calendar/activities_day_activities_list.dart';

class ActivitiesTodayQuickAccess extends StatelessWidget {
  final DateTime day;
  final List<ApiActivity> activities;
  final Function(ApiActivity, String) onStatusUpdate;
  final Function(ApiActivity) isUpdating;
  final String Function(ApiActivity) effectiveStatus;

  const ActivitiesTodayQuickAccess({
    super.key,
    required this.day,
    required this.activities,
    required this.onStatusUpdate,
    required this.isUpdating,
    required this.effectiveStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: TeacherTheme.cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 4.0),
            child: Row(
              children: [
                Icon(Icons.bolt, color: TeacherTheme.tealAccent, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Accès Rapide',
                  style: TextStyle(
                    fontFamily: TeacherTheme.fontName,
                    fontWeight: FontWeight.bold,
                    color: TeacherTheme.tealAccent,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ActivitiesDayActivitiesList(
            day: day,
            dayActivities: activities,
            onStatusUpdate: onStatusUpdate,
            isUpdating: isUpdating,
            effectiveStatus: effectiveStatus,
          ),
        ],
      ),
    );
  }
}
