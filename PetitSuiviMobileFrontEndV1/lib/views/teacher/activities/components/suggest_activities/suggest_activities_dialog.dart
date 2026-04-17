import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/views/teacher/activities/controllers/suggest_activities_controller.dart';

class SuggestActivitiesDialog extends StatefulWidget {
  final List<TeacherClassOption> teacherClasses;
  final SuggestActivitiesController controller;

  const SuggestActivitiesDialog({
    super.key,
    required this.teacherClasses,
    required this.controller,
  });

  @override
  State<SuggestActivitiesDialog> createState() => _SuggestActivitiesDialogState();
}

class _SuggestActivitiesDialogState extends State<SuggestActivitiesDialog> {
  late DateTime _selectedDate;
  late String _selectedClassId;
  late String _startTime;
  late String _endTime;
  String? _dialogError;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedClassId = widget.teacherClasses.first.id.toString();
    _startTime = '10:00';
    _endTime = '11:00';
  }

  bool _isEndTimeAfterStartTime(String start, String end) {
    int? toMin(String v) {
      final m = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(v.trim());
      if (m == null) return null;
      return (int.parse(m.group(1)!) * 60) + int.parse(m.group(2)!);
    }
    final s = toMin(start);
    final e = toMin(end);
    if (s == null || e == null) return false;
    return e > s;
  }

  String _suggestedEndTime(String start) {
    int? toMin(String v) {
      final m = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(v.trim());
      if (m == null) return null;
      return (int.parse(m.group(1)!) * 60) + int.parse(m.group(2)!);
    }
    final s = toMin(start);
    if (s == null) return '11:00';
    final total = (s + 60).clamp(0, (23 * 60) + 59);
    return '${(total ~/ 60).toString().padLeft(2, '0')}:${(total % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Proposer une activité',
        style: TextStyle(fontFamily: AppTheme.fontName, fontWeight: FontWeight.bold, color: AppTheme.darkerText),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: widget.controller.nameController,
              decoration: InputDecoration(
                labelText: 'Nom de l\'activité',
                labelStyle: TextStyle(fontFamily: AppTheme.fontName),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              style: TextStyle(fontFamily: AppTheme.fontName),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: widget.controller.descController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(fontFamily: AppTheme.fontName),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              style: TextStyle(fontFamily: AppTheme.fontName),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBDBDBD)),
              ),
              child: ListTile(
                title: Text('Date', style: TextStyle(fontFamily: AppTheme.fontName, fontSize: 13, color: AppTheme.grey)),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedDate), style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: Icon(Icons.calendar_today, color: AppTheme.nearlyDarkBlue, size: 18),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 1000)),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
              ),
            ),
            const SizedBox(height: 12),
            _buildTimeRow(),
            if (_dialogError != null) ...[
              const SizedBox(height: 8),
              Text(_dialogError!, style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
            ],
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedClassId,
              decoration: InputDecoration(
                labelText: 'Classe',
                labelStyle: TextStyle(fontFamily: AppTheme.fontName),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: widget.teacherClasses.map((c) => DropdownMenuItem(value: c.id.toString(), child: Text(c.name))).toList(),
              onChanged: (v) { if (v != null) setState(() => _selectedClassId = v); },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        ElevatedButton(
          onPressed: () async {
            if (widget.controller.nameController.text.trim().isEmpty) {
              setState(() => _dialogError = 'Le nom de l\'activité est obligatoire.');
              return;
            }
            if (!_isEndTimeAfterStartTime(_startTime, _endTime)) {
               setState(() => _dialogError = 'L\'heure de fin doit être après l\'heure de début.');
               return;
            }
            final ok = await widget.controller.submitSuggestion(
              context: context,
              classId: int.parse(_selectedClassId),
              selectedDate: _selectedDate,
              startTime: _startTime,
              endTime: _endTime,
            );
            if (!context.mounted) return;
            if (ok) {
              Navigator.pop(context);
            } else {
              setState(() => _dialogError = widget.controller.lastSubmitSuggestionError);
            }
          },
          child: widget.controller.isSubmittingSuggestion ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Envoyer'),
        ),
      ],
    );
  }

  Widget _buildTimeRow() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _pickTime(true),
            child: _timeBox('Début', _startTime),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: () => _pickTime(false),
            child: _timeBox('Fin', _endTime),
          ),
        ),
      ],
    );
  }

  Widget _timeBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBDBDBD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _pickTime(bool isStart) async {
    final cur = isStart ? _startTime : _endTime;
    final parts = cur.split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
    );
    if (picked != null) {
      final timeStr = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (isStart) {
          _startTime = timeStr;
          if (!_isEndTimeAfterStartTime(_startTime, _endTime)) {
            _endTime = _suggestedEndTime(_startTime);
          }
        } else {
          _endTime = timeStr;
        }
        _dialogError = null;
      });
    }
  }
}
