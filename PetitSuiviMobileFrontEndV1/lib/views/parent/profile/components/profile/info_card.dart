import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:newv/models/auth_session.dart';
import 'package:newv/views/parent/profile/themes/profile_theme.dart';
import 'package:newv/views/parent/profile/components/common/info_row.dart';

class InfoCard extends StatelessWidget {
  final AuthSession session;

  const InfoCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ProfileTheme.glassBackgroundSubtle,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ProfileTheme.glassBorder),
          ),
          child: Column(
            children: [
              InfoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: (session.email?.isNotEmpty ?? false) ? session.email! : '-',
              ),
              Divider(height: 32, color: ProfileTheme.divider),
              InfoRow(
                icon: Icons.phone_outlined,
                label: 'Téléphone',
                value: (session.phone?.isNotEmpty ?? false) ? session.phone! : '-',
              ),
              Divider(height: 32, color: ProfileTheme.divider),
              InfoRow(
                icon: Icons.badge_outlined,
                label: 'Numéro CIN',
                value: session.cin != null ? session.cin!.toString() : '-',
              ),
              Divider(height: 32, color: ProfileTheme.divider),
              InfoRow(
                icon: Icons.location_on_outlined,
                label: 'Adresse',
                value: (session.address?.isNotEmpty ?? false)
                    ? session.address!
                    : 'Non spécifiée',
              ),
            ],
          ),
        ),
      ),
    );
  }


}
