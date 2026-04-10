import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newv/utils/api_constants.dart';
import 'package:newv/models/auth_session.dart';
import 'package:provider/provider.dart';
import 'package:newv/app_theme.dart';
import 'package:newv/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:newv/theme_manager.dart';
import 'package:url_launcher/url_launcher.dart';

// File: support_page.dart
// Purpose: FAQ and Contact Support hub for parents.
// Usage: Accessed via the "Support" tab or drawer.
// API Usage:
//   - GET /api/parameters (Fetch contact info, company details)
// Dependencies: ApiConstants, AppTheme, AppLocalizations, FontAwesome, UrlLauncher.

/// A page with expandable FAQ items and quick-action buttons (call, email, social links).
class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  // Modern Theme Colors
  static bool get _isLight => ThemeManager.instance.isLightMode;
  static Color get _baseDark =>
      _isLight ? const Color(0xFFF8F9FA) : const Color(0xFF0F172A);
  static Color get _surfaceDark =>
      _isLight ? const Color(0xFFFFFFFF) : const Color(0xFF1E293B);
  static Color get _tealAccent =>
      _isLight ? const Color(0xFF0D9488) : const Color(0xFF2DD4BF);
  static Color get _indigoAccent =>
      _isLight ? const Color(0xFF4F46E5) : const Color(0xFF818CF8);
  static Color get _lightText =>
      _isLight ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
  static Color get _mutedText =>
      _isLight ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

  final List<Map<String, String>> _faqs = [
    {
      "question": "Comment modifier le profil de mon enfant ?",
      "answer":
          "Rendez-vous sur la page Profil, sélectionnez votre enfant dans la liste, puis appuyez sur l'icône de modification.",
    },
    {
      "question": "Où puis-je voir les paiements ?",
      "answer":
          "Vous pouvez consulter l'historique de vos paiements dans la section 'Paiements' du menu principal.",
    },
    {
      "question": "Comment contacter l'administration ?",
      "answer":
          "Vous pouvez utiliser les boutons d'appel ou d'email ci-dessus pour contacter directement l'administration de l'école.",
    },
    {
      "question": "Problème de connexion ?",
      "answer":
          "Assurez-vous que votre adresse email est correcte. Si vous avez oublié votre mot de passe, utilisez l'option 'Mot de passe oublié' sur la page de connexion.",
    },
  ];

  bool _isLoading = true;
  String _email = '';
  String _phone = '';
  String _whatsapp = '';
  String _facebook = '';
  String _instagram = '';
  String _companyName = '';
  String _address = '';
  String _errorMsg = '';

  bool _hasFetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasFetched) {
      _hasFetched = true;
      _fetchParameters();
    }
  }

  Future<void> _fetchParameters() async {
    try {
      final session = context.read<AuthSession>();
      final token = session.token;

      final uri = Uri.parse('${ApiConstants.baseUrl}/api/parameters');
      debugPrint('[SupportPage] Fetching parameters from: $uri');

      final Map<String, String> headers = {
        'Accept': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(uri, headers: headers);

      debugPrint('[SupportPage] Status: ${response.statusCode}');
      debugPrint('[SupportPage] Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);

        List<dynamic> data;
        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map<String, dynamic>) {
          data = decoded['data'] ?? [];
        } else {
          data = [];
        }

        debugPrint('[SupportPage] Parsed ${data.length} parameters');

        final Map<String, String> params = {};
        for (var item in data) {
          final key = (item['name'] ?? item['Name'] ?? '').toString();
          final val = (item['value'] ?? item['Value'] ?? '').toString();
          if (key.isNotEmpty && val.isNotEmpty) {
            params[key] = val;
          }
        }

        debugPrint('[SupportPage] Mapped params keys: ${params.keys.toList()}');

        if (mounted) {
          setState(() {
            _email = params['contact_email'] ?? '';
            _phone = params['contact_phone'] ?? '';
            _whatsapp = params['contact_whatsapp'] ?? '';
            _facebook = params['contact_facebook'] ?? '';
            _instagram = params['contact_instagram'] ?? '';
            _companyName = params['company_name'] ?? '';
            _address = params['kindergarten_address'] ?? '';
            _isLoading = false;
          });
        }
      } else {
        debugPrint('[SupportPage] Non-200 status: ${response.statusCode}');
        if (mounted) {
          setState(() {
            _errorMsg = 'HTTP ${response.statusCode}: ${response.body}';
            _isLoading = false;
          });
        }
      }
    } catch (e, stack) {
      debugPrint('[SupportPage] ERROR fetching parameters: $e');
      debugPrint('[SupportPage] Stack: $stack');
      if (mounted) {
        setState(() {
          _errorMsg = 'Exception: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: _baseDark,
      appBar: AppBar(
        title: Text(
          'Support & FAQ',
          style: TextStyle(
            fontFamily: AppTheme.fontName,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: _lightText,
          ),
        ),
        backgroundColor: _surfaceDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: _lightText),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: _mutedText.withValues(alpha: 0.1),
            height: 1.0,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMsg.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'ERROR: $_errorMsg',
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(l10n),
                  _buildQuickActions(l10n),
                  const SizedBox(height: 24),
                  _buildSocialContacts(),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'Questions Fréquentes',
                      style: TextStyle(
                        fontFamily: AppTheme.fontName,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: _lightText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFAQSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      color: _surfaceDark,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _indigoAccent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.support_agent_rounded,
              color: _indigoAccent,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '$_companyName Support',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: _lightText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.howCanWeHelp,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontSize: 15,
              color: _mutedText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: _mutedText),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  _address,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: AppTheme.fontName,
                    color: _mutedText,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: _buildActionCard(
              icon: Icons.phone_in_talk_rounded,
              label: l10n.callUs,
              color: _tealAccent,
              onTap: () async {
                final Uri phoneLaunchUri = Uri(scheme: 'tel', path: _phone);
                try {
                  await launchUrl(phoneLaunchUri);
                } catch (e) {
                  debugPrint('Could not launch $phoneLaunchUri');
                }
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildActionCard(
              icon: Icons.alternate_email_rounded,
              label: l10n.emailUs,
              color: _indigoAccent,
              onTap: () async {
                final Uri emailLaunchUri = Uri(scheme: 'mailto', path: _email);
                try {
                  await launchUrl(emailLaunchUri);
                } catch (e) {
                  debugPrint('Could not launch $emailLaunchUri');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialContacts() {
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
              color: _lightText,
            ),
          ),
          const SizedBox(height: 16),
          _buildSocialCard(
            icon: FontAwesomeIcons.whatsapp,
            title: 'WhatsApp',
            subtitle: _whatsapp,
            color: const Color(0xFF10B981),
            onTap: () async {
              final formattedPhone = _whatsapp.replaceAll(
                RegExp(r'[^\d+]'),
                '',
              );
              final Uri whatsappLaunchUri = Uri.parse(
                "https://wa.me/$formattedPhone",
              );
              try {
                await launchUrl(
                  whatsappLaunchUri,
                  mode: LaunchMode.externalApplication,
                );
              } catch (e) {
                debugPrint('Could not launch $whatsappLaunchUri');
              }
            },
          ),
          _buildSocialCard(
            icon: FontAwesomeIcons.facebookF,
            title: 'Facebook',
            subtitle: 'Notre page officielle',
            color: const Color(0xFF3B82F6),
            onTap: () async {
              final Uri fbLaunchUri = Uri.parse(_facebook);
              try {
                await launchUrl(
                  fbLaunchUri,
                  mode: LaunchMode.externalApplication,
                );
              } catch (e) {
                debugPrint('Could not launch $fbLaunchUri');
              }
            },
          ),
          _buildSocialCard(
            icon: FontAwesomeIcons.instagram,
            title: 'Instagram',
            subtitle: 'Notre galerie',
            color: const Color(0xFFEC4899),
            onTap: () async {
              final Uri instaLaunchUri = Uri.parse(_instagram);
              try {
                await launchUrl(
                  instaLaunchUri,
                  mode: LaunchMode.externalApplication,
                );
              } catch (e) {
                debugPrint('Could not launch $instaLaunchUri');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceDark,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: _mutedText.withValues(alpha: 0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: _lightText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _surfaceDark,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: _mutedText.withValues(alpha: 0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: _lightText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontSize: 14,
                          color: _mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: _mutedText.withValues(alpha: 0.3),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAQSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        decoration: BoxDecoration(
          color: _surfaceDark,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: _mutedText.withValues(alpha: 0.05)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: _faqs.asMap().entries.map((entry) {
              final index = entry.key;
              final faq = entry.value;
              final isLast = index == _faqs.length - 1;

              return Column(
                children: [
                  Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      iconColor: _tealAccent,
                      collapsedIconColor: _mutedText,
                      title: Text(
                        faq["question"]!,
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: _lightText,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 16,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              faq["answer"]!,
                              style: TextStyle(
                                fontFamily: AppTheme.fontName,
                                fontSize: 14,
                                color: _mutedText,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: _mutedText.withValues(alpha: 0.1),
                      indent: 16,
                      endIndent: 16,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
