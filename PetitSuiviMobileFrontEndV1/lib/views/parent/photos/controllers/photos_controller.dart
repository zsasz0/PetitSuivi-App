import 'package:flutter/material.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/services/photo_service.dart';
import 'package:newv/views/parent/photos/apis/photos_api.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PhotosController {
  final AuthSession session;
  final PhotoService _photoService = PhotoService();

  List<Map<String, dynamic>> children = [];
  String? selectedChildId;
  bool isLoadingChildren = true;

  List<dynamic> photos = [];
  bool isLoadingPhotos = false;
  String? photoError;
  final Set<int> downloadingIds = {};

  PhotosController({required this.session});

  /// Loads children associated with the parent.
  Future<void> loadChildren({required Function() onUpdate}) async {
    final token = session.token;
    final cin = session.cin;
    if (token == null || cin == null) {
      isLoadingChildren = false;
      onUpdate();
      return;
    }

    try {
      isLoadingChildren = true;
      onUpdate();

      children = await PhotosApi.getApprovedChildren(cin: cin.toString(), token: token);
      
      if (children.isNotEmpty && selectedChildId == null) {
        selectedChildId = children.first['id'].toString();
        // Load initial photos
        await loadPhotos(int.parse(selectedChildId!), onUpdate: onUpdate);
      }
      
      isLoadingChildren = false;
      onUpdate();
    } catch (_) {
      isLoadingChildren = false;
      onUpdate();
    }
  }

  /// Selects a child and loads their photos.
  Future<void> selectChild(String? id, {required Function() onUpdate}) async {
    selectedChildId = id;
    if (id != null) {
      await loadPhotos(int.parse(id), onUpdate: onUpdate);
    } else {
      photos = [];
      onUpdate();
    }
  }

  /// Loads photos for a specific child.
  Future<void> loadPhotos(int childId, {required Function() onUpdate}) async {
    final token = session.token;
    if (token == null) return;

    isLoadingPhotos = true;
    photoError = null;
    onUpdate();

    try {
      photos = await _photoService.getChildPhotos(childId, token);
      isLoadingPhotos = false;
      onUpdate();
    } catch (e) {
      isLoadingPhotos = false;
      photoError = 'Erreur: ${e.toString()}';
      onUpdate();
    }
  }

  /// Refreshes children and photos.
  Future<void> refresh({required Function() onUpdate}) async {
    selectedChildId = null;
    children = [];
    photos = [];
    await loadChildren(onUpdate: onUpdate);
  }

  /// Downloads a photo to the device.
  Future<void> downloadPhoto(
    BuildContext context,
    int photoId, {
    required Function() onUpdate,
  }) async {
    final token = session.token;
    if (token == null) return;

    // Permissions check
    bool hasPermission = await _requestPermission(context);
    if (!hasPermission) return;

    downloadingIds.add(photoId);
    onUpdate();

    try {
      final localPath = await _photoService.downloadPhoto(photoId, token);
      downloadingIds.remove(photoId);
      onUpdate();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo enregistrée avec succès ✓'),
            backgroundColor: Color(0xFF009688), // Fallback or use Theme if possible
          ),
        );
      }
      debugPrint('Photo saved to: $localPath');
    } catch (e) {
      downloadingIds.remove(photoId);
      onUpdate();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<bool> _requestPermission(BuildContext context) async {
    final TargetPlatform platform = Theme.of(context).platform;

    if (platform == TargetPlatform.android) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        final status = await Permission.photos.request();
        if (status.isDenied || status.isPermanentlyDenied) {
          if (context.mounted) {
            _showDeniedSnackBar(context);
          }
          return false;
        }
      } else {
        final status = await Permission.storage.request();
        if (status.isDenied || status.isPermanentlyDenied) {
          if (context.mounted) {
            _showDeniedSnackBar(context, isStorage: true);
          }
          return false;
        }
      }
    } else if (platform == TargetPlatform.iOS) {
      final status = await Permission.photos.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        if (context.mounted) {
          _showDeniedSnackBar(context);
        }
        return false;
      }
    }
    return true;
  }

  void _showDeniedSnackBar(BuildContext context, {bool isStorage = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isStorage
              ? 'Permission d\'accès au stockage refusée.'
              : 'Permission d\'accès aux photos refusée.',
        ),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  String getSelectedChildName() {
    if (selectedChildId == null) return '';
    final child = children.firstWhere(
      (c) => c['id'].toString() == selectedChildId,
      orElse: () => <String, dynamic>{},
    );
    return child['firstName']?.toString() ?? '';
  }
}
