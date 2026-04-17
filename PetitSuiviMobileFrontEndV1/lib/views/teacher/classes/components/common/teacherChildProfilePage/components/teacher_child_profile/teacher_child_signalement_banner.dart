import 'package:flutter/material.dart';
import 'package:newv/models/signalement.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/views/teacher/classes/components/common/teacherChildProfilePage/themes/teacher_child_theme.dart';

class TeacherChildSignalementBanner extends StatelessWidget {
  final List<Signalement> signalements;

  const TeacherChildSignalementBanner({
    super.key,
    required this.signalements,
  });

  @override
  Widget build(BuildContext context) {
    if (signalements.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: TeacherChildTheme.signalBannerDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.notification_important,
                color: Colors.redAccent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Signalements du jour',
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.redAccent,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${signalements.length}',
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...signalements.map((s) => _SignalItem(signalement: s)),
        ],
      ),
    );
  }
}

class _SignalItem extends StatelessWidget {
  final Signalement signalement;

  const _SignalItem({required this.signalement});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _alertTypeIcon(signalement.alertType),
            size: 16,
            color: _alertTypeColor(signalement.alertType),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  signalement.alertType,
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: _alertTypeColor(signalement.alertType),
                  ),
                ),
                if (signalement.comment != null &&
                    signalement.comment!.isNotEmpty)
                  Text(
                    signalement.comment!,
                    style: TextStyle(
                      fontFamily: AppTheme.fontName,
                      fontSize: 12,
                      color: AppTheme.darkText,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _alertTypeIcon(String alertType) {
    switch (alertType) {
      case 'Humeur':
        return Icons.mood_bad;
      case 'Isolement':
        return Icons.person_off;
      case 'Pleurs':
        return Icons.water_drop;
      case 'Agressivité':
        return Icons.flash_on;
      default:
        return Icons.more_horiz;
    }
  }

  Color _alertTypeColor(String alertType) {
    switch (alertType) {
      case 'Humeur':
        return TeacherChildTheme.humeurColor;
      case 'Isolement':
        return TeacherChildTheme.isolementColor;
      case 'Pleurs':
        return TeacherChildTheme.pleursColor;
      case 'Agressivité':
        return TeacherChildTheme.agressiviteColor;
      default:
        return TeacherChildTheme.autreColor;
    }
  }
}
