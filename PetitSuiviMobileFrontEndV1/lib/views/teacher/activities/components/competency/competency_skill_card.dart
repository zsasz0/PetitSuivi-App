import 'package:flutter/material.dart';
import 'package:newv/views/teacher/teacher_theme.dart';
import 'package:newv/views/themes/theme_colors.dart';
import 'package:newv/views/themes/theme_manager.dart';
import 'package:provider/provider.dart';

class CompetencySkillCard extends StatefulWidget {
  final String criterionName;
  final String initialLevelStr;
  final String? currentComment;
  final void Function(String levelStr, String? comment) onChanged;

  const CompetencySkillCard({
    super.key,
    required this.criterionName,
    required this.initialLevelStr,
    this.currentComment,
    required this.onChanged,
  });

  @override
  State<CompetencySkillCard> createState() => _CompetencySkillCardState();
}

class _CompetencySkillCardState extends State<CompetencySkillCard> {
  late String _levelStr;
  late TextEditingController _commentCtrl;
  bool _expanded = false;

  final List<String> availableLevels = ['Acquise', 'En cours', 'À renforcer'];

  @override
  void initState() {
    super.initState();
    _levelStr = widget.initialLevelStr;
    _commentCtrl = TextEditingController(text: widget.currentComment ?? '');
  }

  @override
  void didUpdateWidget(CompetencySkillCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialLevelStr != oldWidget.initialLevelStr) {
      _levelStr = widget.initialLevelStr;
    }
    if (widget.currentComment != oldWidget.currentComment) {
      _commentCtrl.text = widget.currentComment ?? '';
    }
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Color _levelColor(String levelStr) {
    switch (levelStr) {
      case 'Acquise':
        return const Color(0xFF00C853);
      case 'En cours':
        return const Color(0xFFFFA726);
      case 'À renforcer':
        return const Color(0xFFEF5350);
      default:
        return TeacherTheme.mutedText;
    }
  }

  IconData _levelIcon(String levelStr) {
    switch (levelStr) {
      case 'Acquise':
        return Icons.check_circle;
      case 'En cours':
        return Icons.timelapse;
      case 'À renforcer':
        return Icons.warning_amber_rounded;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    final color = _levelColor(_levelStr);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: TeacherTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header (always visible)
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.star, color: color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.criterionName,
                          style: TextStyle(
                            fontFamily: TeacherTheme.fontName,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: TeacherTheme.lightText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(_levelIcon(_levelStr), size: 14, color: color),
                            const SizedBox(width: 4),
                            Text(
                              _levelStr,
                              style: TextStyle(
                                fontFamily: TeacherTheme.fontName,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: TeacherTheme.mutedText,
                  ),
                ],
              ),
            ),
          ),
          // Expanded Content
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Text(
                    'Évaluer le niveau',
                    style: TextStyle(
                      fontFamily: TeacherTheme.fontName,
                      fontSize: 13,
                      color: TeacherTheme.mutedText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: availableLevels.map((lvl) {
                      final isSelected = _levelStr == lvl;
                      final lColor = _levelColor(lvl);
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _levelStr = lvl);
                            widget.onChanged(_levelStr, _commentCtrl.text);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? lColor : lColor.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? lColor : lColor.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  _levelIcon(lvl),
                                  size: 18,
                                  color: isSelected ? Colors.white : lColor,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  lvl,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : lColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  // Comment Area
                  Container(
                    decoration: BoxDecoration(
                      color: TeacherTheme.baseDark.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ThemeColors.glassBorderSubtle),
                    ),
                    child: TextField(
                      controller: _commentCtrl,
                      maxLines: 2,
                      style: TextStyle(
                        fontFamily: TeacherTheme.fontName,
                        fontSize: 14,
                        color: TeacherTheme.lightText,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ajouter un commentaire (optionnel)...',
                        hintStyle: TextStyle(
                          color: TeacherTheme.mutedText.withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                        contentPadding: const EdgeInsets.all(12),
                        border: InputBorder.none,
                      ),
                      onChanged: (val) {
                        // We might not want to auto-save on every character here.
                        // But original code didn't have a save button for comment either.
                        // Actually original code only called onChanged in the chipset.
                        // I'll keep it consistent or add a way to save comments.
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => widget.onChanged(_levelStr, _commentCtrl.text),
                      child: const Text('Enregistrer commentaire', style: TextStyle(fontSize: 12)),
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
