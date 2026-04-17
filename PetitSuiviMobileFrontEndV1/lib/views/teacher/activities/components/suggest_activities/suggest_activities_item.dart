import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/views/teacher/activities/controllers/suggest_activities_controller.dart';

class SuggestActivitiesItem extends StatelessWidget {
  final TeacherSuggestionItem item;

  const SuggestActivitiesItem({super.key, required this.item});

  String _statusLabel(String status) {
    switch (status) {
      case 'approved': return 'Confirmée';
      case 'rejected': return 'Rejetée';
      case 'en_cours': return 'En cours';
      default: return 'En cours';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      default: return AppTheme.nearlyDarkBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(item.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.event_note, color: statusColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.darkerText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontSize: 14,
                          color: AppTheme.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _statusLabel(item.status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: AppTheme.grey),
                const SizedBox(width: 4),
                Text(
                  '${item.day} ${item.dateLabel}',
                  style: TextStyle(fontFamily: AppTheme.fontName, fontSize: 12, color: AppTheme.grey),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 14, color: AppTheme.grey),
                const SizedBox(width: 4),
                Text(
                  item.time,
                  style: TextStyle(fontFamily: AppTheme.fontName, fontSize: 12, color: AppTheme.grey),
                ),
                const Spacer(),
                Icon(Icons.school, size: 14, color: AppTheme.grey),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    item.classLabel,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontFamily: AppTheme.fontName, fontSize: 12, color: AppTheme.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
