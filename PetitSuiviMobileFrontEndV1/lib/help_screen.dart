import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:newv/theme_manager.dart';
import 'package:newv/app_theme.dart';
import 'package:newv/utils/api_constants.dart';
import 'package:newv/models/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// A clean, modern screen that provides help and contact information for users.
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  static bool get _isLight => ThemeManager.instance.isLightMode;
  static Color get _baseDark =>
      _isLight ? const Color(0xFFF8F9FA) : const Color(0xFF0F172A);
  static Color get _cardDark =>
      _isLight ? const Color(0xFFFFFFFF) : const Color(0xFF1E293B);
  static Color get _tealAccent =>
      _isLight ? const Color(0xFF0D9488) : const Color(0xFF2DD4BF);
  static Color get _indigoAccent =>
      _isLight ? const Color(0xFF4F46E5) : const Color(0xFF818CF8);
  static Color get _lightText =>
      _isLight ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
  static Color get _mutedText =>
      _isLight ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

  bool _isLoading = true;
  String _email = '';
  String _phone = '';
  String _whatsapp = '';
  String _facebook = '';
  String _instagram = '';
  String _companyName = '';
  String _address = '';

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
      debugPrint('[HelpScreen] Fetching parameters from: $uri');

      final Map<String, String> headers = {
        'Accept': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(uri, headers: headers);

      debugPrint('[HelpScreen] Status: ${response.statusCode}');
      debugPrint('[HelpScreen] Body: ${response.body}');

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

        final Map<String, String> params = {};
        for (var item in data) {
          final key = (item['name'] ?? item['Name'] ?? '').toString();
          final val = (item['value'] ?? item['Value'] ?? '').toString();
          if (key.isNotEmpty && val.isNotEmpty) {
            params[key] = val;
          }
        }

        debugPrint('[HelpScreen] Params: $params');

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
        debugPrint('[HelpScreen] Non-200: ${response.statusCode}');
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e, stack) {
      debugPrint('[HelpScreen] ERROR: $e');
      debugPrint('[HelpScreen] Stack: $stack');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();

    return Scaffold(
      backgroundColor: _baseDark,
      appBar: AppBar(
        title: Text(
          'Aide & Contact',
          style: TextStyle(
            fontFamily: AppTheme.fontName,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: _lightText,
          ),
        ),
        backgroundColor: _baseDark,
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
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/appImage.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: Text(
                        'Besoin d\'aide ?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppTheme.fontName,
                          color: _lightText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'L\'équipe de $_companyName est disponible pour répondre à toutes vos questions.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          fontFamily: AppTheme.fontName,
                          color: _mutedText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: _mutedText,
                          ),
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
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Contactez-nous',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: AppTheme.fontName,
                        color: _lightText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildContactCard(
                      icon: Icons.email_outlined,
                      title: 'Email',
                      subtitle: _email,
                      color: _indigoAccent,
                      onTap: () async {
                        final Uri emailLaunchUri = Uri(
                          scheme: 'mailto',
                          path: _email,
                        );
                        try {
                          await launchUrl(emailLaunchUri);
                        } catch (e) {
                          debugPrint('Could not launch $emailLaunchUri');
                        }
                      },
                    ),
                    _buildContactCard(
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
                    _buildContactCard(
                      icon: Icons.phone_outlined,
                      title: 'Téléphone',
                      subtitle: _phone,
                      color: _tealAccent,
                      onTap: () async {
                        final Uri phoneLaunchUri = Uri(
                          scheme: 'tel',
                          path: _phone,
                        );
                        try {
                          await launchUrl(phoneLaunchUri);
                        } catch (e) {
                          debugPrint('Could not launch $phoneLaunchUri');
                        }
                      },
                    ),
                    _buildContactCard(
                      icon: FontAwesomeIcons.facebookF,
                      title: 'Facebook',
                      subtitle: 'Visiter notre page',
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
                    _buildContactCard(
                      icon: FontAwesomeIcons.instagram,
                      title: 'Instagram',
                      subtitle: 'Voir notre profil',
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
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardDark,
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
}
