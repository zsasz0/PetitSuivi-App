import 'package:flutter/material.dart';
import '../../components/common/glass_role_selector.dart';

class LoginRoleSelector extends StatelessWidget {
  final int selectedRole;
  final ValueChanged<int> onRoleChanged;

  const LoginRoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassRoleSelector(
      selectedRole: selectedRole,
      onRoleChanged: onRoleChanged,
    );
  }
}
