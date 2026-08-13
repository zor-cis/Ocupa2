import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/oferta_model.dart';
import '../utils/constants.dart';

/// Módulo 4: publicar, pagar, mis ofertas, aplicantes.
///
/// Flujo real de publicación (confirmado en Swagger):
///   1. subirFoto()      -> URL de la imagen
///   2. cobrarTarjeta()  -> paymentId aprobado
///   3. crearOferta()    -> usa ambos
class OfertasService {
  // ---------- Helpers ----------

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  dynamic _unwrap(dynamic body) {
    if (body is Map<String, dynamic> && body.containsKey('data')) {
      return body['data'];
    }
    return body;
  }

  String _errorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        return body['error']?.toString() ??
            body['message']?.toString() ??
            'Error ${response.statusCode}';
      }
    } catch (_) {}
    return 'Error ${response.statusCode}';
  }

  List<Map<String, dynamic>> _comoLista(dynamic data) {
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map<String, dynamic>) {
      for (final clave in ['items', 'offers', 'applications', 'payments', 'results']) {
        final v = data[clave];
        if (v is List) return v.cast<Map<String, dynamic>>();
      }
    }
    return [];
  }

  // ---------- Catálogo ----------

  Future<List<JobTypeModel>> jobTypes() async {
    final response = await http.get(Uri.parse(ApiConstants.jobTypes), headers: await _headers());
    if (response.statusCode >= 400) throw Exception(_errorMessage(response));
    return _comoLista(_unwrap(jsonDecode(response.body)))
        .map(JobTypeModel.fromJson)
        .toList();
  }

  // ---------- Paso 1: subir foto ----------

  /// Sube la imagen en base64 y devuelve su URL pública.
  Future<String> subirFoto(File imagen) async {
    final bytes = await imagen.readAsBytes();
    final base64Image = base64Encode(bytes);
    final nombre = imagen.path.split(Platform.pathSeparator).last;

    final response = await http.post(
      Uri.parse(ApiConstants.uploads),
      headers: await _headers(),
      body: jsonEncode({'image': base64Image, 'filename': nombre}),
    );

    if (response.statusCode >= 400) throw Exception(_errorMessage(response));
    final data = _unwrap(jsonDecode(response.body));
    return data['url'].toString();
  }

  // ---------- Paso 2: cobrar ----------

  /// Cobra US$1 con la pasarela simulada. Devuelve el paymentId aprobado.
  Future<PagoModel> cobrarTarjeta({
    required String cardNumber,
    required String cvv,
    required int expMonth,
    required int expYear,
    required String cardholder,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.pagos),
      headers: await _headers(),
      body: jsonEncode({
        'cardNumber': cardNumber.replaceAll(' ', ''),
        'cvv': cvv,
        'expMonth': expMonth,
        'expYear': expYear,
        'cardholder': cardholder,
      }),
    );

    if (response.statusCode >= 400) throw Exception(_errorMessage(response));
    return PagoModel.fromJson(_unwrap(jsonDecode(response.body)));
  }

  Future<List<PagoModel>> misPagos() async {
    final response = await http.get(Uri.parse(ApiConstants.misPagos), headers: await _headers());
    if (response.statusCode >= 400) throw Exception(_errorMessage(response));
    return _comoLista(_unwrap(jsonDecode(response.body))).map(PagoModel.fromJson).toList();
  }

  // ---------- Paso 3: crear la oferta ----------

  Future<OfertaModel> crearOferta({
    required String jobTypeKey,
    required String contractType,
    required String description,
    required String address,
    required String photoUrl,
    required String paymentId,
    required double amount,
    String currency = 'DOP',
    double? lat,
    double? lng,
    DateTime? deadline,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.ofertas),
      headers: await _headers(),
      body: jsonEncode({
        'jobTypeKey': jobTypeKey,
        'contractType': contractType,
        'description': description,
        'address': address,
        'photo': photoUrl,
        'paymentId': paymentId,
        'payment': {'amount': amount, 'currency': currency},
        if (lat != null && lng != null) 'location': {'lat': lat, 'lng': lng},
        if (deadline != null)
          'deadline': deadline.toIso8601String().split('T').first,
      }),
    );

    if (response.statusCode >= 400) throw Exception(_errorMessage(response));
    return OfertaModel.fromJson(_unwrap(jsonDecode(response.body)));
  }

  // ---------- Mis ofertas ----------

  Future<List<OfertaModel>> misOfertas() async {
    final response = await http.get(Uri.parse(ApiConstants.misOfertas), headers: await _headers());
    if (response.statusCode >= 400) throw Exception(_errorMessage(response));
    return _comoLista(_unwrap(jsonDecode(response.body))).map(OfertaModel.fromJson).toList();
  }

  Future<List<AplicacionModel>> aplicantes(String ofertaId) async {
    final response = await http.get(
      Uri.parse(ApiConstants.aplicantesDeOferta(ofertaId)),
      headers: await _headers(),
    );
    if (response.statusCode >= 400) throw Exception(_errorMessage(response));
    return _comoLista(_unwrap(jsonDecode(response.body))).map(AplicacionModel.fromJson).toList();
  }

  Future<void> desactivarOferta(String ofertaId) async {
    final response = await http.post(
      Uri.parse(ApiConstants.desactivarOferta(ofertaId)),
      headers: await _headers(),
    );
    if (response.statusCode >= 400) throw Exception(_errorMessage(response));
  }

  // TODO: el endpoint no aparece en el Swagger. Confirmar con el profesor.
  Future<void> elegirGanador(String ofertaId, String aplicacionId) async {
    final response = await http.post(
      Uri.parse(ApiConstants.elegirGanador(ofertaId)),
      headers: await _headers(),
      body: jsonEncode({'applicationId': aplicacionId}),
    );
    if (response.statusCode >= 400) throw Exception(_errorMessage(response));
  }
}