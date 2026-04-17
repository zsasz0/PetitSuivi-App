import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:newv/models/signalement.dart';
import 'package:newv/views/teacher/teacher_theme.dart';
import 'package:newv/views/themes/theme_colors.dart';

class CompetencySignalementSection extends StatefulWidget {
  final String childName;
  final List<Signalement> existingNotes;
  final Function(String) onAddNote;

  const CompetencySignalementSection({
    super.key,
    required this.childName,
    required this.existingNotes,
    required this.onAddNote,
  });

  @override
  State<CompetencySignalementSection> createState() => _CompetencySignalementSectionState();
}

class _CompetencySignalementSectionState extends State<CompetencySignalementSection> {
  final TextEditingController _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'SIGNALEMENTS / NOTES',
              style: TextStyle(
                fontFamily: TeacherTheme.fontName,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.redAccent,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TeacherTheme.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              TextField(
                controller: _noteCtrl,
                maxLines: 3,
                style: TextStyle(fontFamily: TeacherTheme.fontName, color: TeacherTheme.lightText, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Note un incident, une humeur particulière ou une observation...',
                  hintStyle: TextStyle(color: TeacherTheme.mutedText.withValues(alpha: 0.5), fontSize: 13),
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_noteCtrl.text.trim().isNotEmpty) {
                      widget.onAddNote(_noteCtrl.text.trim());
                      _noteCtrl.clear();
                      FocusScope.of(context).unfocus();
                    }
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: Text('Ajouter une observation pour ${widget.childName}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.existingNotes.isNotEmpty) ...[
          const SizedBox(height: 20),
          ...widget.existingNotes.map((note) => _buildNoteItem(note)),
        ],
      ],
    );
  }

  Widget _buildNoteItem(Signalement note) {
    final timeStr = DateFormat('dd/MM HH:mm').format(note.incidentTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TeacherTheme.surfaceDark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ThemeColors.glassBorderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  note.alertType,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              Text(timeStr, style: TextStyle(color: TeacherTheme.mutedText, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            note.comment ?? '',
            style: TextStyle(fontFamily: TeacherTheme.fontName, color: TeacherTheme.lightText, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
