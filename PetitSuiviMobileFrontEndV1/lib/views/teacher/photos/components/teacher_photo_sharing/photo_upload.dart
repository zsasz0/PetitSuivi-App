import 'dart:io';
import 'package:flutter/material.dart';
import 'package:newv/views/themes/theme_colors.dart';
import 'package:newv/views/teacher/photos/controllers/teacher_photo_sharing_controller.dart';
import 'package:newv/views/teacher/photos/themes/photos_theme.dart';

class PhotoUpload extends StatelessWidget {
  final TeacherPhotoSharingController controller;

  const PhotoUpload({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (controller.pickedImagePath != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(controller.pickedImagePath!),
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          )
        else
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: ThemeColors.glassBorderSubtle,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ThemeColors.glassBorder),
            ),
            child: Center(
              child: Text(
                'Aucune photo sélectionnée',
                style: TextStyle(color: PhotosTheme.textMuted),
              ),
            ),
          ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: controller.pickImage,
          style: OutlinedButton.styleFrom(
            foregroundColor: PhotosTheme.primary,
            side: BorderSide(color: PhotosTheme.primary),
          ),
          icon: const Icon(Icons.photo_library_outlined),
          label: const Text('Choisir une photo'),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          initialValue: controller.selectedExpirationDays,
          dropdownColor: PhotosTheme.card,
          style: TextStyle(
            color: PhotosTheme.text,
          ),
          decoration: InputDecoration(
            labelText: "Durée d'expiration",
            labelStyle: TextStyle(color: PhotosTheme.textMuted),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: ThemeColors.glassBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: PhotosTheme.primary,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: const [
            DropdownMenuItem(value: 3, child: Text('3 Jours')),
            DropdownMenuItem(value: 7, child: Text('1 Semaine')),
            DropdownMenuItem(value: 30, child: Text('1 Mois')),
          ],
          onChanged: (val) {
            if (val != null) {
              controller.selectedExpirationDays = val;
              controller.setState(() {});
            }
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: controller.isSending ? null : controller.sendPhoto,
            style: ElevatedButton.styleFrom(
              backgroundColor: PhotosTheme.primary,
              foregroundColor: PhotosTheme.background,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: controller.isSending
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: PhotosTheme.background,
                    ),
                  )
                : const Icon(Icons.send),
            label: Text(controller.isSending ? 'Envoi...' : 'Envoyer'),
          ),
        ),
      ],
    );
  }
}
