import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:newv/app_theme.dart';
import 'glass_text_field.dart';
import 'package:newv/theme_manager.dart';
import 'package:newv/theme_colors.dart';

/// Step 1 of the registration wizard containing parent information.
///
/// This stateless widget renders input fields for the parent to enter 
/// their personal info like Name, CIN, Email, and Phone number. This data
/// is passed back to the `RegisterPage` where it is formatted for the API request.

/// A step widget containing the parent's personal and account information fields.
class ParentInfoStep extends StatelessWidget {
  static Color get _lightText => ThemeManager.instance.isLightMode
      ? const Color(0xFF212529)
      : const Color(0xFFF2F0F0);
  static Color get _mutedText => ThemeManager.instance.isLightMode
      ? const Color(0xFF6C757D)
      : const Color(0xFFA1A4AB);

  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController cinController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController addressController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final String birthDate;
  final VoidCallback onSelectDate;

  const ParentInfoStep({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.cinController,
    required this.phoneController,
    required this.emailController,
    required this.addressController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.birthDate,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    return ListView(
      key: const ValueKey('step0'),
      padding: const EdgeInsets.all(24.0),
      children: [
        Text(
          "Informations du Parent",
          style: TextStyle(
            color: _lightText,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            fontFamily: AppTheme.fontName,
          ),
        ),
        const SizedBox(height: 24),
        GlassTextField(
          controller: firstNameController,
          label: 'Prenom',
          icon: Icons.person_outline,
        ),
        GlassTextField(
          controller: lastNameController,
          label: 'Nom',
          icon: Icons.badge_outlined,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: InkWell(
            onTap: onSelectDate,
            borderRadius: BorderRadius.circular(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: ThemeColors.glassBorderSubtle,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: ThemeColors.glassBorder,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: _mutedText),
                      const SizedBox(width: 16),
                      Text(
                        birthDate != '' ? birthDate : 'Date de naissance',
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontSize: 16,
                          color: birthDate != ''
                              ? _lightText
                              : _mutedText.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        GlassTextField(
          controller: cinController,
          label: 'CIN',
          icon: Icons.credit_card_outlined,
          keyboardType: TextInputType.number,
        ),
        GlassTextField(
          controller: phoneController,
          label: 'Telephone',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        GlassTextField(
          controller: emailController,
          label: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        GlassTextField(
          controller: addressController,
          label: 'Adresse',
          icon: Icons.location_on_outlined,
          maxLines: 2,
        ),
        GlassTextField(
          controller: passwordController,
          label: 'Mot de passe',
          icon: Icons.lock_outline,
          isPassword: true,
        ),
        GlassTextField(
          controller: confirmPasswordController,
          label: 'Confirmer le mot de passe',
          icon: Icons.lock_reset_outlined,
          isPassword: true,
        ),
        const SizedBox(height: 48),
      ],
    );
  }
}
