import 'package:flutter/material.dart';
import 'package:newv/l10n/app_localizations.dart';
import 'package:newv/views/shared/support/components/support/action_card.dart';
import 'package:newv/views/shared/support/controllers/support_controller.dart';
import 'package:newv/views/shared/support/themes/support_theme.dart';
import 'package:provider/provider.dart';

class SupportQuickActions extends StatelessWidget {
  const SupportQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.read<SupportController>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: ActionCard(
              icon: Icons.phone_in_talk_rounded,
              label: l10n.callUs,
              color: SupportTheme.tealAccent,
              onTap: () => controller.launchPhone(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ActionCard(
              icon: Icons.alternate_email_rounded,
              label: l10n.emailUs,
              color: SupportTheme.indigoAccent,
              onTap: () => controller.launchEmail(),
            ),
          ),
        ],
      ),
    );
  }
}
