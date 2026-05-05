import 'package:flutter/material.dart';
import 'package:newv/models/teacher_models.dart';
import 'package:newv/views/teacher/activities/components/common/activities_class_dropdown.dart';

class ActivitiesClassSelector extends StatelessWidget {
  final List<ClassRoom> classes;
  final ClassRoom? selectedClass;
  final bool isLoading;
  final String? error;
  final Function(ClassRoom) onClassSelected;
  final VoidCallback onRefresh;

  const ActivitiesClassSelector({
    super.key,
    required this.classes,
    required this.selectedClass,
    required this.isLoading,
    this.error,
    required this.onClassSelected,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 56,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (error != null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              onPressed: onRefresh,
              color: Colors.redAccent,
            ),
          ],
        ),
      );
    }

    return ActivitiesClassDropdown(
      classes: classes,
      selectedClass: selectedClass,
      onClassSelected: onClassSelected,
    );
  }
}
