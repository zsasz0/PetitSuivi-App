import 'package:flutter/material.dart';
import 'package:newv/views/themes/theme_colors.dart';
import 'package:newv/views/parent/profile/themes/profile_theme.dart';

class ChangePasswordDialog extends StatefulWidget {
  final Future<void> Function(String, ScaffoldMessengerState) onSubmit;

  const ChangePasswordDialog({super.key, required this.onSubmit});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  String _newPassword = '';
  String _confirmPassword = '';
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    // Capture from context
    final outerMessenger = ScaffoldMessenger.of(context);

    return AlertDialog(
      backgroundColor: ProfileTheme.baseDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: ThemeColors.glassBorder),
      ),
      title: Text(
        'Changer mot de passe',
        style: TextStyle(color: ProfileTheme.lightText),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            onChanged: (val) => _newPassword = val,
            obscureText: true,
            style: TextStyle(color: ProfileTheme.lightText),
            decoration: InputDecoration(
              labelText: 'Nouveau mot de passe',
              labelStyle: TextStyle(color: ProfileTheme.mutedText),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: ProfileTheme.glassBorderWithOpacity(0.3),
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: ProfileTheme.tealAccent),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (val) => _confirmPassword = val,
            obscureText: true,
            style: TextStyle(color: ProfileTheme.lightText),
            decoration: InputDecoration(
              labelText: 'Confirmer le mot de passe',
              labelStyle: TextStyle(color: ProfileTheme.mutedText),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: ProfileTheme.glassBorderWithOpacity(0.3),
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: ProfileTheme.tealAccent),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: Text('Annuler', style: TextStyle(color: ProfileTheme.mutedText)),
        ),
        ElevatedButton(
          onPressed: _isSaving
              ? null
              : () async {
                  final pwd = _newPassword.trim();

                  if (pwd.isEmpty) {
                    outerMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Le mot de passe ne peut pas être vide.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  if (pwd.length < 8) {
                    outerMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Le mot de passe doit contenir au moins 8 caractères.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  if (!pwd.contains(RegExp(r'[A-Z]'))) {
                    outerMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Le mot de passe doit contenir au moins une lettre majuscule.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }
                  if (!pwd.contains(RegExp(r'[a-z]'))) {
                    outerMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Le mot de passe doit contenir au moins une lettre minuscule.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }
                  if (!pwd.contains(RegExp(r'[0-9]'))) {
                    outerMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Le mot de passe doit contenir au moins un chiffre.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }
                  if (!pwd.contains(RegExp(r'[^A-Za-z0-9]'))) {
                    outerMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Le mot de passe doit contenir au moins un symbole.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  if (pwd != _confirmPassword.trim()) {
                    outerMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Les deux mots de passe doivent être identiques.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  setState(() => _isSaving = true);

                  await widget.onSubmit(pwd, outerMessenger);

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: ProfileTheme.indigoAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Changer',
                  style: TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }
}
