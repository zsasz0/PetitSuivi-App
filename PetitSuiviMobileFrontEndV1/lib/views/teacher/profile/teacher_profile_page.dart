/// teacher_profile_page.dart
///
/// Comprehensive profile page for teachers showing personal information,
/// class/child statistics, password management, profile editing, and logout.
///
/// ## State Management
/// - [_TeacherProfilePageState] fetches class/student counts on init and
///   reads personal data from [AuthSession].
/// - Password change and profile edit are handled via modal dialogs with
///   inline validation and loading states.
///
/// ## Backend API Endpoints
///
/// ### GET /api/teachers/{cin}/classes
/// Fetches teacher's classes with nested student lists to compute stats.
/// - **Headers:** `Authorization: Bearer {token}`
/// - **Response 200:**
/// ```json
/// {
///   "data": [
///     { "id": 1, "name": "Moyenne Section B", "students": [ { "id": 8 } ] }
///   ]
/// }
/// ```
///
/// ### POST /api/password/change
/// Changes the authenticated teacher's password.
/// - **Headers:** `Authorization: Bearer {token}`, `Content-Type: application/json`
/// - **Body:** `{ "new_password": "NewStr0ng!Pass" }`
/// - **Response 200:** `{ "message": "Mot de passe modifié." }`
/// - **Validation:** min 8 chars, 1 uppercase, 1 lowercase, 1 digit, 1 symbol.
///
/// ### PUT /api/teachers/{cin}/profile
/// Updates teacher personal information.
/// - **Headers:** `Authorization: Bearer {token}`, `Content-Type: application/json`
/// - **Body:**
/// ```json
/// {
///   "firstName": "Fatma", "lastName": "Mrad",
///   "email": "fatma@example.com", "phone": "12345678",
///   "adresse": "Tunis, Tunisia"
/// }
/// ```
/// - **Response 200:** `{ "message": "Profile updated." }`
///
/// ## Dependencies
/// [AuthSession], [TeacherTheme], [ThemeColors], [UnauthorizedHandler],
/// [ApiConstants], [ThemeManager], [LoginPage].
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:newv/models/auth_session.dart';
import 'package:newv/theme_colors.dart';
import 'package:newv/theme_manager.dart';
import 'package:newv/utils/api_constants.dart';
import 'package:newv/utils/unauthorized_handler.dart';
import 'package:newv/views/auth/login/login_page.dart';
import 'package:newv/views/teacher/teacher_theme.dart';
import 'package:provider/provider.dart';

class TeacherProfilePage extends StatefulWidget {
  const TeacherProfilePage({super.key});

  @override
  State<TeacherProfilePage> createState() => _TeacherProfilePageState();
}

class _TeacherProfilePageState extends State<TeacherProfilePage> {
  static const String _apiBaseUrl = ApiConstants.baseUrl;

