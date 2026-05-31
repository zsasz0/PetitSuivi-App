import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/models/teacher_models.dart';
import 'package:newv/views/themes/theme_manager.dart';
import 'package:newv/views/teacher/classes/components/appel/class_attendance_tab.dart';
import 'package:newv/views/teacher/classes/components/evaluation/class_evaluation_tab.dart';
import 'package:newv/views/teacher/classes/controllers/class_detail_controller.dart';
import 'package:newv/views/teacher/classes/themes/teacher_classes_theme.dart';

/// A tabbed page managing child attendance and skill evaluations for a specific classroom.
class ClassDetailPage extends StatefulWidget {
  final ClassRoom classroom;

  const ClassDetailPage({super.key, required this.classroom});

  @override
  State<ClassDetailPage> createState() => _ClassDetailPageState();
}

class _ClassDetailPageState extends State<ClassDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ClassDetailController _controller = ClassDetailController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _loadData();
  }

  Future<void> _loadData() async {
    final session = context.read<AuthSession>();
    await _controller.loadAttendance(
      context: context,
      classroom: widget.classroom,
      token: session.token,
      setState: setState,
      isMounted: () => mounted,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    final session = context.read<AuthSession>();

    return Scaffold(
      backgroundColor: TeacherClassesTheme.baseDark,
      appBar: AppBar(
        title: Text(
          widget.classroom.name,
          style: TextStyle(
            fontFamily: TeacherClassesTheme.fontName,
            fontWeight: FontWeight.bold,
            color: TeacherClassesTheme.lightText,
            fontSize: 18,
          ),
        ),
        backgroundColor: TeacherClassesTheme.surfaceDark,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: TeacherClassesTheme.lightText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: TeacherClassesTheme.tealAccent,
          unselectedLabelColor: TeacherClassesTheme.mutedText,
          indicatorColor: TeacherClassesTheme.tealAccent,
          labelStyle: TeacherClassesTheme.tabLabelStyle,
          tabs: const [
            Tab(icon: Icon(Icons.fact_check), text: 'Appel'),
            Tab(icon: Icon(Icons.assessment), text: 'Évaluation'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ClassAttendanceTab(
            classroom: widget.classroom,
            selectedDate: _controller.selectedDate,
            onPickDate: () => _controller.pickDate(
              context: context,
              classroom: widget.classroom,
              token: session.token,
              setState: setState,
              isMounted: () => mounted,
            ),
            attendance: _controller.attendance,
            onToggleAttendance: (childId) =>
                _controller.toggleAttendance(childId, context, setState),
            presentCount: _controller.getPresentCount(),
            absentCount: _controller.getAbsentCount(),
            isBusy:
                _controller.isLoadingAttendance ||
                _controller.isSavingAttendance,
            errorMessage: _controller.attendanceError,
            onRetry: _loadData,
          ),
          ClassEvaluationTab(
            classId: int.tryParse(widget.classroom.id) ?? 0,
            selectedDate: _controller.selectedDate,
            onPickDate: () => _controller.pickDate(
              context: context,
              classroom: widget.classroom,
              token: session.token,
              setState: setState,
              isMounted: () => mounted,
            ),
            token: session.token ?? '',
            teacherCin: session.cin ?? 0,
          ),
        ],
      ),
      floatingActionButton:
          _tabController.index == 0 &&
              _controller.selectedDate.year == DateTime.now().year &&
              _controller.selectedDate.month == DateTime.now().month &&
              _controller.selectedDate.day == DateTime.now().day
          ? FloatingActionButton.extended(
              onPressed: () => _controller.saveAttendance(
                context: context,
                classroom: widget.classroom,
                token: session.token,
                setState: setState,
                isMounted: () => mounted,
              ),
              backgroundColor: TeacherClassesTheme.tealAccent,
              foregroundColor: TeacherClassesTheme.baseDark,
              icon: const Icon(Icons.save),
              label: const Text(
                'Enregistrer',
                style: TextStyle(
                  fontFamily: TeacherClassesTheme.fontName,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }
}
