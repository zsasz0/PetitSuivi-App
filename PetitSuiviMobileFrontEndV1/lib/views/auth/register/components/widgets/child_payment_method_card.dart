import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:newv/app_theme.dart';
import 'package:newv/theme_manager.dart';
import 'package:newv/theme_colors.dart';

// File: child_payment_method_card.dart
// Purpose: Visual selection card for payment frequency.
// Usage: Option card in ChildRegistrationForm.
// API Usage: No.
// Dependencies: AppTheme.

/// A decorative card used to select between 'Annual' or 'Monthly' payments.
class ChildPaymentMethodCard extends StatelessWidget {
  final String value;
  final String title;
  final String subtitle;
  final IconData icon;
  final String? selectedValue;
  final ValueChanged<String> onTap;

  const ChildPaymentMethodCard({
    super.key,
    required this.value,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selectedValue,
    required this.onTap,
  });

  static Color get _indigoAccent => ThemeManager.instance.isLightMode
      ? const Color(0xFF3F51B5)
      : const Color(0xFF6870FA);
  static Color get _lightText => ThemeManager.instance.isLightMode
      ? const Color(0xFF212529)
      : const Color(0xFFF2F0F0);
  static Color get _mutedText => ThemeManager.instance.isLightMode
      ? const Color(0xFF6C757D)
      : const Color(0xFFA1A4AB);

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    final bool isSelected = selectedValue == value;
    return InkWell(
      onTap: () => onTap(value),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? _indigoAccent.withValues(alpha: 0.15)
              : ThemeColors.glassBorderSubtle,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _indigoAccent : ThemeColors.glassBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _indigoAccent.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? _indigoAccent : _mutedText,
              size: 28,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? _lightText : _mutedText,
                fontFamily: AppTheme.fontName,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: _mutedText.withValues(alpha: 0.7),
                fontFamily: AppTheme.fontName,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
