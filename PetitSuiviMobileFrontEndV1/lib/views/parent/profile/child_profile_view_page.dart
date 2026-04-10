import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:newv/app_theme.dart';
import 'package:newv/l10n/app_localizations.dart';
import 'package:newv/theme_manager.dart';
import 'package:newv/theme_colors.dart';

// File: child_profile_view_page.dart
// Purpose: Read-only display of a child's basic information and status.
// Usage: Navigated from ParentProfilePage child list.
// API Usage: No (data passed via constructor).
// Dependencies: AppTheme, AppLocalizations.

/// A page that displays detailed, non-editable info about a specific child.
class ChildProfileViewPage extends StatelessWidget {
  // this is fetched from the parent profile page
  final Map<String, dynamic> childData;

  const ChildProfileViewPage({super.key, required this.childData});

  // Modern Theme Colors
  static Color get _baseDark => ThemeManager.instance.isLightMode
      ? const Color(0xFFF0F2F5)
      : const Color(0xFF141B2D);
  static Color get _tealAccent => ThemeManager.instance.isLightMode
      ? const Color(0xFF009688)
      : const Color(0xFF4CCEAC);
  static Color get _indigoAccent => ThemeManager.instance.isLightMode
      ? const Color(0xFF3F51B5)
      : const Color(0xFF6870FA);
  static Color get _lightText => ThemeManager.instance.isLightMode
      ? const Color(0xFF212529)
      : const Color(0xFFF2F0F0);
  static Color get _mutedText => ThemeManager.instance.isLightMode
      ? const Color(0xFF6C757D)
      : const Color(0xFFA1A4AB);

  static Color get _orangeAccent => ThemeManager.instance.isLightMode
      ? Colors.orange.shade700
      : Colors.orangeAccent;
  static Color get _redAccent => ThemeManager.instance.isLightMode
      ? Colors.red.shade700
      : Colors.redAccent;

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: _baseDark,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Profil de ${childData['firstName']}',
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
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: _lightText),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: 40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),

              _buildSectionTitle(l10n.strengthsAndWeaknesses),
              const SizedBox(height: 16),
              _buildGlassCard([
                _buildInfoRow(
                  Icons.person_outline_rounded,
                  l10n.firstName,
                  childData['firstName']?.toString() ?? '-',
                ),
                _buildInfoRow(
                  Icons.family_restroom_rounded,
                  l10n.lastName,
                  childData['lastName']?.toString() ?? '-',
                ),
                _buildInfoRow(
                  Icons.cake_rounded,
                  l10n.dateOfBirth,
                  childData['birthDate']?.toString() ?? '-',
                ),
                _buildInfoRow(
                  Icons.calendar_today_rounded,
                  l10n.age,
                  '${_calculateAge(childData['birthDate']?.toString())} ${l10n.yearsOld}',
                  isLast: true,
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _tealAccent.withValues(alpha: 0.1),
            border: Border.all(
              color: _tealAccent.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _tealAccent.withValues(alpha: 0.2),
                blurRadius: 20,
              ),
            ],
          ),
          child: Icon(
            Icons.face_retouching_natural_rounded,
            size: 50,
            color: _tealAccent,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${childData['firstName']} ${childData['lastName']}',
          style: TextStyle(
            fontFamily: AppTheme.fontName,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: _lightText,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: AppTheme.fontName,
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: _lightText,
      ),
    );
  }

  Widget _buildGlassCard(List<Widget> rows) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: ThemeColors.glassBackgroundSubtle,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ThemeColors.glassBorder),
          ),
          child: Column(children: rows),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _indigoAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: _indigoAccent, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: AppTheme.fontName,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: _mutedText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontFamily: AppTheme.fontName,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: _lightText,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isLast) ...[
            const SizedBox(height: 16),
            Divider(height: 1, color: ThemeColors.glassBorder),
          ],
        ],
      ),
    );
  }

  int _calculateAge(String? birthDateString) {
    if (birthDateString == null || birthDateString.isEmpty) return 0;
    try {
      DateTime birthDate = DateTime.parse(birthDateString);
      DateTime today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
  }
}
