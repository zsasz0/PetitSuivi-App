import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/views/themes/theme_manager.dart';
import 'package:newv/views/themes/theme_colors.dart';

// File: glass_text_field.dart
// Purpose: Frosted-glass styled text input.
// Usage: Input fields for Email and Password in LoginPage.
// API Usage: No.
// Dependencies: None.

/// A stylized [TextField] with a backdrop blur and semi-transparent background.
class GlassTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;

  const GlassTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
  });

  @override
  State<GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<GlassTextField> {
  static Color get _lightText => ThemeManager.instance.isLightMode
      ? const Color(0xFF212529)
      : const Color(0xFFF2F0F0);
  static Color get _mutedText => ThemeManager.instance.isLightMode
      ? const Color(0xFF6C757D)
      : const Color(0xFFA1A4AB);
  static Color get _tealAccent => ThemeManager.instance.isLightMode
      ? const Color(0xFF009688)
      : const Color(0xFF4CCEAC);

  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: ThemeColors.glassBorderSubtle,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ThemeColors.glassBorder, width: 1),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              textSelectionTheme: TextSelectionThemeData(
                cursorColor: _tealAccent,
                selectionColor: Color(0x664CCEAC), // Semi-transparent teal
                selectionHandleColor: _tealAccent,
              ),
            ),
            child: TextField(
              controller: widget.controller,
              obscureText: _obscureText,
              keyboardType: widget.isPassword
                  ? TextInputType.visiblePassword
                  : TextInputType.emailAddress,
              textInputAction: widget.isPassword
                  ? TextInputAction.done
                  : TextInputAction.next,
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                color: _lightText,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: widget.label,
                hintStyle: TextStyle(
                  fontFamily: AppTheme.fontName,
                  color: _mutedText.withValues(alpha: 0.8),
                ),
                prefixIcon: Icon(widget.icon, color: _mutedText),
                suffixIcon: widget.isPassword
                    ? IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: _mutedText,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
              ),
              cursorColor: _tealAccent,
            ),
          ),
        ),
      ),
    );
  }
}
