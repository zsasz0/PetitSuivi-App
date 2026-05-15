import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:newv/l10n/app_localizations.dart';
import 'package:newv/views/themes/theme_manager.dart';
import 'package:newv/views/parent/child_tracking/components/child_tracking/re_registration_page.dart';

// Modular Imports
import 'package:newv/views/parent/profile/themes/profile_theme.dart';

class ChildProfileViewPage extends StatelessWidget {
  final Map<String, dynamic> childData;
  final bool inscriptionsOpen;
  final VoidCallback onRefresh;

  const ChildProfileViewPage({
    super.key,
    required this.childData,
    required this.inscriptionsOpen,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    final l10n = AppLocalizations.of(context)!;

    // Extract status from inscriptions
    final inscriptions = childData['extraData']?['inscriptions'] as List? ?? [];
    String status = 'inconnu';
    if (inscriptions.isNotEmpty) {
      status = inscriptions.last['status']?['name']?.toString() ?? 'inconnu';
    }

    String displayStatus = 'Inconnu';
    if (status.toLowerCase() == 'approved') {
      displayStatus = 'Approuvé';
    }
    if (status.toLowerCase() == 'pending') {
      displayStatus = 'En attente';
    }
    if (status.toLowerCase() == 'rejected') {
      displayStatus = 'Rejeté';
    }
    if (status.toLowerCase() == 'inscription_requise') {
      displayStatus = 'Inscription requise';
    }

    bool needsReRegistration = status.toLowerCase() == 'inscription_requise';

    return Container(
      color: ProfileTheme.baseDark,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Profil de ${childData['firstName']}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: ProfileTheme.lightText,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: ProfileTheme.lightText,
            ),
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
                ),
                _buildInfoRow(
                  Icons.info_outline_rounded,
                  'Statut',
                  displayStatus,
                  isLast: true,
                ),
              ]),
              const SizedBox(height: 32),

              if (inscriptionsOpen || !needsReRegistration)
                ElevatedButton(
                  onPressed: needsReRegistration
                      ? () async {
                          final result = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReRegistrationPage(
                                childId: childData['id'] ?? 0,
                                firstName:
                                    childData['firstName']?.toString() ?? '',
                                lastName:
                                    childData['lastName']?.toString() ?? '',
                                birthDate:
                                    childData['birthDate']
                                        ?.toString()
                                        .split('T')
                                        .first ??
                                    '',
                              ),
                            ),
                          );
                          if (result == true) {
                            onRefresh();
                            if (context.mounted) Navigator.pop(context);
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    backgroundColor: ProfileTheme.indigoAccent,
                    disabledBackgroundColor: ProfileTheme.indigoAccent
                        .withValues(alpha: 0.3),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white70,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.school_outlined, size: 22),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Inscrire pour la nouvelle année',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else if (needsReRegistration)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Text(
                    'Les inscriptions sont actuellement fermées.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
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
            color: ProfileTheme.tealAccent.withValues(alpha: 0.1),
            border: Border.all(
              color: ProfileTheme.tealAccent.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: ProfileTheme.tealAccent.withValues(alpha: 0.2),
                blurRadius: 20,
              ),
            ],
          ),
          child: Icon(
            Icons.face_retouching_natural_rounded,
            size: 50,
            color: ProfileTheme.tealAccent,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${childData['firstName']} ${childData['lastName']}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: ProfileTheme.lightText,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildGlassCard(List<Widget> rows) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: ProfileTheme.glassBackgroundSubtle,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ProfileTheme.glassBorder),
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
                  color: ProfileTheme.indigoAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: ProfileTheme.indigoAccent, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: ProfileTheme.mutedText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: ProfileTheme.lightText,
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
            Divider(height: 1, color: ProfileTheme.glassBorder),
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
