import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/views/themes/theme_colors.dart';
import 'package:newv/views/parent/photos/themes/photos_theme.dart';

class ChildSelector extends StatelessWidget {
  final List<Map<String, dynamic>> children;
  final String? selectedChildId;
  final ValueChanged<String?> onChanged;

  const ChildSelector({
    super.key,
    required this.children,
    required this.selectedChildId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: ThemeColors.glassBorderSubtle,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ThemeColors.glassBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedChildId,
              dropdownColor: PhotosTheme.baseDark.withValues(alpha: 0.95),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: PhotosTheme.tealAccent,
              ),
              hint: Text(
                'Choisir un enfant',
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  color: PhotosTheme.mutedText,
                ),
              ),
              items: children
                  .map(
                    (child) => DropdownMenuItem<String>(
                      value: child['id'].toString(),
                      child: Text(
                        '${child['firstName'] ?? ''} ${child['lastName'] ?? ''}'
                            .trim(),
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontWeight: FontWeight.w600,
                          color: PhotosTheme.lightText,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );
  }
}
