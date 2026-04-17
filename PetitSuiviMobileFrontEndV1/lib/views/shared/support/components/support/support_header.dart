import 'package:flutter/material.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/l10n/app_localizations.dart';
import 'package:newv/views/shared/support/themes/support_theme.dart';

class SupportHeader extends StatelessWidget {
  final String companyName;
  final String address;

  const SupportHeader({
    super.key,
    required this.companyName,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(24.0),
      color: SupportTheme.surfaceBackground,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SupportTheme.indigoAccent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.support_agent_rounded,
              color: SupportTheme.indigoAccent,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '$companyName Support',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: SupportTheme.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.howCanWeHelp,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontSize: 15,
              color: SupportTheme.mutedText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: SupportTheme.mutedText),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  address,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: AppTheme.fontName,
                    color: SupportTheme.mutedText,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
