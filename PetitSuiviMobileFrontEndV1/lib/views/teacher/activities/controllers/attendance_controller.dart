import 'package:flutter/material.dart';
import 'package:newv/models/teacher_models.dart';

class AttendanceController extends ChangeNotifier {
  DateTime selectedDate = DateTime.now();
  ClassRoom? selectedClass;
  
  // childId -> isPresent for the current session
  Map<String, bool> attendance = {};
  
  List<ClassRoom> classes = [];
  final List<AttendanceRecord> attendanceRecords = [];

  bool loadingClasses = false;
  String? classesError;

  void setSelectedDate(DateTime date) {
    selectedDate = date;
    loadAttendance();
    notifyListeners();
  }

  void setClasses(List<ClassRoom> newClasses) {
    classes = newClasses;
    if (classes.isNotEmpty && selectedClass == null) {
      selectedClass = classes.first;
      loadAttendance();
    }
    notifyListeners();
  }

  void selectClass(ClassRoom cls) {
    selectedClass = cls;
    loadAttendance();
    notifyListeners();
  }

  void loadAttendance() {
    if (selectedClass == null) return;
    attendance = {};
    for (var child in selectedClass!.children) {
      final existing = attendanceRecords.where(
        (r) =>
            r.childId == child.id &&
            r.date.year == selectedDate.year &&
            r.date.month == selectedDate.month &&
            r.date.day == selectedDate.day,
      ).toList();
      
      if (existing.isNotEmpty) {
        attendance[child.id] = existing.first.isPresent;
      } else {
        attendance[child.id] = true; // default present
      }
    }
  }

  void toggleAttendance(String childId) {
    attendance[childId] = !(attendance[childId] ?? true);
    notifyListeners();
  }

  Future<void> saveAttendance(BuildContext context) async {
    if (selectedClass == null) return;
    
    // Simulation: Remove existing records for this class + date
    attendanceRecords.removeWhere((r) {
      final sameDate =
          r.date.year == selectedDate.year &&
          r.date.month == selectedDate.month &&
          r.date.day == selectedDate.day;
      final inClass = selectedClass!.children.any((c) => c.id == r.childId);
      return sameDate && inClass;
    });

    // Simulation: Add new records
    for (var entry in attendance.entries) {
      attendanceRecords.add(
        AttendanceRecord(
          childId: entry.key,
          date: DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
          ),
          isPresent: entry.value,
        ),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Présence enregistrée avec succès !',
          style: TextStyle(fontFamily: 'Outfit'),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    notifyListeners();
  }

  int get presentCount => attendance.values.where((v) => v).length;
  int get absentCount => attendance.values.where((v) => !v).length;
}
