import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:newv/app_theme.dart';
import 'package:newv/theme_manager.dart';
import 'package:newv/theme_colors.dart';

// File: glass_text_field.dart
// Purpose: Frosted-glass styled text input for parent details.
// Usage: Used throughout ParentInfoStep.
// API Usage: No.
// Dependencies: AppTheme.

/// A stylized [TextFormField] with backdrop blurring.
class GlassTextField extends StatelessWidget {
  static Color get _lightText => ThemeManager.instance.isLightMode
      ? const Color(0xFF212529)
      : const Color(0xFFF2F0F0);
  static Color get _mutedText => ThemeManager.instance.isLightMode
      ? const Color(0xFF6C757D)
      : const Color(0xFFA1A4AB);
  static Color get _tealAccent => ThemeManager.instance.isLightMode
      ? const Color(0xFF009688)
      : const Color(0xFF4CCEAC);

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final TextInputType keyboardType;
  final int maxLines;

  const GlassTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: ThemeColors.glassBorderSubtle,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ThemeColors.glassBorder, width: 1),
            ),
            child: TextFormField(
              controller: controller,
              obscureText: isPassword,
              keyboardType: keyboardType,
              maxLines: maxLines,
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
                prefixIcon: Icon(icon, color: _mutedText),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
              ),
              cursorColor: _tealAccent,
              validator: (val) =>
                  val == null || val.isEmpty ? 'Champ requis' : null,
            ),
          ),
        ),
      ),
    );
  }
}
