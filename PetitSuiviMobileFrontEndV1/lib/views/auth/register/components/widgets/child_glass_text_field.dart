import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:newv/app_theme.dart';
import 'package:newv/theme_manager.dart';
import 'package:newv/theme_colors.dart';

// File: child_glass_text_field.dart
// Purpose: Specialized glass text field for child details.
// Usage: Input fields for names and other text data in ChildRegistrationForm.
// API Usage: No.
// Dependencies: AppTheme.

/// A stylized text input field with a frosted-glass appearance.
class ChildGlassTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final IconData? icon;
  final ValueChanged<String>? onChanged;

  const ChildGlassTextField({
    super.key,
    this.controller,
    required this.label,
    this.icon,
    this.onChanged,
  });

  static Color get _lightText => ThemeManager.instance.isLightMode
      ? const Color(0xFF212529)
      : const Color(0xFFF2F0F0);
  static Color get _mutedText => ThemeManager.instance.isLightMode
      ? const Color(0xFF6C757D)
      : const Color(0xFFA1A4AB);
  static Color get _tealAccent => ThemeManager.instance.isLightMode
      ? const Color(0xFF009688)
      : const Color(0xFF4CCEAC);

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: ThemeColors.glassBorderSubtle,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ThemeColors.glassBorder, width: 1),
        ),
        child: TextFormField(
          controller: controller,
          style: TextStyle(
            fontFamily: AppTheme.fontName,
            color: _lightText,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              fontFamily: AppTheme.fontName,
              color: _mutedText.withValues(alpha: 0.8),
            ),
            suffixIcon: icon != null ? Icon(icon, color: _mutedText) : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          cursorColor: _tealAccent,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
