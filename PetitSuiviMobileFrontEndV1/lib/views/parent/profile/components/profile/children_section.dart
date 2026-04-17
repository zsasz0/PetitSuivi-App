import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/views/parent/profile/themes/profile_theme.dart';
import 'child_card.dart';
import 'child_skeleton.dart';

class ChildrenSection extends StatelessWidget {
  final bool isLoading;
  final List<Map<String, dynamic>> children;
  final Function(Map<String, dynamic>) onChildTap;
  final VoidCallback onInscribeChild;
  final bool inscriptionsOpen;
  final String Function(String, {double? price}) shortMealPlanLabel;

  const ChildrenSection({
    super.key,
    required this.isLoading,
    required this.children,
    required this.onChildTap,
    required this.onInscribeChild,
    required this.inscriptionsOpen,
    required this.shortMealPlanLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mes Enfants',
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: ProfileTheme.lightText,
              ),
            ),
            if (inscriptionsOpen)
              TextButton.icon(
                onPressed: onInscribeChild,
                icon: Icon(Icons.add_circle_outline,
                    size: 20, color: ProfileTheme.tealAccent),
                label: Text(
                  'Ajouter un enfant',
                  style: TextStyle(
                    color: ProfileTheme.tealAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (isLoading)
          const ChildSkeleton()
        else if (children.isEmpty)
          _buildEmptyState()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: children.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => ChildCard(
              child: children[index],
              onChildTap: onChildTap,
              shortMealPlanLabel: shortMealPlanLabel,
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ProfileTheme.glassBackgroundSubtle,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ProfileTheme.glassBorder),
      ),
      child: Column(
        children: [
          Icon(Icons.child_care_rounded,
              size: 48, color: ProfileTheme.mutedText.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(
            'Aucun enfant inscrit pour le moment.',
            style: TextStyle(
              color: ProfileTheme.mutedText,
              fontFamily: AppTheme.fontName,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
