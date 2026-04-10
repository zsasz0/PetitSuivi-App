import 'package:newv/theme_manager.dart';
import 'package:newv/utils/api_constants.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/models/teacher_models.dart';
import 'package:newv/utils/unauthorized_handler.dart';
import 'package:newv/views/teacher/classes/class_detail_page.dart';
import 'package:newv/views/teacher/classes/listOfclasses/classes_list_section.dart';
import 'package:newv/views/teacher/teacher_theme.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

/// File: manage_classes_page.dart
/// Purpose: Entry point for teacher's classroom management, listing all assigned classes.
/// Usage: Navigated from the teacher dashboard.
/// API Usage:
///   - GET /api/teachers/{cin}/classes/by-planning
///     Fetches classrooms assigned to the logged-in teacher for the current planning year.
/// Dependencies: AuthSession, ClassDetailPage, ClassesListSection, TeacherTheme.

/// A page that fetches and displays a list of classes assigned to the logged-in teacher.
class ManageClassesPage extends StatefulWidget {
  const ManageClassesPage({super.key});

  @override
  State<ManageClassesPage> createState() => _ManageClassesPageState();
}

class _ManageClassesPageState extends State<ManageClassesPage> {
  static const String _apiBaseUrl = ApiConstants.baseUrl;

  // ===========================================================================
  // STATE VARIABLES
  // ===========================================================================
  bool _isLoading = true;
  String? _error;
  List<ClassRoom> _classrooms = [];

  // ===========================================================================
  // INIT & DISPOSE
  // ===========================================================================
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTeacherClasses());
  }

  // ===========================================================================
  // DATA FETCHING & MAPPING
  // ===========================================================================

  /// Fetches classes from the backend using the teacher's CIN and session token.
  Future<void> _loadTeacherClasses() async {
    final session = context.read<AuthSession>();
    final token = session.token;
    final teacherCin = session.cin;

    if (token == null || token.isEmpty || teacherCin == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Session enseignant introuvable. Reconnectez-vous.';
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final uri = Uri.parse(
      '$_apiBaseUrl/api/teachers/$teacherCin/classes/by-planning',
    );

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;
      if (UnauthorizedHandler.handle(
        context: context,
        statusCode: response.statusCode,
      )) {
        return;
      }

      final body = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          body['data'] is List) {
        final String? pStartStr = body['planning_start']?.toString();
        final String? pEndStr = body['planning_end']?.toString();
        final DateTime? pStart = pStartStr != null
            ? DateTime.tryParse(pStartStr)
            : null;
        final DateTime? pEnd = pEndStr != null
            ? DateTime.tryParse(pEndStr)
            : null;

        final classrooms = (body['data'] as List)
            .whereType<Map>()
            .map(
              (item) => ClassMapper.mapClassroom(
                item.cast<String, dynamic>(),
                pStart,
                pEnd,
              ),
            )
            .toList();

        setState(() {
          _classrooms = classrooms;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _error =
              body['message']?.toString() ??
              'Impossible de charger les classes.';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Erreur réseau. Vérifiez la connexion à l\'API.';
      });
    }
  }

  // ===========================================================================
  // UI BUILDING
  // ===========================================================================
  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return Scaffold(
      backgroundColor: TeacherTheme.baseDark,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Gérer les Classes',
        style: TextStyle(
          fontFamily: TeacherTheme.fontName,
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: TeacherTheme.lightText,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Navigator.canPop(context)
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: TeacherTheme.lightText,
              ),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      automaticallyImplyLeading: false,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: TeacherTheme.tealAccent),
      );
    }

    if (_error != null) {
      return _buildErrorView();
    }

    return ClassesListSection(
      classrooms: _classrooms,
      onOpenClass: (classroom) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClassDetailPage(classroom: classroom),
          ),
        );
      },
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: TeacherTheme.fontName,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: TeacherTheme.tealAccent,
                foregroundColor: TeacherTheme.baseDark,
              ),
              onPressed: _loadTeacherClasses,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// HELPER CLASSES
// ===========================================================================

/// A helper class to map raw JSON data into Classroom models.
class ClassMapper {
  static ClassRoom mapClassroom(
    Map<String, dynamic> json, [
    DateTime? pStart,
    DateTime? pEnd,
  ]) {
    final classId = json['id']?.toString() ?? '';
    final rawStudents = (json['students'] is List)
        ? json['students'] as List
        : const [];

    final children = rawStudents.whereType<Map>().map((item) {
      final child = item.cast<String, dynamic>();
      final rawFirst = child['first_name']?.toString() ?? child['firstName']?.toString() ?? '';
      final rawLast = child['last_name']?.toString() ?? child['lastName']?.toString() ?? '';
      
      return MockChild(
        id: child['id']?.toString() ?? '',
        firstName: rawFirst.trim().isEmpty ? 'U' : rawFirst.trim(),
        lastName: rawLast.trim().isEmpty ? 'U' : rawLast.trim(),
        age: _calculateAge(child['birthdate']?.toString()),
        classId: classId,
      );
    }).toList();

    return ClassRoom(
      id: classId,
      name: json['name']?.toString() ?? 'Classe',
      children: children,
      planningStartDate: pStart,
      planningEndDate: pEnd,
    );
  }

  static int _calculateAge(String? birthDateString) {
    if (birthDateString == null || birthDateString.isEmpty) return 0;
    try {
      final birthDate = DateTime.parse(birthDateString);
      final today = DateTime.now();
      var age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age < 0 ? 0 : age;
    } catch (_) {
      return 0;
    }
  }
}
