import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:newv/views/teacher/photos/controllers/teacher_photo_sharing_controller.dart';
import 'package:newv/views/teacher/photos/themes/photos_theme.dart';

class RecentShares extends StatelessWidget {
  final TeacherPhotoSharingController controller;

  const RecentShares({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm', 'fr');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Partages récents',
          style: PhotosTheme.titleStyle.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 8),
        if (controller.isLoadingRecent)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                color: Colors.tealAccent,
              ),
            ),
          )
        else if (controller.recentPhotos.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: PhotosTheme.sectionDecoration,
            child: Text(
              'Aucun partage pour le moment.',
              style: TextStyle(color: PhotosTheme.textMuted),
            ),
          )
        else
          ...controller.recentPhotos.take(10).map((photo) {
            final photoId = photo['id'];
            final createdAt = DateTime.tryParse(
              photo['created_at']?.toString() ?? '',
            );
            final recipients = photo['recipients'] as List? ?? [];
            final childNames = recipients
                .map((r) {
                  final name = r['child_name']?.toString() ?? '';
                  return name.trim();
                })
                .where((n) => n.isNotEmpty)
                .toList();
            final expired = photo['expired'] == true;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: PhotosTheme.sectionDecoration,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: expired
                      ? Colors.grey.withValues(alpha: 0.15)
                      : PhotosTheme.accentIndigo.withValues(alpha: 0.15),
                  child: Icon(
                    expired ? Icons.timer_off : Icons.photo,
                    color: expired ? PhotosTheme.textMuted : PhotosTheme.accentIndigo,
                  ),
                ),
                title: Text(
                  '${childNames.length} enfant(s)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: PhotosTheme.text,
                  ),
                ),
                subtitle: Text(
                  '${childNames.take(3).join(', ')}${childNames.length > 3 ? '...' : ''}\n${createdAt != null ? dateFormatter.format(createdAt) : ''}${expired ? ' • Expirée' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: PhotosTheme.textMuted,
                  ),
                ),
                isThreeLine: true,
                trailing: IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: PhotosTheme.accentRed.withValues(alpha: 0.8),
                    size: 20,
                  ),
                  onPressed: () => controller.deletePhoto(photoId),
                  tooltip: 'Supprimer',
                ),
              ),
            );
          }),
      ],
    );
  }
}