  int _classCount = 0;
  int _enfantCount = 0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchStats());
  }

  Future<void> _fetchStats() async {
    final session = context.read<AuthSession>();
    final token = session.token;
    final teacherCin = session.cin;

    if (token == null || token.isEmpty || teacherCin == null) {
      if (mounted) setState(() => _isLoadingStats = false);
      return;
    }

    final uri = Uri.parse('$_apiBaseUrl/api/teachers/$teacherCin/classes');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};
        final data = body['data'];

        if (data is List) {
          int totalClasses = data.length;
          int totalStudents = 0;
          for (var c in data) {
            if (c is Map && c['students'] is List) {
              totalStudents += (c['students'] as List).length;
            }
          }
          setState(() {
            _classCount = totalClasses;
            _enfantCount = totalStudents;
            _isLoadingStats = false;
          });
          return;
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoadingStats = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    final session = context.watch<AuthSession>();
    final firstName = (session.firstName?.isNotEmpty ?? false)
        ? session.firstName!
        : '';
    final lastName = (session.lastName?.isNotEmpty ?? false)
        ? session.lastName!
        : '';
    final fullName = '$firstName $lastName'.trim();
    final email = (session.email?.isNotEmpty ?? false) ? session.email! : '';
    final phone = (session.phone?.isNotEmpty ?? false) ? session.phone! : '';
    final address = (session.address?.isNotEmpty ?? false)
        ? session.address!
        : '-';
    final age = _calculateAge(session.birthdate);
    final yearsOfTeaching = _calculateYearsOfTeachingFromInscriptionDate(
      session.inscriptionDate,
    );

    return Scaffold(
      backgroundColor: TeacherTheme.baseDark,
      appBar: AppBar(
        title: Text(
          'Mon Profil',
          style: TextStyle(
            fontFamily: TeacherTheme.fontName,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: TeacherTheme.lightText,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios, color: TeacherTheme.lightText),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: EdgeInsets.only(
          bottom: 100 + MediaQuery.of(context).padding.bottom,
        ),
        children: [
          const SizedBox(height: 16),
          // Profile Header
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: TeacherTheme.tealAccent.withValues(alpha: 0.5),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: TeacherTheme.tealAccent.withValues(alpha: 0.2),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: TeacherTheme.surfaceDark,
                  child: Text(
                    '${firstName.isNotEmpty ? firstName[0] : 'U'}${lastName.isNotEmpty ? lastName[0] : ''}',
                    style: TextStyle(
                      fontFamily: TeacherTheme.fontName,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: TeacherTheme.tealAccent,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                fullName.isNotEmpty ? fullName : 'Teacher',
                style: TextStyle(
                  fontFamily: TeacherTheme.fontName,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: TeacherTheme.lightText,
                ),
              ),
              Text(
                'Enseignant',
                style: TextStyle(
                  fontFamily: TeacherTheme.fontName,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: TeacherTheme.mutedText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Info Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: TeacherTheme.surfaceCard(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.email, 'Email', email),
                    Divider(color: ThemeColors.glassBorderSubtle),
                    _buildInfoRow(Icons.phone, 'Téléphone', phone),
                    Divider(color: ThemeColors.glassBorderSubtle),
                    _buildInfoRow(Icons.location_on, 'Adresse', address),
                    Divider(color: ThemeColors.glassBorderSubtle),
                    _buildInfoRow(
                      Icons.work_history,
                      'Années d\'enseignement',
                      yearsOfTeaching > 0 ? '$yearsOfTeaching ans' : '-',
                    ),
                    Divider(color: ThemeColors.glassBorderSubtle),
                    _buildInfoRow(
                      Icons.cake,
                      'Âge',
                      age > 0 ? '$age ans' : '-',
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Stats cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    _isLoadingStats ? '-' : '$_classCount',
                    'Classes',
                    Icons.class_,
                    TeacherTheme.tealAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    _isLoadingStats ? '-' : '$_enfantCount',
                    'Enfants',
                    Icons.child_care,
                    TeacherTheme.indigoAccent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // _buildButton(
                //   'Modifier le profil (Désactivé)',
                //   Icons.edit,
                //   null,
                // ),
                // const SizedBox(height: 16),
                // _buildButton(
                //   'Modifier le profil',
                //   Icons.edit,
                //   () => _showEditProfileDialog(context),
                // ),
                // const SizedBox(height: 16),
                _buildButton(
                  'Changer le mot de passe',
                  Icons.lock,
                  () => _showChangePasswordDialog(context),
                ),
                const SizedBox(height: 16),
                _buildButton(
                  'Déconnexion',
                  Icons.logout,
                  () => _handleLogout(context),
                  customColor: Colors.redAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: TeacherTheme.tealAccent, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: TeacherTheme.fontName,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: TeacherTheme.mutedText,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: TeacherTheme.fontName,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: TeacherTheme.lightText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: TeacherTheme.fontName,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: TeacherTheme.fontName,
              fontSize: 14,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    String text,
    IconData icon,
    VoidCallback? onTap, {
    Color? customColor,
  }) {
    final c = customColor ?? TeacherTheme.tealAccent;
    return Container(
      width: double.infinity,
      height: 48,
      decoration: TeacherTheme.surfaceCard(borderRadius: 12).copyWith(
        color: onTap == null ? Colors.grey.withValues(alpha: 0.1) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: c),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: TextStyle(
                    fontFamily: TeacherTheme.fontName,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: c,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    context.read<AuthSession>().clear();
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  int _calculateAge(String? birthDateString) {
    if (birthDateString == null || birthDateString.isEmpty) return 0;
    try {
      final birthDate = DateTime.parse(birthDateString);
      final today = DateTime.now();
      var age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return 0;
    }
  }

  int _calculateYearsOfTeachingFromInscriptionDate(
    String? inscriptionDateString,
  ) {
    if (inscriptionDateString == null || inscriptionDateString.isEmpty) {
      return 0;
    }
    try {
      final startDate = DateTime.parse(inscriptionDateString);
      final today = DateTime.now();
      var years = today.year - startDate.year;
      if (today.month < startDate.month ||
          (today.month == startDate.month && today.day < startDate.day)) {
        years--;
      }
      return years < 0 ? 0 : years;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    String newPassword = '';
    String confirmPassword = '';
    bool isSaving = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: TeacherTheme.cardDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Changer le mot de passe',
              style: TextStyle(color: TeacherTheme.lightText),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (val) => newPassword = val,
                  obscureText: true,
                  style: TextStyle(color: TeacherTheme.lightText),
                  decoration: InputDecoration(
                    labelText: 'Nouveau mot de passe',
                    labelStyle: TextStyle(color: TeacherTheme.mutedText),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: ThemeColors.glassBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: TeacherTheme.tealAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (val) => confirmPassword = val,
                  obscureText: true,
                  style: TextStyle(color: TeacherTheme.lightText),
                  decoration: InputDecoration(
                    labelText: 'Confirmer le mot de passe',
                    labelStyle: TextStyle(color: TeacherTheme.mutedText),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: ThemeColors.glassBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: TeacherTheme.tealAccent),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(dialogCtx),
                child: Text(
                  'Annuler',
                  style: TextStyle(color: TeacherTheme.mutedText),
                ),
              ),
              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        final pwd = newPassword.trim();

                        if (pwd.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Le mot de passe ne peut pas être vide.',
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        if (pwd.length < 8) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Le mot de passe doit contenir au moins 8 caractères.',
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        if (!pwd.contains(RegExp(r'[A-Z]'))) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Le mot de passe doit contenir au moins une lettre majuscule.',
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }
                        if (!pwd.contains(RegExp(r'[a-z]'))) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Le mot de passe doit contenir au moins une lettre minuscule.',
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }
                        if (!pwd.contains(RegExp(r'[0-9]'))) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Le mot de passe doit contenir au moins un chiffre.',
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }
                        if (!pwd.contains(RegExp(r'[^A-Za-z0-9]'))) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Le mot de passe doit contenir au moins un symbole.',
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        if (pwd != confirmPassword.trim()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Les deux mots de passe doivent être identiques.',
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        setState(() => isSaving = true);
                        final changed = await _changePassword(
                          context: context,
                          newPassword: pwd,
                        );
                        if (!context.mounted) return;
                        if (changed) {
                          Navigator.pop(dialogCtx);
                        } else {
                          setState(() => isSaving = false);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TeacherTheme.tealAccent,
                  foregroundColor: TeacherTheme.baseDark,
                ),
                child: isSaving
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: TeacherTheme.baseDark,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Changer'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<bool> _changePassword({
    required BuildContext context,
    required String newPassword,
  }) async {
    final session = context.read<AuthSession>();
    final token = session.token;

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session invalide. Reconnectez-vous.')),
      );
      return false;
    }

    final uri = Uri.parse('$_apiBaseUrl/api/password/change');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'new_password': newPassword}),
      );

      if (!context.mounted) return false;
      if (UnauthorizedHandler.handle(
        context: context,
        statusCode: response.statusCode,
      )) {
        return false;
      }

      final body = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              body['message']?.toString() ?? 'Mot de passe modifié.',
            ),
          ),
        );
        return true;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            body['message']?.toString() ??
                'Échec du changement de mot de passe.',
          ),
        ),
      );
      return false;
    } catch (_) {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erreur réseau.')));
      return false;
    }
  }

  


}
