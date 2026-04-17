import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:newv/views/teacher/teacher_theme.dart';
import 'package:newv/views/teacher/activities/themes/activities_theme.dart';
import 'package:newv/views/teacher/activities/apis/activities_api.dart';

class ActivitiesDayActivitiesList extends StatelessWidget {
  final DateTime day;
  final List<ApiActivity> dayActivities;
  final Function(ApiActivity, String) onStatusUpdate;
  final Function(ApiActivity) isUpdating;
  final String Function(ApiActivity) effectiveStatus;

  const ActivitiesDayActivitiesList({
    super.key,
    required this.day,
    required this.dayActivities,
    required this.onStatusUpdate,
    required this.isUpdating,
    required this.effectiveStatus,
  });

  @override
  Widget build(BuildContext context) {
    final longDate = DateFormat('EEEE d MMMM yyyy', 'fr');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ActivitiesTheme.surfaceDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ActivitiesTheme.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: ActivitiesTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  longDate.format(day).toUpperCase(),
                  style: TextStyle(
                    fontFamily: TeacherTheme.fontName,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: ActivitiesTheme.primaryBlue,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (dayActivities.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.event_busy,
                      color: TeacherTheme.mutedText,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Aucune activité prévue r',
                      style: TextStyle(
                        fontFamily: TeacherTheme.fontName,
                        color: TeacherTheme.mutedText,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...dayActivities.map((a) => _buildActivityItem(a)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(ApiActivity a) {
    final status = effectiveStatus(a);
    final isPending = isUpdating(a);

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final activityDate = DateTime(a.date.year, a.date.month, a.date.day);
    final canExecute = !activityDate.isAfter(todayDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TeacherTheme.baseDark.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ActivitiesTheme.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  a.title,
                  style: TextStyle(
                    fontFamily: TeacherTheme.fontName,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: TeacherTheme.lightText,
                  ),
                ),
              ),
              if (isPending)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          if (a.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              a.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: TeacherTheme.fontName,
                fontSize: 12,
                color: TeacherTheme.mutedText,
              ),
            ),
          ],
          const SizedBox(height: 10),
          if (a.timeLabel.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: TeacherTheme.mutedText,
                ),
                const SizedBox(width: 4),
                Text(
                  a.timeLabel,
                  style: TextStyle(
                    fontFamily: TeacherTheme.fontName,
                    fontSize: 11,
                    color: TeacherTheme.mutedText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ] else
            const SizedBox(height: 2),
          // is pending means the activity is not executed yet
          if (!isPending && canExecute)
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => onStatusUpdate(a, 'not_executed'),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: status == 'not_executed'
                            ? ActivitiesTheme.statusNotExecuted.withValues(
                                alpha: 0.15,
                              )
                            : TeacherTheme.surfaceDark.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: status == 'not_executed'
                              ? ActivitiesTheme.statusNotExecuted.withValues(
                                  alpha: 0.5,
                                )
                              : ActivitiesTheme.glassBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cancel,
                            size: 14,
                            color: status == 'not_executed'
                                ? ActivitiesTheme.statusNotExecuted
                                : TeacherTheme.mutedText,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Non exécutée',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: status == 'not_executed'
                                    ? ActivitiesTheme.statusNotExecuted
                                    : TeacherTheme.mutedText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => onStatusUpdate(a, 'executed'),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: status == 'executed'
                            ? ActivitiesTheme.statusExecuted.withValues(
                                alpha: 0.15,
                              )
                            : TeacherTheme.surfaceDark.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: status == 'executed'
                              ? ActivitiesTheme.statusExecuted.withValues(
                                  alpha: 0.5,
                                )
                              : ActivitiesTheme.glassBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: status == 'executed'
                                ? ActivitiesTheme.statusExecuted
                                : TeacherTheme.mutedText,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Exécutée',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: status == 'executed'
                                    ? ActivitiesTheme.statusExecuted
                                    : TeacherTheme.mutedText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
