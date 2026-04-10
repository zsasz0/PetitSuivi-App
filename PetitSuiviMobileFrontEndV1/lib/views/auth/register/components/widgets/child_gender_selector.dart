import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:newv/app_theme.dart';
import 'package:newv/theme_manager.dart';
import 'package:newv/theme_colors.dart';

// File: child_gender_selector.dart
// Purpose: Interactive card to select a child's gender.
// Usage: Component of ChildRegistrationForm.
// API Usage: No.
// Dependencies: AppTheme.

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

  static Color get _tealAccent => ThemeManager.instance.isLightMode
      ? const Color(0xFF009688)
      : const Color(0xFF4CCEAC);
  static Color get _lightText => ThemeManager.instance.isLightMode
      ? const Color(0xFF212529)
      : const Color(0xFFF2F0F0);
  static Color get _mutedText => ThemeManager.instance.isLightMode
      ? const Color(0xFF6C757D)
      : const Color(0xFFA1A4AB);

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
              ? _tealAccent.withValues(alpha: 0.15)
              : ThemeColors.glassBorderSubtle,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _tealAccent : ThemeColors.glassBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? _tealAccent : _mutedText),
            const SizedBox(height: 4),
            Text(
              gender,
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? _lightText : _mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
