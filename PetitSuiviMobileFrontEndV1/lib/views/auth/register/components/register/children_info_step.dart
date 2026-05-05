import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/views/themes/theme_manager.dart';
import '../../themes/register_theme.dart';
import 'child_registration_form.dart';

/// Step 2 of the registration wizard containing the list of children.
class ChildrenInfoStep extends StatelessWidget {
  final List<Map<String, dynamic>> children;
  final List<String> paymentMethods;
  final Function(int) onRemoveChild;
  final VoidCallback onAddChild;
  final String parentAddress;
  final int totalChildren;

  const ChildrenInfoStep({
    super.key,
    required this.children,
    required this.paymentMethods,
    required this.onRemoveChild,
    required this.onAddChild,
    this.parentAddress = '',
    this.totalChildren = 1,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return ListView(
      key: const ValueKey('step1'),
      padding: const EdgeInsets.all(24.0),
      children: [
        Text(
          "Informations des Enfants",
          style: TextStyle(
            color: RegisterTheme.lightText,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            fontFamily: AppTheme.fontName,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${children.length} Enfant(s) ajouté(s)',
          style: TextStyle(color: RegisterTheme.tealAccent, fontSize: 16),
        ),
        const SizedBox(height: 24),
        ...children.asMap().entries.map((entry) {
          final index = entry.key;
          return Column(
            children: [
              ChildRegistrationForm(
                index: index,
                childData: entry.value,
                paymentMethods: paymentMethods,
                parentAddress: parentAddress,
                totalChildren: totalChildren,
              ),
              if (children.length > 1)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => onRemoveChild(index),
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    label: const Text(
                      'Retirer',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          );
        }),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.center,
          child: TextButton.icon(
            onPressed: onAddChild,
            icon: Icon(Icons.add_circle_outline, color: RegisterTheme.accentColor),
            label: Text(
              'Ajouter un autre enfant',
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                fontWeight: FontWeight.bold,
                color: RegisterTheme.accentColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }
}
