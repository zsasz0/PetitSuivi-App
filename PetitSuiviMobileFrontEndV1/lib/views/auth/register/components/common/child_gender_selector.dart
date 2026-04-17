import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/views/themes/theme_manager.dart';
import '../../themes/register_theme.dart';

/// A decorative gender selection card with animated states.
class ChildGenderSelector extends StatelessWidget {
  final String gender;
  final IconData icon;
  final String? selectedGender;
  final ValueChanged<String> onTap;

  const ChildGenderSelector({
    super.key,
    required this.gender,
    required this.icon,
    required this.selectedGender,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    final bool isSelected = selectedGender == gender;
    return InkWell(
      onTap: () => onTap(gender),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? RegisterTheme.tealAccent.withValues(alpha: 0.15)
              : RegisterTheme.glassBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? RegisterTheme.tealAccent : RegisterTheme.glassBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? RegisterTheme.tealAccent : RegisterTheme.mutedText),
            const SizedBox(height: 4),
            Text(
              gender,
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? RegisterTheme.lightText : RegisterTheme.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
