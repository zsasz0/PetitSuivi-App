import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/views/themes/theme_manager.dart';
import '../../themes/register_theme.dart';

/// A stylized [TextFormField] with backdrop blurring.
class GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final TextInputType keyboardType;
  final int maxLines;
  final String? errorText;

  const GlassTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.errorText,
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
              color: RegisterTheme.glassBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: RegisterTheme.glassBorder, width: 1),
            ),
            child: TextFormField(
              controller: controller,
              obscureText: isPassword,
              keyboardType: keyboardType,
              maxLines: maxLines,
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
                prefixIcon: Icon(icon, color: RegisterTheme.mutedText),
                border: InputBorder.none,
                errorText: errorText,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
              ),
              cursorColor: RegisterTheme.tealAccent,
              validator: (val) =>
                  val == null || val.isEmpty ? 'Champ requis' : null,
            ),
          ),
        ),
      ),
    );
  }
}
