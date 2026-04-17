import 'package:flutter/material.dart';
import 'package:newv/views/teacher/teacher_theme.dart';
import 'package:newv/views/teacher/activities/themes/activities_theme.dart';
import 'package:newv/views/teacher/activities/apis/activities_api.dart';

class ActivitiesDayGridView extends StatelessWidget {
  final int year;
  final int month;
  final DateTime? selectedDay;
  final Map<String, List<ApiActivity>> activityByDay;
  final Function(DateTime) onDaySelected;

  const ActivitiesDayGridView({
    super.key,
    required this.year,
    required this.month,
    required this.selectedDay,
    required this.activityByDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstDayOffset = DateTime(year, month, 1).weekday - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ActivitiesTheme.weekdaysFr
                .map((d) => Text(
                      d,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: TeacherTheme.mutedText,
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: daysInMonth + firstDayOffset,
            itemBuilder: (context, index) {
              if (index < firstDayOffset) return const SizedBox.shrink();
              final dayNum = index - firstDayOffset + 1;
              final dayDate = DateTime(year, month, dayNum);
              final key = '${dayDate.year}-${dayDate.month.toString().padLeft(2, '0')}-${dayDate.day.toString().padLeft(2, '0')}';
              
              final acts = activityByDay[key] ?? [];
              final isSelected = selectedDay != null &&
                  selectedDay!.day == dayNum &&
                  selectedDay!.month == month &&
                  selectedDay!.year == year;
              
              final isToday = DateTime.now().year == year &&
                  DateTime.now().month == month &&
                  DateTime.now().day == dayNum;

              return GestureDetector(
                onTap: () => onDaySelected(dayDate),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ActivitiesTheme.primaryBlue
                        : isToday
                            ? ActivitiesTheme.primaryBlue.withValues(alpha: 0.1)
                            : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isToday && !isSelected
                        ? Border.all(color: ActivitiesTheme.primaryBlue, width: 1)
                        : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '$dayNum',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? TeacherTheme.baseDark
                              : isToday
                                  ? ActivitiesTheme.primaryBlue
                                  : TeacherTheme.lightText,
                        ),
                      ),
                      if (acts.isNotEmpty && !isSelected)
                        Positioned(
                          bottom: 4,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Colors.orangeAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
