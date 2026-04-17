import 'package:flutter/material.dart';
import 'package:newv/views/shared/support/apis/support_api.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportController extends ChangeNotifier {
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String _email = '';
  String get email => _email;

  String _phone = '';
  String get phone => _phone;

  String _whatsapp = '';
  String get whatsapp => _whatsapp;

  String _facebook = '';
  String get facebook => _facebook;

  String _instagram = '';
  String get instagram => _instagram;

  String _companyName = '';
  String get companyName => _companyName;

  String _address = '';
  String get address => _address;

  String _errorMsg = '';
  String get errorMsg => _errorMsg;



  Future<void> fetchParameters(String? token) async {
    _isLoading = true;
    _errorMsg = '';
    notifyListeners();

    try {
      final params = await SupportApis.fetchParameters(token);
      _email = params['contact_email'] ?? '';
      _phone = params['contact_phone'] ?? '';
      _whatsapp = params['contact_whatsapp'] ?? '';
      _facebook = params['contact_facebook'] ?? '';
      _instagram = params['contact_instagram'] ?? '';
      _companyName = params['company_name'] ?? '';
      _address = params['kindergarten_address'] ?? '';
      _isLoading = false;
    } catch (e) {
      _errorMsg = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> launchPhone() async {
    final Uri phoneLaunchUri = Uri(scheme: 'tel', path: _phone);
    await _launch(phoneLaunchUri);
  }

  Future<void> launchEmail() async {
    final Uri emailLaunchUri = Uri(scheme: 'mailto', path: _email);
    await _launch(emailLaunchUri);
  }

  Future<void> launchWhatsapp() async {
    final formattedPhone = _whatsapp.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri whatsappLaunchUri = Uri.parse("https://wa.me/$formattedPhone");
    await _launch(whatsappLaunchUri, mode: LaunchMode.externalApplication);
  }

  Future<void> launchFacebook() async {
    if (_facebook.isEmpty) return;
    final urlStr = _facebook.startsWith('http') ? _facebook : 'https://$_facebook';
    final Uri fbLaunchUri = Uri.parse(urlStr);
    await _launch(fbLaunchUri, mode: LaunchMode.externalApplication);
  }

  Future<void> launchInstagram() async {
    if (_instagram.isEmpty) return;
    final urlStr = _instagram.startsWith('http') ? _instagram : 'https://$_instagram';
    final Uri instaLaunchUri = Uri.parse(urlStr);
    await _launch(instaLaunchUri, mode: LaunchMode.externalApplication);
  }

  Future<void> _launch(Uri uri, {LaunchMode mode = LaunchMode.platformDefault}) async {
    try {
      await launchUrl(uri, mode: mode);
    } catch (e) {
      debugPrint('Error launching $uri: $e');
    }
  }
}
