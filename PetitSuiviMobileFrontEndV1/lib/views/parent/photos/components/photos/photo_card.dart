import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/services/photo_service.dart';
import 'package:newv/views/themes/theme_colors.dart';
import 'package:newv/views/parent/photos/themes/photos_theme.dart';

class PhotoCard extends StatelessWidget {
  final dynamic photo;
  final String? token;
  final bool isDownloading;
  final VoidCallback onDownload;
  final PhotoService photoService;

  const PhotoCard({
    super.key,
    required this.photo,
    required this.token,
    required this.isDownloading,
    required this.onDownload,
    required this.photoService,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd/MM/yyyy • HH:mm', 'fr');
    final photoId = int.tryParse(photo['id']?.toString() ?? '0') ?? 0;
    final createdAt = DateTime.tryParse(photo['created_at']?.toString() ?? '');
    final daysRemaining =
        int.tryParse(photo['days_remaining']?.toString() ?? '0') ?? 0;

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
              // Photo Image
              if (photoId > 0 && token != null)
                _buildAuthenticatedImage(photoId, token!)
              else
                Container(
                  height: 250,
                  color: ThemeColors.glassBackgroundSubtle,
                  child: Center(
                    child: Icon(
                      Icons.broken_image_rounded,
                      size: 48,
                      color: PhotosTheme.mutedText,
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
                                  color: PhotosTheme.lightText,
                                ),
                              ),
                              const SizedBox(height: 6),
                              if (createdAt != null)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 14,
                                      color: PhotosTheme.mutedText.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      formatter.format(createdAt),
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontName,
                                        fontSize: 13,
                                        color: PhotosTheme.mutedText.withValues(
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
                          onTap: isDownloading ? null : onDownload,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDownloading
                                  ? ThemeColors.glassBorder
                                  : PhotosTheme.indigoAccent.withValues(
                                      alpha: 0.15,
                                    ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDownloading
                                    ? Colors.transparent
                                    : PhotosTheme.indigoAccent.withValues(
                                        alpha: 0.3,
                                      ),
                              ),
                            ),
                            child: isDownloading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        PhotosTheme.indigoAccent,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    Icons.file_download_outlined,
                                    color: PhotosTheme.indigoAccent,
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

  Widget _buildAuthenticatedImage(int photoId, String token) {
    return FutureBuilder<List<int>>(
      future: photoService.getPhotoBytes(photoId, token),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 280,
            color: ThemeColors.glassBackgroundSubtle,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  PhotosTheme.tealAccent,
                ),
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
                  Icon(
                    Icons.broken_image_rounded,
                    size: 48,
                    color: PhotosTheme.mutedText,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Image indisponible',
                    style: TextStyle(color: PhotosTheme.mutedText),
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
