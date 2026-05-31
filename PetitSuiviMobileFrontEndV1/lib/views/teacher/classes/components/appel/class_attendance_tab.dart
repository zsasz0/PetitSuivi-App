import 'package:provider/provider.dart';
import 'package:newv/views/themes/theme_manager.dart';
import 'package:newv/views/themes/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:newv/models/teacher_models.dart';
import 'package:newv/views/teacher/classes/themes/teacher_classes_theme.dart';

/// A UI component displaying a date selector, attendance statistics, and a list of students with toggleable presence.
class ClassAttendanceTab extends StatelessWidget {
  final ClassRoom classroom;
  final DateTime selectedDate;
  final Future<void> Function() onPickDate;
  final Map<String, bool> attendance;
  final void Function(String childId) onToggleAttendance;
  final int presentCount;
  final int absentCount;
  final bool isBusy;
  final String? errorMessage;
  final Future<void> Function()? onRetry;

  const ClassAttendanceTab({
    super.key,
    required this.classroom,
    required this.selectedDate,
    required this.onPickDate,
    required this.attendance,
    required this.onToggleAttendance,
    required this.presentCount,
    required this.absentCount,
    this.isBusy = false,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    const months = [
      '',
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    const days = [
      '',
      'lundi',
      'mardi',
      'mercredi',
      'jeudi',
      'vendredi',
      'samedi',
      'dimanche',
    ];
    final dayName = days[selectedDate.weekday];
    final formattedDate =
        '$dayName ${selectedDate.day} ${months[selectedDate.month]} ${selectedDate.year}';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onPickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: TeacherClassesTheme.surfaceCard(borderRadius: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: TeacherClassesTheme.tealAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontFamily: TeacherClassesTheme.fontName,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: TeacherClassesTheme.lightText,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_drop_down,
                    color: TeacherClassesTheme.mutedText.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _statChip(
                Icons.people,
                'Total',
                '${attendance.length}',
                TeacherClassesTheme.indigoAccent,
              ),
              const SizedBox(width: 10),
              _statChip(
                Icons.check_circle,
                'Présents',
                '$presentCount',
                Colors.greenAccent,
              ),
              const SizedBox(width: 10),
              _statChip(
                Icons.cancel,
                'Absents',
                '$absentCount',
                Colors.redAccent,
              ),
            ],
          ),
        ),
        if (isBusy)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LinearProgressIndicator(
              minHeight: 2,
              color: TeacherClassesTheme.tealAccent,
            ),
          ),
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
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
                      errorMessage!,
                      style: TextStyle(
                        fontFamily: TeacherClassesTheme.fontName,
                        color: Colors.redAccent,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (onRetry != null)
                    TextButton(
                      onPressed: isBusy ? null : onRetry,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                      ),
                      child: const Text('Réessayer'),
                    ),
                ],
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: classroom.children.length,
            itemBuilder: (context, index) {
              final child = classroom.children[index];
              final isPresent = attendance[child.id] ?? true;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: TeacherClassesTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeColors.shadow,
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ],
                  border: Border.all(
                    color: isPresent
                        ? Colors.greenAccent.withValues(alpha: 0.3)
                        : Colors.redAccent.withValues(alpha: 0.3),
                    width: 1.2,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap:
                        (isBusy ||
                            selectedDate.year != DateTime.now().year ||
                            selectedDate.month != DateTime.now().month ||
                            selectedDate.day != DateTime.now().day)
                        ? null
                        : () => onToggleAttendance(child.id),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: isPresent
                                ? Colors.greenAccent.withValues(alpha: 0.1)
                                : Colors.redAccent.withValues(alpha: 0.1),
                            child: Text(
                              '${child.firstName[0]}${child.lastName[0]}',
                              style: TextStyle(
                                fontFamily: TeacherClassesTheme.fontName,
                                fontWeight: FontWeight.bold,
                                color: isPresent
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  child.fullName,
                                  style: TextStyle(
                                    fontFamily: TeacherClassesTheme.fontName,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: TeacherClassesTheme.lightText,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${child.age} ans',
                                  style: TextStyle(
                                    fontFamily: TeacherClassesTheme.fontName,
                                    fontSize: 12,
                                    color: TeacherClassesTheme.mutedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isPresent
                                  ? Colors.greenAccent.withValues(alpha: 0.12)
                                  : Colors.redAccent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isPresent ? Icons.check_circle : Icons.cancel,
                                  size: 18,
                                  color: isPresent
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isPresent ? 'Présent' : 'Absent',
                                  style: TextStyle(
                                    fontFamily: TeacherClassesTheme.fontName,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isPresent
                                        ? Colors.greenAccent
                                        : Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _statChip(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontFamily: TeacherClassesTheme.fontName,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: TeacherClassesTheme.fontName,
                fontSize: 11,
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
