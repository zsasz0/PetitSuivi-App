import 'package:flutter/foundation.dart';

/// Manages the state for the current user's profile photo across different roles.
///
/// This provides a reactive way to update and retrieve the file paths for
/// both parent and teacher profile images.
class UserProfile extends ChangeNotifier {
  String? _parentPhotoPath;
  String? _teacherPhotoPath;

  /// Returns the local file path for the parent's profile photo.
  String? get parentPhotoPath => _parentPhotoPath;

  /// Returns the local file path for the teacher's profile photo.
  String? get teacherPhotoPath => _teacherPhotoPath;

  /// Updates the parent's photo path and notifies listeners.
  void setParentPhotoPath(String? path) {
    _parentPhotoPath = path;
    notifyListeners();
  }

  /// Updates the teacher's photo path and notifies listeners.
  void setTeacherPhotoPath(String? path) {
    _teacherPhotoPath = path;
    notifyListeners();
  }
}
