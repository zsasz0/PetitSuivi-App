import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:newv/app_theme.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/services/photo_service.dart';
import 'package:provider/provider.dart';
import 'package:newv/theme_manager.dart';
import 'package:newv/theme_colors.dart';

// File: photos_tab.dart
// Purpose: Displays a scrollable list of photos specific to a child.
// Usage: Tab item in ChildDetailsPage or child component in ParentPhotosPage.
// API Usage: Yes, GET /api/photos (via PhotoService).
// Dependencies: AuthSession, PhotoService, AppTheme.

/// A widget that fetches and renders a gallery of photos shared by teachers.
class ChildTrackingPhotosTab extends StatefulWidget {
  final int childId;
  final String childFirstName;

  const ChildTrackingPhotosTab({
    super.key,
    required this.childId,
    required this.childFirstName,
  });

  @override
  State<ChildTrackingPhotosTab> createState() => _ChildTrackingPhotosTabState();
}

class _ChildTrackingPhotosTabState extends State<ChildTrackingPhotosTab> {
  final PhotoService _photoService = PhotoService();
  List<dynamic> _photos = [];
  bool _isLoading = true;
  String? _error;
  final Set<int> _downloadingIds = {};

  // Modern Theme Colors
  static Color get _baseDark => ThemeManager.instance.isLightMode
      ? const Color(0xFFF0F2F5)
      : const Color(0xFF141B2D);
  static Color get _tealAccent => ThemeManager.instance.isLightMode
      ? const Color(0xFF009688)
      : const Color(0xFF4CCEAC);
  static Color get _indigoAccent => ThemeManager.instance.isLightMode
      ? const Color(0xFF3F51B5)
      : const Color(0xFF6870FA);
  static Color get _lightText => ThemeManager.instance.isLightMode
      ? const Color(0xFF212529)
      : const Color(0xFFF2F0F0);
  static Color get _mutedText => ThemeManager.instance.isLightMode
      ? const Color(0xFF6C757D)
      : const Color(0xFFA1A4AB);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPhotos());
  }

  @override
  void didUpdateWidget(covariant ChildTrackingPhotosTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.childId != widget.childId) {
      _loadPhotos();
    }
  }

  Future<void> _loadPhotos() async {
    final session = context.read<AuthSession>();
    final cin = session.cin;
    final token = session.token;
    if (cin == null || token == null) return;

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final photos = await _photoService.getChildPhotos(widget.childId, token);
      if (!mounted) return;

      setState(() {
        _photos = photos;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Erreur: ${e.toString()}';
      });
    }
  }

  Future<void> _downloadPhoto(int photoId) async {
    final session = context.read<AuthSession>();
    final token = session.token;
    if (token == null) return;

    // Demande de permissions
    if (Theme.of(context).platform == TargetPlatform.android) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        final status = await Permission.photos.request();
        if (status.isDenied || status.isPermanentlyDenied) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Permission d\'accès aux photos refusée.'),
              backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
            ),
          );
          return;
        }
      } else {
        final status = await Permission.storage.request();
        if (status.isDenied || status.isPermanentlyDenied) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Permission d\'accès au stockage refusée.'),
              backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
            ),
          );
          return;
        }
      }
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      final status = await Permission.photos.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Permission d\'accès aux photos refusée.'),
            backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          ),
        );
        return;
      }
    }

    setState(() => _downloadingIds.add(photoId));

    try {
      final localPath = await _photoService.downloadPhoto(photoId, token);
      if (!mounted) return;
      setState(() => _downloadingIds.remove(photoId));
      // localPath is kept for potential future use (e.g. opening the file)
      debugPrint('Photo saved to: $localPath');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Photo enregistrée avec succès ✓'),
          backgroundColor: _tealAccent.withValues(alpha: 0.9),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _downloadingIds.remove(photoId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    final formatter = DateFormat('dd/MM/yyyy • HH:mm', 'fr');

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(_tealAccent),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontFamily: AppTheme.fontName,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadPhotos,
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                label: const Text(
                  'Réessayer',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_photos.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: ThemeColors.glassBackgroundSubtle,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: ThemeColors.glassBorderSubtle),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ThemeColors.glassBackgroundSubtle,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.photo_library_outlined,
                    size: 48,
                    color: _mutedText,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune photo partagée pour ${widget.childFirstName} pour le moment.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    color: _mutedText,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return RefreshIndicator(
      color: _tealAccent,
      backgroundColor: _baseDark,
      onRefresh: _loadPhotos,
      child: ListView.builder(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: 100,
        ),
        itemCount: _photos.length,
        itemBuilder: (context, index) {
          final photo = _photos[index];
          final session = context.read<AuthSession>();
          return _buildPhotoCard(photo, formatter, session.token);
        },
      ),
    );
  }

  Widget _buildPhotoCard(dynamic photo, DateFormat formatter, String? token) {
    final photoId = int.tryParse(photo['id']?.toString() ?? '0') ?? 0;
    final createdAt = DateTime.tryParse(photo['created_at']?.toString() ?? '');
    final daysRemaining =
        int.tryParse(photo['days_remaining']?.toString() ?? '0') ?? 0;
    final isDownloading = _downloadingIds.contains(photoId);

    // Teacher info
    final teacher = photo['teacher'];
    final teacherName = teacher != null
        ? '${teacher['firstName'] ?? ''} ${teacher['lastName'] ?? ''}'.trim()
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: ThemeColors.glassBackgroundSubtle,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ThemeColors.glassBorderSubtle),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.shadow,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photo Image — fetched via authenticated download endpoint
              if (photoId > 0 && token != null)
                _buildAuthenticatedImage(photoId, token)
              else
                Container(
                  height: 250,
                  color: ThemeColors.glassBackgroundSubtle,
                  child: Center(
                    child: Icon(
                      Icons.broken_image_rounded,
                      size: 48,
                      color: _mutedText,
                    ),
                  ),
                ),

              // Details pane
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                teacherName.isNotEmpty
                                    ? 'Partagé par $teacherName'
                                    : 'Photo partagée',
                                style: TextStyle(
                                  fontFamily: AppTheme.fontName,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: _lightText,
                                ),
                              ),
                              const SizedBox(height: 6),
                              if (createdAt != null)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 14,
                                      color: _mutedText.withValues(alpha: 0.8),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      formatter.format(createdAt),
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontName,
                                        fontSize: 13,
                                        color: _mutedText.withValues(
                                          alpha: 0.8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        // Download Button
                        GestureDetector(
                          onTap: isDownloading
                              ? null
                              : () => _downloadPhoto(photoId),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDownloading
                                  ? ThemeColors.glassBorder
                                  : _indigoAccent.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDownloading
                                    ? Colors.transparent
                                    : _indigoAccent.withValues(alpha: 0.3),
                              ),
                            ),
                            child: isDownloading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        _indigoAccent,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    Icons.file_download_outlined,
                                    color: _indigoAccent,
                                    size: 20,
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Expiration Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: daysRemaining <= 7
                            ? Colors.redAccent.withValues(alpha: 0.15)
                            : Colors.orangeAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: daysRemaining <= 7
                              ? Colors.redAccent.withValues(alpha: 0.3)
                              : Colors.orangeAccent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 14,
                            color: daysRemaining <= 7
                                ? Colors.redAccent
                                : Colors.orangeAccent,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            daysRemaining <= 0
                                ? 'Expire aujourd\'hui'
                                : daysRemaining == 1
                                ? 'Expire demain'
                                : 'Expire dans $daysRemaining jours',
                            style: TextStyle(
                              fontFamily: AppTheme.fontName,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: daysRemaining <= 7
                                  ? Colors.redAccent
                                  : Colors.orangeAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Loads a photo via the authenticated `/api/photos/{id}/download` endpoint
  /// and displays it using [Image.memory]. This avoids the unreliable
  /// `/storage/` URL which fails on phones due to host/symlink/auth issues.
  Widget _buildAuthenticatedImage(int photoId, String token) {
    return FutureBuilder<List<int>>(
      future: _photoService.getPhotoBytes(photoId, token),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 280,
            color: ThemeColors.glassBackgroundSubtle,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_tealAccent),
              ),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Container(
            height: 280,
            color: ThemeColors.glassBackgroundSubtle,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.broken_image_rounded, size: 48, color: _mutedText),
                  SizedBox(height: 8),
                  Text(
                    'Image indisponible',
                    style: TextStyle(color: _mutedText),
                  ),
                ],
              ),
            ),
          );
        }

        return Image.memory(
          Uint8List.fromList(snapshot.data!),
          height: 280,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      },
    );
  }
}
