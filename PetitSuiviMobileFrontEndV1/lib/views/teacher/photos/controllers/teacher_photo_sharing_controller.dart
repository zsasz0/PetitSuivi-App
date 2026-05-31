import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/services/photo_service.dart';
import 'package:newv/views/teacher/photos/apis/teacher_photo_sharing_apis.dart';
import 'package:provider/provider.dart';

class TeacherPhotoSharingController {
  final BuildContext context;
  final Function(VoidCallback) setState;

  TeacherPhotoSharingController({
    required this.context,
    required this.setState,
  });

  final PhotoService _photoService = PhotoService();

  List<Map<String, dynamic>> classes = [];
  String? selectedClassId;
  List<Map<String, dynamic>> classChildren = [];
  Set<int> selectedChildIds = {};

  String? pickedImagePath;
  int selectedExpirationDays = 30;

  List<dynamic> recentPhotos = [];

  bool isLoadingClasses = true;
  bool isLoadingChildren = false;
  bool isSending = false;
  bool isLoadingRecent = false;
  String? error;

  AuthSession get _session => context.read<AuthSession>();
  String? get _token => _session.token;
  int? get _cin => _session.cin;

  bool get mounted => (context as dynamic).mounted ?? true;

  Future<void> init() async {
    await loadClasses();
    await loadRecentPhotos();
  }

  Map<String, dynamic> _normalizeChild(Map<String, dynamic> rawChild) {
    return {
      'id': rawChild['id'],
      'firstName': rawChild['firstName'] ?? rawChild['first_name'] ?? '',
      'lastName': rawChild['lastName'] ?? rawChild['last_name'] ?? '',
      'birthdate': rawChild['birthdate'],
    };
  }

  Future<void> loadClasses({bool isRefresh = false}) async {
    if (_token == null || _cin == null) return;

    if (!isRefresh) {
      setState(() {
        isLoadingClasses = true;
        error = null;
      });
    } else {
      setState(() {
        error = null;
      });
    }

    try {
      final response = await TeacherPhotoSharingApis.getTeacherClasses(
        _cin!,
        _token!,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final data = body['data'] as List? ?? [];
        setState(() {
          classes = data.cast<Map<String, dynamic>>();
          isLoadingClasses = false;
          if (classes.isNotEmpty && selectedClassId == null) {
            selectedClassId = classes.first['id'].toString();
            loadChildrenForClass(selectedClassId!);
          }
        });
      } else {
        setState(() {
          isLoadingClasses = false;
          error = 'Erreur lors du chargement des classes.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoadingClasses = false;
        error = 'Erreur réseau.';
      });
    }
  }

  Future<void> loadChildrenForClass(String classId) async {
    if (_token == null) return;

    setState(() {
      isLoadingChildren = true;
      classChildren = [];
      selectedChildIds = {};
    });

    try {
      final response = await TeacherPhotoSharingApis.getClassStudents(
        classId,
        _token!,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final dataMap = body['data'] as Map<String, dynamic>? ?? {};
        final students = dataMap['students'] as List? ?? [];
        final normalizedChildren = students
            .whereType<Map>()
            .where((child) {
              bool isArchived =
                  child['is_archived'] == true ||
                  child['is_archived'] == 1 ||
                  child['isArchived'] == true ||
                  child['isArchived'] == 1;

              final inscriptions = child['inscriptions'];
              if (inscriptions is List && inscriptions.isNotEmpty) {
                final lastInscription = inscriptions.last;
                if (lastInscription is Map) {
                  isArchived =
                      isArchived ||
                      lastInscription['is_archived'] == true ||
                      lastInscription['is_archived'] == 1 ||
                      lastInscription['isArchived'] == true ||
                      lastInscription['isArchived'] == 1;
                }
              }

              return !isArchived;
            })
            .map((child) => _normalizeChild(child.cast<String, dynamic>()))
            .toList();
        setState(() {
          classChildren = normalizedChildren;
          selectedChildIds = classChildren
              .map<int>((c) => int.tryParse(c['id'].toString()) ?? 0)
              .where((id) => id > 0)
              .toSet();
          isLoadingChildren = false;
        });
      } else {
        setState(() => isLoadingChildren = false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoadingChildren = false);
    }
  }

  Future<void> loadRecentPhotos({bool isRefresh = false}) async {
    if (_cin == null || _token == null) return;

    if (!isRefresh) {
      setState(() => isLoadingRecent = true);
    }

    try {
      final photos = await _photoService.getTeacherPhotos(_cin!, _token!);
      if (!mounted) return;
      setState(() {
        recentPhotos = photos;
        isLoadingRecent = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoadingRecent = false);
    }
  }

  Future<void> refreshData() async {
    await Future.wait([
      loadClasses(isRefresh: true),
      loadRecentPhotos(isRefresh: true),
    ]);
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1600,
    );
    if (file == null) return;
    setState(() {
      pickedImagePath = file.path;
    });
  }

  Future<void> sendPhoto() async {
    if (pickedImagePath == null) {
      showSnack('Veuillez sélectionner une photo.');
      return;
    }
    if (selectedChildIds.isEmpty) {
      showSnack('Sélectionnez au moins un enfant.');
      return;
    }

    if (_cin == null || _token == null) return;

    setState(() => isSending = true);

    try {
      await _photoService.uploadPhoto(
        photo: File(pickedImagePath!),
        teacherId: _cin!,
        childIds: selectedChildIds.toList(),
        token: _token!,
        expiresInDays: selectedExpirationDays,
      );

      if (!mounted) return;
      setState(() {
        pickedImagePath = null;
        isSending = false;
      });
      showSnack(
        'Photo envoyée à ${selectedChildIds.length} enfant(s).',
        isSuccess: true,
      );
      loadRecentPhotos();
    } catch (e) {
      if (!mounted) return;
      setState(() => isSending = false);
      showSnack('Erreur: ${e.toString()}');
    }
  }

  Future<void> deletePhoto(int photoId) async {
    if (_token == null) return;

    try {
      await _photoService.deletePhoto(photoId, _token!);
      if (!mounted) return;
      showSnack('Photo supprimée.', isSuccess: true);
      loadRecentPhotos();
    } catch (_) {
      showSnack('Erreur lors de la suppression.');
    }
  }

  void toggleSelectAll() {
    setState(() {
      if (selectedChildIds.length == classChildren.length) {
        selectedChildIds = {};
      } else {
        selectedChildIds = classChildren
            .map<int>((c) => int.tryParse(c['id'].toString()) ?? 0)
            .where((id) => id > 0)
            .toSet();
      }
    });
  }

  void showSnack(String message, {bool isSuccess = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.redAccent,
      ),
    );
  }
}
