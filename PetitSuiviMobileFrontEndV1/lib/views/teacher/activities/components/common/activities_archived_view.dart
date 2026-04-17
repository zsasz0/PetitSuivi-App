import 'package:flutter/material.dart';
import 'package:newv/views/teacher/teacher_theme.dart';

class ActivitiesArchivedView extends StatelessWidget {
  final String? planningLabel;

  const ActivitiesArchivedView({super.key, this.planningLabel});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.archive_outlined,
              color: Color(0xFF42A5F5),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              "Année scolaire archivée",
              style: TextStyle(
                fontFamily: TeacherTheme.fontName,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: TeacherTheme.lightText,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "L'année scolaire ${planningLabel ?? ''} est archivée.\nLes activités ne sont plus consultables.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: TeacherTheme.fontName,
                fontSize: 14,
                color: Color(0xFF90CAF9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
