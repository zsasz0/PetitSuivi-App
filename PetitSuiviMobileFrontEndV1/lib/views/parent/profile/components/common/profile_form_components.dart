import 'package:flutter/material.dart';
import 'package:newv/views/themes/theme_colors.dart';
import 'package:newv/views/parent/profile/themes/profile_theme.dart';

class ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  final void Function(String)? onChanged;

  const ProfileTextField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(color: ProfileTheme.lightText),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: ProfileTheme.mutedText, fontSize: 14),
        filled: true,
        fillColor: ThemeColors.glassBackgroundSubtle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}

class ProfileDropdown extends StatelessWidget {
  final String? value;
  final String label;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String Function(String) labelMapper;

  const ProfileDropdown({
    super.key,
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
    required this.labelMapper,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: value,
      dropdownColor: ProfileTheme.baseDark.withValues(alpha: 0.95),
      icon: Icon(Icons.arrow_drop_down, color: ProfileTheme.mutedText),
      style: TextStyle(color: ProfileTheme.lightText),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: ProfileTheme.mutedText, fontSize: 14),
        filled: true,
        fillColor: ThemeColors.glassBackgroundSubtle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            labelMapper(item),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
