import 'package:flutter/material.dart';
import 'package:newv/views/themes/theme_colors.dart';
import 'package:newv/views/teacher/profile/controllers/teacher_profile_controller.dart';
import 'package:newv/views/teacher/profile/themes/teacher_profile_theme.dart';

class ChangePasswordDialog extends StatefulWidget {
  final TeacherProfileController controller;

  const ChangePasswordDialog({
    super.key,
    required this.controller,
  });

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  String _newPassword = '';
  String _confirmPassword = '';
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: TeacherProfileTheme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        'Changer le mot de passe',
        style: TextStyle(color: TeacherProfileTheme.textColor),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            onChanged: (val) => _newPassword = val,
            obscureText: true,
            style: TextStyle(color: TeacherProfileTheme.textColor),
            decoration: InputDecoration(
              labelText: 'Nouveau mot de passe',
              labelStyle: TextStyle(color: TeacherProfileTheme.mutedTextColor),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: ThemeColors.glassBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: TeacherProfileTheme.primaryColor),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (val) => _confirmPassword = val,
            obscureText: true,
            style: TextStyle(color: TeacherProfileTheme.textColor),
            decoration: InputDecoration(
              labelText: 'Confirmer le mot de passe',
              labelStyle: TextStyle(color: TeacherProfileTheme.mutedTextColor),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: ThemeColors.glassBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: TeacherProfileTheme.primaryColor),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: Text(
            'Annuler',
            style: TextStyle(color: TeacherProfileTheme.mutedTextColor),
          ),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _handleChangePassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: TeacherProfileTheme.primaryColor,
            foregroundColor: TeacherProfileTheme.backgroundColor,
          ),
          child: _isSaving
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: TeacherProfileTheme.backgroundColor,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Changer'),
        ),
      ],
    );
  }

  Future<void> _handleChangePassword() async {
    final pwd = _newPassword.trim();

    if (pwd.isEmpty) {
      _showSnackBar('Le mot de passe ne peut pas être vide.');
      return;
    }

    if (pwd.length < 8) {
      _showSnackBar('Le mot de passe doit contenir au moins 8 caractères.');
      return;
    }

    if (!pwd.contains(RegExp(r'[A-Z]'))) {
      _showSnackBar('Le mot de passe doit contenir au moins une lettre majuscule.');
      return;
    }
    if (!pwd.contains(RegExp(r'[a-z]'))) {
      _showSnackBar('Le mot de passe doit contenir au moins une lettre minuscule.');
      return;
    }
    if (!pwd.contains(RegExp(r'[0-9]'))) {
      _showSnackBar('Le mot de passe doit contenir au moins un chiffre.');
      return;
    }
    if (!pwd.contains(RegExp(r'[^A-Za-z0-9]'))) {
      _showSnackBar('Le mot de passe doit contenir au moins un symbole.');
      return;
    }

    if (pwd != _confirmPassword.trim()) {
      _showSnackBar('Les deux mots de passe doivent être identiques.');
      return;
    }

    setState(() => _isSaving = true);
    final changed = await widget.controller.changePassword(pwd);
    
    if (!mounted) return;
    
    if (changed) {
      Navigator.pop(context);
    } else {
      setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
