import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:newv/app_theme.dart';
import 'package:newv/theme_manager.dart';
import 'package:newv/theme_colors.dart';

// File: child_glass_dropdown.dart
// Purpose: Transparent dropdown field for registration options.
// Usage: Used for Inscription Type and Meal Plan in ChildRegistrationForm.
// API Usage: No.
// Dependencies: AppTheme.

/// A glass-styled dropdown menu allowing selection from a list of options.
class ChildGlassDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String Function(String)? itemLabelBuilder;

  const ChildGlassDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemLabelBuilder,
  });

  static Color get _baseDark => ThemeManager.instance.isLightMode
      ? const Color(0xFFF0F2F5)
      : const Color(0xFF141B2D);
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: ThemeColors.glassBorderSubtle,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ThemeColors.glassBorder, width: 1),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            dropdownColor: _baseDark,
            iconEnabledColor: _tealAccent,
            style: TextStyle(
              color: _lightText,
              fontSize: 14,
              fontFamily: AppTheme.fontName,
            ),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: _mutedText.withValues(alpha: 0.8)),
              border: InputBorder.none,
            ),
            initialValue: value,
            items: items
                .map(
                  (option) => DropdownMenuItem<String>(
                    value: option,
                    child: Text(
                      itemLabelBuilder != null
                          ? itemLabelBuilder!(option)
                          : option,
                      softWrap: true,
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
