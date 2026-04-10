import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:newv/app_theme.dart';
import 'child_registration_form.dart';
import 'package:newv/theme_manager.dart';

/// Step 2 of the registration wizard containing the list of children.
///
/// This widget handles rendering a `ChildRegistrationForm` for each
/// child added by the user. It passes down parameters and handles
/// adding or removing additional child sections.

/// Step 2 of the registration process: Collecting information about the children.
///
/// This widget iterates over a list of child data maps and renders a
/// [ChildRegistrationForm] for each one.
///
/// It receives [parentAddress] and computes [totalChildren] from the list of
/// children to pass down to each [ChildRegistrationForm] to allow the
/// medical record page to intelligently pre-fill its fields with sensible
/// defaults or parent-derived data (e.g., address, birth order).
class ChildrenInfoStep extends StatelessWidget {
  static Color get _lightText => ThemeManager.instance.isLightMode ? const Color(0xFF212529) : const Color(0xFFF2F0F0);
  static Color get _tealAccent => ThemeManager.instance.isLightMode ? const Color(0xFF009688) : const Color(0xFF4CCEAC);
  static Color get _indigoAccent => ThemeManager.instance.isLightMode ? const Color(0xFF3F51B5) : const Color(0xFF6870FA);

  final List<Map<String, dynamic>> children;
  final List<String> paymentMethods;
  final Function(int) onRemoveChild;
  final VoidCallback onAddChild;

  /// The parent's address, passed down to pre-fill the child's medical record.
  final String parentAddress;

  /// The total number of children, passed down to calculate the child's position
  /// among siblings (Only Child, Eldest, Youngest, Middle).
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
            color: _lightText,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            fontFamily: AppTheme.fontName,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${children.length} Enfant(s) ajouté(s)',
          style: TextStyle(color: _tealAccent, fontSize: 16),
        ),
        const SizedBox(height: 24),
        ...children.asMap().entries.map((entry) {
          final index = entry.key;
          return Column(
            children: [
              // used to build the child registration form
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
            icon: Icon(Icons.add_circle_outline, color: _indigoAccent),
            label: Text(
              'Ajouter un autre enfant',
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                fontWeight: FontWeight.bold,
                color: _indigoAccent,
              ),
            ),
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }
}
