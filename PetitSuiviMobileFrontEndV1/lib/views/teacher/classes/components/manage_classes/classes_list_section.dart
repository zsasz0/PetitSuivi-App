import 'package:provider/provider.dart';
import 'package:newv/views/themes/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:newv/models/teacher_models.dart';
import 'package:newv/views/teacher/classes/themes/teacher_classes_theme.dart';

class ClassesListSection extends StatelessWidget {
  final List<ClassRoom> classrooms;
  final void Function(ClassRoom classroom) onOpenClass;

  const ClassesListSection({
    super.key,
    required this.classrooms,
    required this.onOpenClass,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '${classrooms.length} classe${classrooms.length > 1 ? 's' : ''}',
            style: TextStyle(
              fontFamily: TeacherClassesTheme.fontName,
              fontSize: 14,
              color: TeacherClassesTheme.mutedText,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: classrooms.length,
            itemBuilder: (context, index) {
              final classroom = classrooms[index];
              final colors = [
                TeacherClassesTheme.tealAccent,
                TeacherClassesTheme.indigoAccent,
                const Color(0xFFFFA726),
                const Color(0xFFFF6B6B),
              ];
              final color = colors[index % colors.length];

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: TeacherClassesTheme.surfaceCard(borderRadius: 16),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => onOpenClass(classroom),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: color.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Icon(Icons.class_, color: color, size: 26),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  classroom.name,
                                  style: TextStyle(
                                    fontFamily: TeacherClassesTheme.fontName,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: TeacherClassesTheme.lightText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.child_care,
                                      size: 16,
                                      color: TeacherClassesTheme.mutedText,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${classroom.children.length} enfant${classroom.children.length > 1 ? 's' : ''}',
                                      style: TextStyle(
                                        fontFamily: TeacherClassesTheme.fontName,
                                        fontSize: 14,
                                        color: TeacherClassesTheme.mutedText,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: TeacherClassesTheme.mutedText.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
