import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:newv/utils/api_constants.dart';

import 'package:newv/app_theme.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/utils/unauthorized_handler.dart';
import 'package:newv/theme_manager.dart';
import 'package:newv/theme_colors.dart';

// File: parent_profile_edit_page.dart
// Purpose: Form for parents to update their own contact information.
// Usage: Navigated from ParentProfilePage.
// API Usage:
//   - PUT /api/parents/{cin}/profile (Update parent details)
// Dependencies: AuthSession, UnauthorizedHandler, ApiConstants, AppTheme.

/// A page providing a form to edit the parent's name, email, phone, and address.
class ParentProfileEditPage extends StatefulWidget {
  const ParentProfileEditPage({super.key});

  @override
  State<ParentProfileEditPage> createState() => _ParentProfileEditPageState();
}

class _ParentProfileEditPageState extends State<ParentProfileEditPage> {
  static const String _apiBaseUrl = ApiConstants.baseUrl;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _isSaving = false;

  // Modern Theme Colors
  static Color get _baseDark => ThemeManager.instance.isLightMode
      ? const Color(0xFFF0F2F5)
      : const Color(0xFF141B2D);
  static Color get _tealAccent => ThemeManager.instance.isLightMode
      ? const Color(0xFF009688)
      : const Color(0xFF4CCEAC);
  static Color get _lightText => ThemeManager.instance.isLightMode
      ? const Color(0xFF212529)
      : const Color(0xFFF2F0F0);
  static Color get _mutedText => ThemeManager.instance.isLightMode
      ? const Color(0xFF6C757D)
      : const Color(0xFFA1A4AB);

  @override
  void initState() {
    super.initState();
    final session = context.read<AuthSession>();
    _nameController = TextEditingController(text: session.fullName);
    _emailController = TextEditingController(text: session.email ?? '');
    _phoneController = TextEditingController(text: session.phone ?? '');
    _addressController = TextEditingController(text: session.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return Container(
      color: _baseDark,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Modifier mon profil',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: _lightText,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close_rounded, color: _lightText),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: _isSaving
                  ? Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: _tealAccent,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : TextButton(
                      onPressed: _saveProfile,
                      style: TextButton.styleFrom(
                        backgroundColor: _tealAccent.withValues(alpha: 0.15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'ENREGISTRER',
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          color: _tealAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informations Personnelles',
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  color: _mutedText,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              _buildGlassForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassForm() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ThemeColors.glassBackgroundSubtle,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ThemeColors.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                'Nom complet',
                _nameController,
                Icons.person_outline_rounded,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                'Email',
                _emailController,
                Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                'Téléphone',
                _phoneController,
                Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                'Adresse',
                _addressController,
                Icons.location_on_outlined,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: _mutedText, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: _lightText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(
            color: _lightText,
            fontSize: 15,
            fontFamily: AppTheme.fontName,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: ThemeColors.glassBorderSubtle,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ThemeColors.glassBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ThemeColors.glassBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _tealAccent),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    final session = context.read<AuthSession>();
    final token = session.token;
    final cin = session.cin;

    if (token == null || token.isEmpty || cin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session invalide. Reconnectez-vous.')),
      );
      return;
    }

    final fullName = _nameController.text.trim();
    final parts = fullName
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    final missing = <String>[];
    if (firstName.isEmpty || lastName.isEmpty) {
      missing.add('Nom complet (prénom et nom)');
    }
    if (_emailController.text.trim().isEmpty) missing.add('Email');
    if (_phoneController.text.trim().isEmpty) missing.add('Téléphone');
    if (_addressController.text.trim().isEmpty) missing.add('Adresse');
    if (missing.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Champ(s) manquant(s) : ${missing.join(', ')}'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final uri = Uri.parse('$_apiBaseUrl/api/parents/$cin/profile');

    try {
      final response = await http.put(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'adresse': _addressController.text.trim(),
        }),
      );

      if (!mounted) return;
      if (UnauthorizedHandler.handle(
        context: context,
        statusCode: response.statusCode,
      )) {
        return;
      }

      final body = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = body['data'] as Map<String, dynamic>?;
        session.updateProfileData(
          firstName: data?['firstName']?.toString() ?? firstName,
          lastName: data?['lastName']?.toString() ?? lastName,
          email: data?['email']?.toString() ?? _emailController.text.trim(),
          phone: data?['phone']?.toString() ?? _phoneController.text.trim(),
          address:
              data?['adresse']?.toString() ?? _addressController.text.trim(),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              body['message']?.toString() ?? 'Erreur lors de la mise à jour.',
            ),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Erreur réseau.'),
          backgroundColor: Colors.red.shade800,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
