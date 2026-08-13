import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/oferta_model.dart';
import '../utils/constants.dart';

/// Toda la red del módulo 4: publicar, pagar, mis ofertas, aplicantes y ganador.
/// Sigue el mismo patrón que AuthService: token desde SharedPreferences,
/// header Bearer, y respuesta envuelta en {"ok": true, "data": {...}}.
class OfertasService {
  // ---------- Helpers ----------

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _headers({bool json = true}) async {
    final token = await _getToken();
    return {
      if (json) 'Content-Type': 'application/json',
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
      for (final clave in ['items', 'ofertas', 'aplicaciones', 'pagos', 'results']) {
        final v = data[clave];
        if (v is List) return v.cast<Map<String, dynamic>>();
      }
    }
    return [];
  }

  // ---------- Publicar ----------

  Future<OfertaModel> crearOferta({
    required String titulo,
    required String descripcion,
    required String categoria,
    required double pago,
    required String ubicacion,
    double? latitud,
    double? longitud,
    File? imagen,
  }) async {
    if (imagen == null) {
      final response = await http.post(
        Uri.parse(ApiConstants.ofertas),
        headers: await _headers(),
        body: jsonEncode({
          'titulo': titulo,
          'descripcion': descripcion,
          'categoria': categoria,
          'pago': pago,
          'ubicacion': ubicacion,
          if (latitud != null) 'latitud': latitud,
          if (longitud != null) 'longitud': longitud,
        }),
      );

      if (response.statusCode >= 400) throw Exception(_errorMessage(response));
      return OfertaModel.fromJson(_unwrap(jsonDecode(response.body)));
    }

    // Con imagen: multipart. 'imagen' debe coincidir con el Swagger.
    final request = http.MultipartRequest('POST', Uri.parse(ApiConstants.ofertas));
    request.headers.addAll(await _headers(json: false));
    request.fields.addAll({
      'titulo': titulo,
      'descripcion': descripcion,
      'categoria': categoria,
      'pago': pago.toString(),
      'ubicacion': ubicacion,
      if (latitud != null) 'latitud': latitud.toString(),
      if (longitud != null) 'longitud': longitud.toString(),
    });
    request.files.add(await http.MultipartFile.fromPath('imagen', imagen.path));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode >= 400) throw Exception(_errorMessage(response));
    return OfertaModel.fromJson(_unwrap(jsonDecode(response.body)));
  }

  // ---------- Pago ----------

  Future<PagoModel> pagarPublicacion(int ofertaId, {String metodo = 'tarjeta'}) async {
    final response = await http.post(
      Uri.parse(ApiConstants.pagarOferta(ofertaId)),
      headers: await _headers(),
      body: jsonEncode({
        'monto': ApiConstants.costoPublicacion,
        'metodo': metodo,
      }),
    );

    if (response.statusCode >= 400) throw Exception(_errorMessage(response));
    return PagoModel.fromJson(_unwrap(jsonDecode(response.body)));
  }

  Future<List<PagoModel>> historialPagos() async {
    final response = await http.get(
      Uri.parse(ApiConstants.pagos),
      headers: await _headers(),
    );

    if (response.statusCode >= 400) throw Exception(_errorMessage(response));
    return _comoLista(_unwrap(jsonDecode(response.body)))
        .map(PagoModel.fromJson)
        .toList();
  }

  // ---------- Mis ofertas ----------

  Future<List<OfertaModel>> misOfertas() async {
    final response = await http.get(
      Uri.parse(ApiConstants.misOfertas),
      headers: await _headers(),
    );

    if (response.statusCode >= 400) throw Exception(_errorMessage(response));
    return _comoLista(_unwrap(jsonDecode(response.body)))
        .map(OfertaModel.fromJson)
        .toList();
  }

  Future<List<AplicacionModel>> aplicantes(int ofertaId) async {
    final response = await http.get(
      Uri.parse(ApiConstants.aplicantesDeOferta(ofertaId)),
      headers: await _headers(),
    );

    if (response.statusCode >= 400) throw Exception(_errorMessage(response));
    return _comoLista(_unwrap(jsonDecode(response.body)))
        .map(AplicacionModel.fromJson)
        .toList();
  }

  Future<void> elegirGanador(int ofertaId, int aplicacionId) async {
    final response = await http.put(
      Uri.parse(ApiConstants.elegirGanador(ofertaId)),
      headers: await _headers(),
      body: jsonEncode({'aplicacion_id': aplicacionId}),
    );

    if (response.statusCode >= 400) throw Exception(_errorMessage(response));
  }

  Future<void> eliminarOferta(int ofertaId) async {
    final response = await http.delete(
      Uri.parse(ApiConstants.oferta(ofertaId)),
      headers: await _headers(),
    );

    if (response.statusCode >= 400) throw Exception(_errorMessage(response));
  }
}