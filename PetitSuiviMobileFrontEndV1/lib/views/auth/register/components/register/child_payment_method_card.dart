import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/views/themes/theme_manager.dart';
import '../../themes/register_theme.dart';

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
              ? RegisterTheme.accentColor.withValues(alpha: 0.15)
              : RegisterTheme.glassBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? RegisterTheme.accentColor : RegisterTheme.glassBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: RegisterTheme.accentColor.withValues(alpha: 0.2),
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
              color: isSelected ? RegisterTheme.accentColor : RegisterTheme.mutedText,
              size: 28,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? RegisterTheme.lightText : RegisterTheme.mutedText,
                fontFamily: AppTheme.fontName,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: RegisterTheme.mutedText.withValues(alpha: 0.7),
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
