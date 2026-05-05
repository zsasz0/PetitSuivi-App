import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/views/themes/theme_manager.dart';
import '../../themes/register_theme.dart';

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

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: RegisterTheme.glassBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: RegisterTheme.glassBorder, width: 1),
        ),
        child: TextFormField(
          controller: controller,
          style: TextStyle(
            fontFamily: AppTheme.fontName,
            color: RegisterTheme.lightText,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              fontFamily: AppTheme.fontName,
              color: RegisterTheme.mutedText.withValues(alpha: 0.8),
            ),
            suffixIcon: icon != null ? Icon(icon, color: RegisterTheme.mutedText) : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          cursorColor: RegisterTheme.tealAccent,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
