import 'package:flutter/material.dart';
import 'package:newv/views/teacher/photos/controllers/teacher_photo_sharing_controller.dart';
import 'package:newv/views/teacher/photos/themes/photos_theme.dart';

class ChildrenSelector extends StatelessWidget {
  final TeacherPhotoSharingController controller;

  const ChildrenSelector({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.isLoadingChildren) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.tealAccent,
          ),
        ),
      );
    }

    if (controller.classChildren.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'Aucun enfant dans cette classe.',
          style: TextStyle(color: PhotosTheme.textMuted),
        ),
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${controller.selectedChildIds.length}/${controller.classChildren.length} sélectionnés',
              style: TextStyle(
                fontSize: 13,
                color: PhotosTheme.textMuted,
              ),
            ),
            TextButton(
              onPressed: controller.toggleSelectAll,
              child: Text(
                controller.selectedChildIds.length == controller.classChildren.length
                    ? 'Désélectionner tout'
                    : 'Sélectionner tout',
                style: TextStyle(
                  color: PhotosTheme.primary,
                ),
              ),
            ),
          ],
        ),
        ...controller.classChildren.map((child) {
          final childId = int.tryParse(child['id'].toString()) ?? 0;
          final firstName = child['firstName']?.toString() ?? '';
          final lastName = child['lastName']?.toString() ?? '';
          return CheckboxListTile(
            dense: true,
            checkColor: PhotosTheme.background,
            activeColor: PhotosTheme.primary,
            value: controller.selectedChildIds.contains(childId),
            title: Text(
              '$firstName $lastName'.trim(),
              style: TextStyle(
                color: PhotosTheme.text,
              ),
            ),
            onChanged: (checked) {
              if (checked == true) {
                controller.selectedChildIds.add(childId);
              } else {
                controller.selectedChildIds.remove(childId);
              }
              controller.setState(() {});
            },
          );
        }),
      ],
    );
  }
}
