import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:newv/views/themes/app_theme.dart';
import 'package:newv/views/shared/support/components/support/social_card.dart';
import 'package:newv/views/shared/support/controllers/support_controller.dart';
import 'package:newv/views/shared/support/themes/support_theme.dart';
import 'package:provider/provider.dart';

class SupportSocialContacts extends StatelessWidget {
  const SupportSocialContacts({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SupportController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Autres moyens de contact',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: SupportTheme.primaryText,
            ),
          ),
          const SizedBox(height: 16),
          SupportSocialCard(
            icon: FontAwesomeIcons.whatsapp,
            title: 'WhatsApp',
            subtitle: controller.whatsapp,
            color: SupportTheme.whatsappColor,
            onTap: () => controller.launchWhatsapp(),
          ),
          SupportSocialCard(
            icon: FontAwesomeIcons.facebookF,
            title: 'Facebook',
            subtitle: 'Notre page officielle',
            color: SupportTheme.facebookColor,
            onTap: () => controller.launchFacebook(),
          ),
          SupportSocialCard(
            icon: FontAwesomeIcons.instagram,
            title: 'Instagram',
            subtitle: 'Notre galerie',
            color: SupportTheme.instagramColor,
            onTap: () => controller.launchInstagram(),
          ),
        ],
      ),
    );
  }
}

// Renaming the internal widget to avoid conflict if I used SocialCard elsewhere, 
// but actually I named the file social_card.dart. 
// Let's stick to SocialCard but be careful with naming inside. 
// Actually, I'll name the class in social_card.dart as SocialCard.
