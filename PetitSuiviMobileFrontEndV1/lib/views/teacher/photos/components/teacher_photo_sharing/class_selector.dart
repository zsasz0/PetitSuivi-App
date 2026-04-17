import 'package:flutter/material.dart';
import 'package:newv/views/themes/theme_colors.dart';
import 'package:newv/views/teacher/photos/controllers/teacher_photo_sharing_controller.dart';
import 'package:newv/views/teacher/photos/themes/photos_theme.dart';

class ClassSelector extends StatelessWidget {
  final TeacherPhotoSharingController controller;

  const ClassSelector({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: controller.selectedClassId,
      dropdownColor: PhotosTheme.card,
      style: TextStyle(
        color: PhotosTheme.text,
        fontFamily: 'Montserrat', // Access via PhotosTheme if needed
      ),
      decoration: InputDecoration(
        labelText: 'Classe',
        labelStyle: TextStyle(color: PhotosTheme.textMuted),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: ThemeColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: PhotosTheme.primary),
        ),
      ),
      items: controller.classes
          .map(
            (c) => DropdownMenuItem<String>(
              value: c['id'].toString(),
              child: Text(
                c['name']?.toString() ?? 'Classe #${c['id']}',
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        controller.selectedClassId = value;
        controller.loadChildrenForClass(value);
      },
    );
  }
}
