import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/application.dart';
import '../models/offer.dart';
import '../utils/constants.dart';

class OfferService {
  Future<List<Offer>> getOffers({
    String? jobTypeKey,
    String? contractType,
  }) async {
    final token = await _getToken();

    final queryParameters = <String, String>{};

    if (jobTypeKey != null && jobTypeKey.isNotEmpty) {
      queryParameters['jobTypeKey'] = jobTypeKey;
    }

    if (contractType != null && contractType.isNotEmpty) {
      queryParameters['contractType'] = contractType;
    }

    final uri = Uri.parse(ApiConstants.offers).replace(
      queryParameters: queryParameters,
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
    final data = json['data'];

    return (data as List)
        .map((item) => Offer.fromJson(item))
        .toList();
  }

  Future<Offer> getOfferDetail(String id) async {
    final token = await _getToken();

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
    final data = json['data'] ?? json;

    return Offer.fromJson(data);
  }

  Future<void> applyToOffer(
    String id,
    String comment,
    List<Map<String, dynamic>> answers,
  ) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse(ApiConstants.applyToOffer(id)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'comment': comment,
        'answers': answers,
      }),
    );

    if (response.statusCode >= 400) {
      throw Exception(_errorMessage(response));
    }
  }

  Future<void> unlikeOffer(String id) async {
    final token = await _getToken();

    final response = await http.delete(
      Uri.parse(ApiConstants.applyToOffer(id).replaceAll('/apply', '/like')),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 400) {
      throw Exception(_errorMessage(response));
    }
  }

  Future<List<Application>> getMyApplications() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse(ApiConstants.myApplications),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 400) {
      throw Exception(_errorMessage(response));
    }

    final json = jsonDecode(response.body);
    final data = json['data'];

    if (data == null) {
      return [];
    }

    return (data as List)
        .map((item) => Application.fromJson(item))
        .toList();
  }

  Future<List<Offer>> getLikedOffers() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse(ApiConstants.myLikes),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 400) {
      throw Exception(_errorMessage(response));
    }

    final json = jsonDecode(response.body);
    final data = json['data'];

    if (data == null) {
      return [];
    }

    return (data as List)
        .map((item) => Offer.fromJson(item))
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