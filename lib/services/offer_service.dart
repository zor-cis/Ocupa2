import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/offer.dart';
import '../utils/constants.dart';
import 'auth_service.dart';

class OfferService {
  final AuthService _authService = AuthService();

  // Explorar ofertas
  Future<List<Offer>> getOffers({
    String? jobTypeKey,
    String? contractType,
  }) async {
    final token = await _authService.getToken();

    if (token == null) {
      throw Exception('Sesión no encontrada');
    }

    final queryParameters = <String, String>{};

    if (jobTypeKey != null && jobTypeKey.isNotEmpty) {
      queryParameters['jobTypeKey'] = jobTypeKey;
    }

    if (contractType != null && contractType.isNotEmpty) {
      queryParameters['contractType'] = contractType;
    }

    final uri = Uri.parse(ApiConstants.offers).replace(
      queryParameters:
          queryParameters.isEmpty ? null : queryParameters,
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 400) {
      throw Exception(_errorMessage(response));
    }

    final json = jsonDecode(response.body);

    final List<dynamic> data = json['data'];

    return data
        .map((offer) => Offer.fromJson(offer))
        .toList();
  }

  // Ver detalle de una oferta
  Future<Offer> getOfferDetail(String id) async {
    final token = await _authService.getToken();

    if (token == null) {
      throw Exception('Sesión no encontrada');
    }

    final response = await http.get(
      Uri.parse(ApiConstants.offerDetail(id)),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 400) {
      throw Exception(_errorMessage(response));
    }

    final json = jsonDecode(response.body);

    return Offer.fromJson(json['data']);
  }

  // Aplicar a una oferta
  Future<void> applyToOffer(String id) async {
    final token = await _authService.getToken();

    if (token == null) {
      throw Exception('Sesión no encontrada');
    }

    final response = await http.post(
      Uri.parse(ApiConstants.applyToOffer(id)),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode >= 400) {
      throw Exception(_errorMessage(response));
    }
  }

  String _errorMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      return data['message'] ??
          data['error'] ??
          'Error del servidor';
    } catch (_) {
      return 'Error del servidor (${response.statusCode})';
    }
  }
}