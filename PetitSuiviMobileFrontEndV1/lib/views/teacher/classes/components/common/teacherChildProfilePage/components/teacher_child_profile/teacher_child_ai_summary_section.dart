import 'package:flutter/material.dart';
import 'package:newv/views/teacher/teacher_theme.dart';
import 'package:newv/views/teacher/classes/components/common/teacherChildProfilePage/themes/teacher_child_theme.dart';

class TeacherChildAiSummarySection extends StatelessWidget {
  final bool isLoading;
  final String? dietaryComment;
  final String? healthComment;

  const TeacherChildAiSummarySection({
    super.key,
    required this.isLoading,
    this.dietaryComment,
    this.healthComment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.psychology,
              color: TeacherChildTheme.aiSummaryPurple,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              'Résumé IA',
              style: TeacherChildTheme.sectionTitleStyle,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Analyses générées par l\'intelligence artificielle à partir du dossier médical.',
          style: TeacherChildTheme.sectionSubtitleStyle,
        ),
        const SizedBox(height: 14),
        if (isLoading)
          _buildLoadingState()
        else if (dietaryComment == null && healthComment == null)
          _buildEmptyState()
        else ...[
          if (dietaryComment != null)
            _buildAiCard(
              icon: Icons.restaurant,
              title: 'Restrictions alimentaires',
              comment: dietaryComment!,
              color: TeacherChildTheme.dietaryTeal,
            ),
          if (healthComment != null)
            _buildAiCard(
              icon: Icons.local_hospital,
              title: 'Santé générale',
              comment: healthComment!,
              color: TeacherChildTheme.healthBlue,
            ),
        ],
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: TeacherTheme.surfaceCard(borderRadius: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: TeacherChildTheme.aiSummaryPurple,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Chargement des résumés...',
            style: TextStyle(
              fontFamily: TeacherTheme.fontName,
              fontSize: 13,
              color: TeacherTheme.mutedText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TeacherChildTheme.aiSummaryPurple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Aucun résumé IA disponible pour cet enfant.',
        style: TextStyle(
          fontFamily: TeacherTheme.fontName,
          fontSize: 12,
          color: TeacherChildTheme.aiSummaryPurple,
        ),
      ),
    );
  }

  Widget _buildAiCard({
    required IconData icon,
    required String title,
    required String comment,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: TeacherChildTheme.aiCardDecoration(color),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: TeacherTheme.fontName,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            style: TextStyle(
              fontFamily: TeacherTheme.fontName,
              fontSize: 13,
              color: TeacherTheme.lightText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
