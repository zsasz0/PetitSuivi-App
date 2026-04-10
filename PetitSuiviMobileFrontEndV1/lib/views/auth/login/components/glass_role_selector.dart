import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:newv/app_theme.dart';
import 'package:newv/theme_manager.dart';
import 'package:newv/theme_colors.dart';

// File: glass_role_selector.dart
// Purpose: Interactive toggle to switch between Parent and Teacher roles.
// Usage: Role selection toggle in LoginPage.
// API Usage: No.
// Dependencies: None.

/// A glass-styled role selector with Parent and Teacher options.
class GlassRoleSelector extends StatelessWidget {
  final int selectedRole;
  final ValueChanged<int> onRoleChanged;

  static Color get _indigoAccent => ThemeManager.instance.isLightMode
      ? const Color(0xFF3F51B5)
      : const Color(0xFF6870FA);
  static Color get _mutedText => ThemeManager.instance.isLightMode
      ? const Color(0xFF6C757D)
      : const Color(0xFFA1A4AB);

  const GlassRoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: ThemeColors.glassBorderSubtle,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ThemeColors.glassBorder, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildRoleOption(
                  label: 'Parent',
                  icon: Icons.family_restroom_outlined,
                  role: 2,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRoleOption(
                  label: 'Enseignant',
                  icon: Icons.school_outlined,
                  role: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption({
    required String label,
    required IconData icon,
    required int role,
  }) {
    final isSelected = selectedRole == role;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onRoleChanged(role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? _indigoAccent.withValues(alpha: 0.7)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: isSelected ? Colors.white : _mutedText),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : _mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
