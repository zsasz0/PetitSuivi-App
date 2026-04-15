/// attendance_page.dart
///
/// Interface for teachers to record daily student attendance by toggling
/// each child's presence or absence for a selected class and date.
///
/// ## State Management
/// - [_AttendancePageState] manages the selected date, selected class,
///   and attendance map (`childId → isPresent`).
/// - Currently operates in **simulation mode** — attendance records are saved
///   locally in-memory only. No persistent backend calls are made yet.
///
/// ## Backend API Endpoints (Planned)
///
/// ### POST /api/classes/{classId}/presences
/// Will persist attendance records to the backend.
/// - **Route (existing):** registered in `api.php` → `ClassAttendanceController@store`
/// - **Body:**
/// ```json
/// {
///   "date": "2026-03-05",
///   "presences": [
///     { "child_id": 8, "status": "present" },
///     { "child_id": 9, "status": "absent" }
///   ]
/// }
/// ```
///
/// ## Dependencies
/// [TeacherTheme], [AppTheme], [ClassRoom], [AttendanceRecord], [ThemeManager].
library;

import 'package:flutter/material.dart';
import 'package:newv/app_theme.dart';
import 'package:newv/models/teacher_models.dart';
import 'package:newv/theme_colors.dart';
import 'package:newv/theme_manager.dart';
import 'package:newv/views/teacher/teacher_theme.dart';
import 'package:provider/provider.dart';
class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  late DateTime _selectedDate;
  ClassRoom? _selectedClass;
  // childId -> isPresent for the current session
  Map<String, bool> _attendance = {};

  final List<ClassRoom> _classes = [];
  final List<AttendanceRecord> _attendanceRecords = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    if (_classes.isNotEmpty) {
      _selectedClass = _classes.first;
      _loadAttendance();
    }
  }

  void _loadAttendance() {
    if (_selectedClass == null) return;
    _attendance = {};
    for (var child in _selectedClass!.children) {
      // Check if there's an existing record
      final existing = _attendanceRecords
          .where(
            (r) =>
                r.childId == child.id &&
                r.date.year == _selectedDate.year &&
                r.date.month == _selectedDate.month &&
                r.date.day == _selectedDate.day,
          )
          .toList();
      if (existing.isNotEmpty) {
        _attendance[child.id] = existing.first.isPresent;
      } else {
        _attendance[child.id] = true; // default present
      }
    }
    setState(() {});
  }

  void _toggleAttendance(String childId) {
    setState(() {
      _attendance[childId] = !(_attendance[childId] ?? true);
    });
  }

  void _saveAttendance() {
    if (_selectedClass == null) return;
    // Remove existing records for this class + date
    _attendanceRecords.removeWhere((r) {
      final sameDate =
          r.date.year == _selectedDate.year &&
          r.date.month == _selectedDate.month &&
          r.date.day == _selectedDate.day;
      final inClass = _selectedClass!.children.any((c) => c.id == r.childId);
      return sameDate && inClass;
    });
    // Add new records
    for (var entry in _attendance.entries) {
      _attendanceRecords.add(
        AttendanceRecord(
          childId: entry.key,
          date: DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
          ),
          isPresent: entry.value,
        ),
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Présence enregistrée avec succès !',
          style: TextStyle(fontFamily: TeacherTheme.fontName),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: TeacherTheme.tealAccent,
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
      setState(() {
        _selectedDate = picked;
      });
      _loadAttendance();
    }
  }

  int get _presentCount => _attendance.values.where((v) => v).length;
  int get _absentCount => _attendance.values.where((v) => !v).length;

  @override
  Widget build(BuildContext context) {
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
          // Class selector chips
          _buildClassSelector(),
          // Date row
          _buildDateRow(),
          // Stats banner
          if (_selectedClass != null) _buildStatsBanner(),
          const SizedBox(height: 4),
          // Children list
          if (_selectedClass != null)
            Expanded(child: _buildChildrenList())
          else
            Expanded(
              child: Center(
                child: Text(
                  'Aucune classe disponible',
                  style: TextStyle(
                    fontFamily: TeacherTheme.fontName,
                    fontSize: 16,
                    color: TeacherTheme.mutedText,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _selectedClass != null
          ? FloatingActionButton.extended(
              onPressed: _saveAttendance,
              backgroundColor: TeacherTheme.tealAccent,
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
  }

  Widget _buildClassSelector() {
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _classes.length,
        itemBuilder: (context, index) {
          final classroom = _classes[index];
          final isSelected = _selectedClass?.id == classroom.id;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                classroom.name,
                style: TextStyle(
                  fontFamily: TeacherTheme.fontName,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? TeacherTheme.baseDark
                      : TeacherTheme.lightText,
                ),
              ),
              selected: isSelected,
              selectedColor: TeacherTheme.tealAccent,
              backgroundColor: TeacherTheme.surfaceDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? TeacherTheme.tealAccent
                      : ThemeColors.glassBorder,
                ),
              ),
              onSelected: (_) {
                setState(() {
                  _selectedClass = classroom;
                });
                _loadAttendance();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateRow() {
    final months = [
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
    final days = [
      '',
      'lundi',
      'mardi',
      'mercredi',
      'jeudi',
      'vendredi',
      'samedi',
      'dimanche',
    ];
    final dayName = days[_selectedDate.weekday];
    final formattedDate =
        '$dayName ${_selectedDate.day} ${months[_selectedDate.month]} ${_selectedDate.year}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _pickDate,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: TeacherTheme.surfaceCard(borderRadius: 12),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: TeacherTheme.tealAccent,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                formattedDate,
                style: TextStyle(
                  fontFamily: TeacherTheme.fontName,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: TeacherTheme.lightText,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_drop_down,
                color: TeacherTheme.mutedText.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsBanner() {
    final total = _attendance.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _statChip(
            icon: Icons.people,
            label: 'Total',
            value: '$total',
            color: TeacherTheme.tealAccent,
          ),
          const SizedBox(width: 10),
          _statChip(
            icon: Icons.check_circle,
            label: 'Présents',
            value: '$_presentCount',
            color: Colors.green,
          ),
          const SizedBox(width: 10),
          _statChip(
            icon: Icons.cancel,
            label: 'Absents',
            value: '$_absentCount',
            color: Colors.redAccent,
          ),
        ],
      ),
    );
  }

  Widget _statChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontFamily: TeacherTheme.fontName,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: TeacherTheme.fontName,
                fontSize: 11,
                color: color.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildrenList() {
    final children = _selectedClass!.children;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: children.length,
      itemBuilder: (context, index) {
        final child = children[index];
        final isPresent = _attendance[child.id] ?? true;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: TeacherTheme.surfaceCard(borderRadius: 14).copyWith(
            border: Border.all(
              color: isPresent
                  ? Colors.green.withValues(alpha: 0.3)
                  : Colors.redAccent.withValues(alpha: 0.3),
              width: 1.2,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _toggleAttendance(child.id),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: isPresent
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.redAccent.withValues(alpha: 0.1),
                      child: Text(
                        '${child.firstName[0]}${child.lastName[0]}',
                        style: TextStyle(
                          fontFamily: TeacherTheme.fontName,
                          fontWeight: FontWeight.bold,
                          color: isPresent ? Colors.green : Colors.redAccent,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            child.fullName,
                            style: TextStyle(
                              fontFamily: TeacherTheme.fontName,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: TeacherTheme.lightText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${child.age} ans',
                            style: TextStyle(
                              fontFamily: TeacherTheme.fontName,
                              fontSize: 12,
                              color: TeacherTheme.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status chip
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isPresent
                            ? Colors.green.withValues(alpha: 0.12)
                            : Colors.redAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPresent ? Icons.check_circle : Icons.cancel,
                            size: 18,
                            color: isPresent ? Colors.green : Colors.redAccent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isPresent ? 'Présent' : 'Absent',
                            style: TextStyle(
                              fontFamily: TeacherTheme.fontName,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isPresent
                                  ? Colors.green
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
    );
  }
}
