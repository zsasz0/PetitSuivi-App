import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newv/utils/api_constants.dart';

class PaymentApis {
  static const String _apiBaseUrl = ApiConstants.baseUrl;

  static Future<Map<String, dynamic>> fetchPayments({
    required String cin,
    required String token,
  }) async {
    final uri = Uri.parse('$_apiBaseUrl/api/parents/$cin/payments');

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 15));

    final body = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};

    return {
      'status': response.statusCode,
      'data': body,
    };
  }
}
