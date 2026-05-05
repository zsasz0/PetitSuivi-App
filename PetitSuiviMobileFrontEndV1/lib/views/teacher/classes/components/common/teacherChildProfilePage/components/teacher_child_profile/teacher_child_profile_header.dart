import 'package:flutter/material.dart';
import 'package:newv/models/teacher_models.dart';
import 'package:newv/views/teacher/teacher_theme.dart';
import 'package:newv/views/teacher/classes/components/common/teacherChildProfilePage/components/common/teacher_child_chips.dart';

class TeacherChildProfileHeader extends StatelessWidget {
  final MockChild child;
  final String className;

  const TeacherChildProfileHeader({
    super.key,
    required this.child,
    required this.className,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: TeacherTheme.surfaceCard(borderRadius: 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: TeacherTheme.tealAccent.withValues(
              alpha: 0.1,
            ),
            child: Text(
              '${child.firstName[0]}${child.lastName[0]}',
              style: TextStyle(
                fontFamily: TeacherTheme.fontName,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: TeacherTheme.tealAccent,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            child.fullName,
            style: TextStyle(
              fontFamily: TeacherTheme.fontName,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: TeacherTheme.lightText,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TeacherChildInfoChip(icon: Icons.class_, label: className),
              const SizedBox(width: 8),
              TeacherChildInfoChip(icon: Icons.cake, label: '${child.age} ans'),
            ],
          ),
        ],
      ),
    );
  }
}
