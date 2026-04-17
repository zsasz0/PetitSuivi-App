import 'package:flutter/material.dart';
import 'package:newv/services/photo_service.dart';
import 'package:newv/views/parent/photos/components/photos/empty_state.dart';
import 'package:newv/views/parent/photos/components/photos/photo_card.dart';
import 'package:newv/views/parent/photos/controllers/photos_controller.dart';
import 'package:newv/views/parent/photos/themes/photos_theme.dart';

class PhotosList extends StatelessWidget {
  final PhotosController controller;

  const PhotosList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.isLoadingPhotos) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(PhotosTheme.tealAccent),
        ),
      );
    }

    if (controller.photoError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              controller.photoError!,
              style: const TextStyle(color: Colors.redAccent),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.loadPhotos(
                int.parse(controller.selectedChildId!),
                onUpdate: () => (context as Element).markNeedsBuild(),
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (controller.photos.isEmpty) {
      return PhotosEmptyState(
        message:
            'Aucune photo partagée pour ${controller.getSelectedChildName()} pour le moment.',
        icon: Icons.photo_library_outlined,
      );
    }

    return RefreshIndicator(
      color: PhotosTheme.tealAccent,
      backgroundColor: PhotosTheme.baseDark,
      onRefresh: () => controller.loadPhotos(
        int.parse(controller.selectedChildId!),
        onUpdate: () => (context as Element).markNeedsBuild(),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: 100,
        ),
        itemCount: controller.photos.length,
        itemBuilder: (context, index) {
          final photo = controller.photos[index];
          final photoId = int.tryParse(photo['id']?.toString() ?? '0') ?? 0;
          return PhotoCard(
            photo: photo,
            token: controller.session.token,
            isDownloading: controller.downloadingIds.contains(photoId),
            onDownload: () => controller.downloadPhoto(
              context,
              photoId,
              onUpdate: () => (context as Element).markNeedsBuild(),
            ),
            photoService: PhotoService(),
          );
        },
      ),
    );
  }
}
