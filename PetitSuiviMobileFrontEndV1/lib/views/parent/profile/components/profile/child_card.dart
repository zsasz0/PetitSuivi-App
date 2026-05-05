import 'package:flutter/material.dart';
import 'package:newv/views/parent/profile/themes/profile_theme.dart';

class ChildCard extends StatelessWidget {
  final Map<String, dynamic> child;
  final Function(Map<String, dynamic>) onChildTap;
  final String Function(String, {double? price}) shortMealPlanLabel;

  const ChildCard({
    super.key,
    required this.child,
    required this.onChildTap,
    required this.shortMealPlanLabel,
  });

  @override
  Widget build(BuildContext context) {
    final inscriptions = child['extraData']?['inscriptions'] as List? ?? [];

    final mealPlan = (inscriptions.isNotEmpty)
        ? inscriptions.last['meal_plan']?.toString() ?? ''
        : '';

    return InkWell(
      onTap: () => onChildTap(child),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ProfileTheme.glassBackgroundSubtle,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ProfileTheme.glassBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ProfileTheme.indigoAccent.withValues(alpha: 0.1),
              ),
              child: Icon(Icons.face_rounded, color: ProfileTheme.indigoAccent),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${child['firstName']} ${child['lastName']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: ProfileTheme.lightText,
                    ),
                  ),
                  if (mealPlan.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      shortMealPlanLabel(mealPlan),
                      style: TextStyle(
                        fontSize: 12,
                        color: ProfileTheme.mutedText,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded,
                color: ProfileTheme.mutedText, size: 20),
          ],
        ),
      ),
    );
  }
}
