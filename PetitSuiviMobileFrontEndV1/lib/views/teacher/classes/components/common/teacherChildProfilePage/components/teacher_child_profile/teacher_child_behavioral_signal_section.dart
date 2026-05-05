import 'package:flutter/material.dart';
import 'package:newv/views/teacher/teacher_theme.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/views/teacher/classes/components/common/teacherChildProfilePage/themes/teacher_child_theme.dart';

class TeacherChildBehavioralSignalSection extends StatefulWidget {
  final bool isSending;
  final Function(String, String?) onSignalSubmit;

  const TeacherChildBehavioralSignalSection({
    super.key,
    required this.isSending,
    required this.onSignalSubmit,
  });

  @override
  State<TeacherChildBehavioralSignalSection> createState() =>
      _TeacherChildBehavioralSignalSectionState();
}

class _TeacherChildBehavioralSignalSectionState
    extends State<TeacherChildBehavioralSignalSection> {
  String? _selectedAlertType;
  final TextEditingController _descCtrl = TextEditingController();

  static const _alertTypes = <String, Map<String, dynamic>>{
    'Humeur': {'icon': Icons.mood_bad, 'color': TeacherChildTheme.humeurColor},
    'Isolement': {
      'icon': Icons.person_off,
      'color': TeacherChildTheme.isolementColor
    },
    'Pleurs': {'icon': Icons.water_drop, 'color': TeacherChildTheme.pleursColor},
    'Agressivité': {
      'icon': Icons.flash_on,
      'color': TeacherChildTheme.agressiviteColor
    },
    'Autre': {'icon': Icons.more_horiz, 'color': TeacherChildTheme.autreColor},
  };

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_selectedAlertType != null) {
      widget.onSignalSubmit(
        _selectedAlertType!,
        _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      );
      // We don't clear here, we wait for the parent to tell us it's done if we wanted to
      // But in the original code it was cleared after success.
      // I'll add a way to clear it via a key or just trust the state update.
      // For now, I'll clear it when isSending goes from true to false? 
      // Actually, better to just clear it if the parent calls a callback.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              'Signaler un comportement',
              style: TeacherChildTheme.sectionTitleStyle,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Signalez un comportement inhabituel pour déclencher une alerte pédagogique.',
          style: TeacherChildTheme.sectionSubtitleStyle,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: TeacherTheme.surfaceCard(borderRadius: 16).copyWith(
            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Type de signalement :',
                style: TextStyle(
                  fontFamily: TeacherTheme.fontName,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: TeacherTheme.lightText,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _alertTypes.entries.map((entry) {
                  final alertType = entry.key;
                  final meta = entry.value;
                  final isSelected = _selectedAlertType == alertType;
                  final color = meta['color'] as Color;
                  return GestureDetector(
                    onTap: () => setState(
                      () => _selectedAlertType = isSelected ? null : alertType,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.2)
                            : TeacherTheme.baseDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? color
                              : TeacherTheme.mutedText.withValues(alpha: 0.2),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            meta['icon'] as IconData,
                            size: 18,
                            color: isSelected
                                ? color
                                : TeacherTheme.mutedText.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            alertType,
                            style: TextStyle(
                              fontFamily: TeacherTheme.fontName,
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 12,
                              color: isSelected ? color : TeacherTheme.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _descCtrl,
                maxLines: 2,
                style: TextStyle(
                  fontFamily: TeacherTheme.fontName,
                  fontSize: 14,
                  color: TeacherTheme.lightText,
                ),
                decoration: InputDecoration(
                  hintText: 'Description (optionnel)...',
                  hintStyle: TextStyle(
                    fontFamily: TeacherTheme.fontName,
                    fontSize: 13,
                    color: TeacherTheme.mutedText.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: TeacherTheme.surfaceDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (_selectedAlertType != null && !widget.isSending)
                      ? () {
                          _handleSubmit();
                          // Clear values after submission if needed or handled by parent
                          _selectedAlertType = null;
                          _descCtrl.clear();
                          setState(() {});
                        }
                      : null,
                  icon: widget.isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.warning_amber_rounded, size: 18),
                  label: Text(
                    widget.isSending
                        ? 'Envoi en cours...'
                        : 'Envoyer le signalement',
                    style: TextStyle(
                      fontFamily: AppTheme.fontName,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppTheme.grey.withValues(alpha: 0.15),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
