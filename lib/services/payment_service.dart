import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/payment_transaction.dart';
import '../utils/constants.dart';

class PaymentService {
  Future<List<PaymentTransaction>> getMyPayments() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(ApiConstants.myPayments),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode >= 400) {
      throw Exception(_errorMessage(response));
    }

    final json = jsonDecode(response.body);
    final data = json['data'];

    if (data == null) return [];

    return (data as List)
        .map((item) => PaymentTransaction.fromJson(item))
        .toList();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  String _errorMessage(http.Response response) {
    try {
      final json = jsonDecode(response.body);
      return json['message'] ??
          json['error'] ??
          json['detail'] ??
          'Error del servidor';
    } catch (_) {
      return 'Error del servidor (${response.statusCode})';
    }
  }
}
