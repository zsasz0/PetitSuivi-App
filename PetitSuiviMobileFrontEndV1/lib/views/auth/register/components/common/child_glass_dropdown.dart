import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/views/themes/theme_manager.dart';
import '../../themes/register_theme.dart';

/// A glass-styled dropdown menu allowing selection from a list of options.
class ChildGlassDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String Function(String)? itemLabelBuilder;

  const ChildGlassDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemLabelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: RegisterTheme.glassBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: RegisterTheme.glassBorder, width: 1),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            dropdownColor: RegisterTheme.baseDark,
            iconEnabledColor: RegisterTheme.tealAccent,
            style: TextStyle(
              color: RegisterTheme.lightText,
              fontSize: 14,
              fontFamily: AppTheme.fontName,
            ),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: RegisterTheme.mutedText.withValues(alpha: 0.8)),
              border: InputBorder.none,
            ),
            initialValue: value,
            items: items
                .map(
                  (option) => DropdownMenuItem<String>(
                    value: option,
                    child: Text(
                      itemLabelBuilder != null
                          ? itemLabelBuilder!(option)
                          : option,
                      softWrap: true,
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
