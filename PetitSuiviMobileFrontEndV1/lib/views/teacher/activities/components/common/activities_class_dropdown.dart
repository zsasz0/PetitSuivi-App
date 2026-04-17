import 'package:flutter/material.dart';
import 'package:newv/models/teacher_models.dart';
import 'package:newv/views/teacher/activities/themes/activities_theme.dart';
import 'package:newv/views/teacher/teacher_theme.dart';
import 'package:newv/views/themes/theme_colors.dart';

class ActivitiesClassDropdown extends StatelessWidget {
  final List<ClassRoom> classes;
  final ClassRoom? selectedClass;
  final Function(ClassRoom) onClassSelected;

  const ActivitiesClassDropdown({
    super.key,
    required this.classes,
    required this.selectedClass,
    required this.onClassSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: ActivitiesTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.glassBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedClass?.id,
          hint: Text(
            'Sélectionnez une classe',
            style: TextStyle(
              color: TeacherTheme.mutedText,
              fontFamily: TeacherTheme.fontName,
            ),
          ),
          isExpanded: true,
          dropdownColor: ActivitiesTheme.surfaceDark,
          icon: Icon(Icons.arrow_drop_down, color: TeacherTheme.lightText),
          items: classes.map((cls) {
            final isSelected = selectedClass?.id == cls.id;
            return DropdownMenuItem<String>(
              value: cls.id,
              child: Text(
                cls.name,
                style: TextStyle(
                  fontFamily: TeacherTheme.fontName,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? ActivitiesTheme.primaryBlue : TeacherTheme.lightText,
                ),
              ),
            );
          }).toList(),
          onChanged: (id) {
            if (id != null) {
              final cls = classes.firstWhere((c) => c.id == id);
              onClassSelected(cls);
            }
          },
        ),
      ),
    );
  }
}
