import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/l10n/app_localizations.dart';
import 'package:newv/views/auth/register/entities/child.dart';
import 'package:newv/views/themes/theme_colors.dart';
import 'package:newv/views/parent/child_tracking/controllers/child_tracking_controller.dart';
import 'package:newv/views/parent/child_tracking/themes/child_tracking_theme.dart';
import 'package:newv/views/parent/child_tracking/components/child_tracking/re_registration_page.dart';

class ChildCard extends StatelessWidget {
  final Child child;
  final ChildTrackingController controller;
  final VoidCallback onOpenDetails;

  const ChildCard({
    super.key,
    required this.child,
    required this.controller,
    required this.onOpenDetails,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canOpenProfile = controller.isChildApproved(child);
    final needsReReg = controller.needsReRegistration(child);
    final age = controller.calculateAge(child.birthDate);
    final className = controller.getCurrentClassName(child);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (needsReReg) {
                if (!controller.inscriptionsOpen) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Les inscriptions sont actuellement fermées.'),
                      backgroundColor: Colors.orange.shade800,
                    ),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReRegistrationPage(
                      childId: child.id ?? 0,
                      firstName: child.firstName,
                      lastName: child.lastName,
                      birthDate: child.birthDate.toIso8601String().split('T').first,
                    ),
                  ),
                );
                return;
              }

              if (!canOpenProfile) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Profil indisponible: inscription en attente d\'approbation.'),
                    backgroundColor: Colors.orange.shade800,
                  ),
                );
                return;
              }

              onOpenDetails();
            },
            child: Container(
              decoration: BoxDecoration(
                color: canOpenProfile
                    ? ThemeColors.glassBorder
                    : ThemeColors.glassBackgroundSubtle,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: canOpenProfile
                      ? ThemeColors.glassBorderStrong
                      : ThemeColors.glassBorderSubtle,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: canOpenProfile
                          ? ChildTrackingTheme.tealAccent.withValues(alpha: 0.2)
                          : ThemeColors.glassBackgroundSubtle,
                      border: Border.all(
                        color: canOpenProfile
                            ? ChildTrackingTheme.tealAccent
                            : ThemeColors.glassBorder,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.face_retouching_natural_rounded,
                      size: 40,
                      color: needsReReg
                          ? ChildTrackingTheme.indigoAccent
                          : (canOpenProfile ? ChildTrackingTheme.tealAccent : ChildTrackingTheme.mutedText),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    child.firstName,
                    style: TextStyle(
                      fontFamily: AppTheme.fontName,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: canOpenProfile ? ChildTrackingTheme.lightText : ChildTrackingTheme.mutedText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$age ${l10n.yearsOld}',
                    style: TextStyle(
                      fontFamily: AppTheme.fontName,
                      fontSize: 14,
                      color: canOpenProfile
                          ? ChildTrackingTheme.mutedText
                          : ChildTrackingTheme.mutedText.withValues(alpha: 0.5),
                    ),
                  ),
                  if (canOpenProfile && className != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Classe: $className',
                      style: TextStyle(
                        fontFamily: AppTheme.fontName,
                        fontSize: 14,
                        color: ChildTrackingTheme.tealAccent.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (needsReReg) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: ChildTrackingTheme.indigoAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ChildTrackingTheme.indigoAccent.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        'Nouvelle année — Inscription requise',
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ChildTrackingTheme.indigoAccent,
                        ),
                      ),
                    ),
                  ] else if (!canOpenProfile) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                      ),
                      child: const Text(
                        'En attente',
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.orangeAccent,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
