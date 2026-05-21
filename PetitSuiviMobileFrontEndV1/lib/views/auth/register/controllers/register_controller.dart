import 'package:flutter/material.dart';
import '../apis/register_api.dart';
import '../components/register/child_medical_record_page.dart';
import '../../../parent/waitingForApproval/waiting_approval_page.dart';

class RegisterController {
  final BuildContext context;

  RegisterController(this.context);

  static String normalizeKey(String s) {
    // check if the string contains any accents
    const accents = 'àâäéèêëîïôùûüç';
    const plain = 'aaaeeeeiiouu uc';
    final buf = StringBuffer();
    for (final ch in s.toLowerCase().runes) {
      final c = String.fromCharCode(ch);
      final idx = accents.indexOf(c);
      buf.write(idx >= 0 ? plain[idx] : c);
    }
    return buf.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static String formatAmount(double amount) {
    return amount.toStringAsFixed(0);
  }

  Future<List<String>> loadPaymentMethods() async {
    return await RegisterApi.getPaymentMethods();
  }

  Future<Map<String, dynamic>?> fetchPricingParameters() async {
    final list = await RegisterApi.fetchParameters();
    if (list == null) return null;

    double? baseFee;
    final Map<String, double> mealFees = {};

    const mealPlanOptions = [
      'Mon enfant prend le déjeuner et le goûter',
      'Mon enfant prend seulement le déjeuner',
      'Mon enfant prend seulement le goûter',
      'Mon enfant ne mange pas à l\'école (le parent le récupère puis le ramène)',
    ];

    for (final item in list) {
      final name = item['name']?.toString() ?? '';
      final value = double.tryParse(item['value']?.toString() ?? '');
      if (value == null) continue;

      final normName = normalizeKey(name);

      if (normName == normalizeKey('Prix de base')) {
        baseFee = value;
      } else {
        String? matchedOption;
        if (normName.contains('dejeuner et le gouter')) {
          matchedOption = mealPlanOptions[0];
        } else if (normName.contains('seulement le dejeuner')) {
          matchedOption = mealPlanOptions[1];
        } else if (normName.contains('seulement le gouter')) {
          matchedOption = mealPlanOptions[2];
        } else if (normName.contains('ne mange pas')) {
          matchedOption = mealPlanOptions[3];
        }

        if (matchedOption != null) {
          mealFees[matchedOption] = value;
        }
      }
    }

    return {'baseFee': baseFee, 'mealFees': mealFees};
  }

  Future<String?> selectDate({
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    required Color tealAccent,
    required Color baseDark,
    required Color lightText,
    required bool isLight,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: (isLight ? ThemeData.light() : ThemeData.dark()).copyWith(
            colorScheme:
                (isLight ? const ColorScheme.light() : const ColorScheme.dark())
                    .copyWith(
                      primary: tealAccent,
                      onPrimary: isLight ? Colors.white : baseDark,
                      surface: baseDark,
                      onSurface: lightText,
                    ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      return "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
    return null;
  }

  Future<Map<String, dynamic>?> openMedicalRecordPage(
    Map<String, dynamic> initialData,
  ) async {
    return await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => ChildMedicalRecordPage(initialData: initialData),
      ),
    );
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String? extractEmailError(Map<String, dynamic> body) {
    final errors = body['errors'];
    if (errors is! Map<String, dynamic>) return null;

    final emailErrors = errors['email'];
    if (emailErrors is List && emailErrors.isNotEmpty) {
      return emailErrors.first.toString();
    }
    if (emailErrors is String && emailErrors.isNotEmpty) {
      return emailErrors;
    }
    return null;
  }

  Future<bool> checkEmailAvailability(
    String email,
    Function(String?) onEmailError,
  ) async {
    try {
      final response = await RegisterApi.checkEmail(email);
      final body = response['body'] as Map<String, dynamic>;
      final emailError = extractEmailError(body);
      final available = body['available'] == true;

      if (response['statusCode'] >= 200 &&
          response['statusCode'] < 300 &&
          available) {
        onEmailError(null);
        return true;
      }

      final message =
          emailError ??
          body['message']?.toString() ??
          'Cet email est déjà utilisé.';
      onEmailError(message);
      showError(message);
      return false;
    } catch (_) {
      showError('Impossible de vérifier l\'email pour le moment.');
      return false;
    }
  }

  String? extractCinError(Map<String, dynamic> body) {
    final errors = body['errors'];
    if (errors is! Map<String, dynamic>) return null;

    final cinErrors = errors['cin'];
    if (cinErrors is List && cinErrors.isNotEmpty) {
      return cinErrors.first.toString();
    }
    if (cinErrors is String && cinErrors.isNotEmpty) {
      return cinErrors;
    }
    return null;
  }

  Future<bool> checkCinAvailability(
    String cin,
    Function(String?) onCinError,
  ) async {
    try {
      final response = await RegisterApi.checkCin(cin);
      final body = response['body'] as Map<String, dynamic>;
      final cinError = extractCinError(body);
      final available = body['available'] == true;

      if (response['statusCode'] >= 200 &&
          response['statusCode'] < 300 &&
          available) {
        onCinError(null);
        return true;
      }

      final message =
          cinError ?? body['message']?.toString() ?? 'Ce CIN est déjà utilisé.';
      onCinError(message);
      showError(message);
      return false;
    } catch (_) {
      showError('Impossible de vérifier le CIN pour le moment.');
      return false;
    }
  }

  Future<void> handleRegister({
    required Map<String, dynamic> payload,
    required Function(bool) onLoadingChanged,
    required Function(String?, int) onRegistrationError,
  }) async {
    onLoadingChanged(true);
    try {
      final response = await RegisterApi.register(payload);
      final statusCode = response['statusCode'] as int;
      final body = response['body'] as Map<String, dynamic>;

      if (!context.mounted) return;

      if (statusCode >= 200 && statusCode < 300) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const WaitingApprovalPage()),
          (route) => false,
        );
      } else {
        final emailError = extractEmailError(body);
        if (emailError != null) {
          onRegistrationError(emailError, 0); // Step 0 is parent info
          showError(emailError);
        } else {
          showError(body['message']?.toString() ?? 'Échec de l\'inscription.');
        }
      }
    } catch (_) {
      showError('Erreur réseau lors de l\'inscription.');
    } finally {
      onLoadingChanged(false);
    }
  }
}
