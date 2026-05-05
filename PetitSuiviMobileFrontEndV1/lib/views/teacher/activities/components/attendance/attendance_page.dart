import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:newv/views/themes/theme_manager.dart';
import 'package:newv/views/teacher/teacher_theme.dart';
import 'package:newv/views/teacher/activities/controllers/attendance_controller.dart';
import 'package:newv/views/teacher/activities/components/common/activities_class_selector.dart';
import 'package:newv/views/teacher/activities/components/attendance/attendance_date_row.dart';
import 'package:newv/views/teacher/activities/components/attendance/attendance_stats_banner.dart';
import 'package:newv/views/teacher/activities/components/attendance/attendance_child_item.dart';
import 'package:newv/views/teacher/activities/themes/activities_theme.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  late AttendanceController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AttendanceController();
    // In a real app, classes would be loaded from an API.
    // Here we'll need to pass classes if they are already available in parent or load them.
    // For now, I'll keep it as it was if possible, but the original file had an empty list.
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _controller.selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: ActivitiesTheme.primaryBlue,
              onPrimary: TeacherTheme.baseDark,
              surface: TeacherTheme.surfaceDark,
              onSurface: TeacherTheme.lightText,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _controller.setSelectedDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AttendanceController>.value(
      value: _controller,
      child: Consumer<AttendanceController>(
        builder: (context, controller, child) {
          context.watch<ThemeManager>();
          
          return Scaffold(
            backgroundColor: TeacherTheme.baseDark,
            appBar: AppBar(
              title: Text(
                'Appel / Présence',
                style: TextStyle(
                  fontFamily: TeacherTheme.fontName,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: TeacherTheme.lightText,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: TeacherTheme.lightText),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Column(
              children: [
                ActivitiesClassSelector(
                  classes: controller.classes,
                  selectedClass: controller.selectedClass,
                  isLoading: controller.loadingClasses,
                  error: controller.classesError,
                  onClassSelected: (cls) => controller.selectClass(cls),
                  onRefresh: () {}, // Not implemented in simulation
                ),
                AttendanceDateRow(
                  selectedDate: controller.selectedDate,
                  onTap: _pickDate,
                ),
                if (controller.selectedClass != null)
                  AttendanceStatsBanner(
                    total: controller.attendance.length,
                    presents: controller.presentCount,
                    absents: controller.absentCount,
                  ),
                const SizedBox(height: 4),
                Expanded(child: _buildChildrenList(controller)),
              ],
            ),
            floatingActionButton: controller.selectedClass != null
                ? FloatingActionButton.extended(
                    onPressed: () => controller.saveAttendance(context),
                    backgroundColor: ActivitiesTheme.primaryBlue,
                    icon: Icon(Icons.save, color: TeacherTheme.baseDark),
                    label: Text(
                      'Enregistrer',
                      style: TextStyle(
                        fontFamily: TeacherTheme.fontName,
                        fontWeight: FontWeight.w600,
                        color: TeacherTheme.baseDark,
                      ),
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }

  Widget _buildChildrenList(AttendanceController controller) {
    if (controller.selectedClass == null) {
      return Center(
        child: Text(
          'Aucune classe disponible',
          style: TextStyle(
            fontFamily: TeacherTheme.fontName,
            fontSize: 16,
            color: TeacherTheme.mutedText,
          ),
        ),
      );
    }

    final children = controller.selectedClass!.children;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: children.length,
      itemBuilder: (context, index) {
        final child = children[index];
        final isPresent = controller.attendance[child.id] ?? true;
        return AttendanceChildItem(
          child: child,
          isPresent: isPresent,
          onTap: () => controller.toggleAttendance(child.id),
        );
      },
    );
  }
}
