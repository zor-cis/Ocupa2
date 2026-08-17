import 'dart:io';

import 'package:flutter/material.dart';

import '../models/oferta_model.dart';
import '../services/ofertas_service.dart';

/// Estado del módulo 4. Sigue el mismo patrón que AuthProvider.
class OfertasProvider extends ChangeNotifier {
  final _service = OfertasService();

  // --- Estado compartido ---
  bool isLoading = false;
  String? errorMessage;

  // --- Catálogo ---
  List<JobTypeModel> jobTypes = [];

  // --- Mis ofertas ---
  List<OfertaModel> misOfertas = [];

  // --- Aplicantes de la oferta abierta ---
  List<AplicacionModel> aplicantes = [];

  // --- Historial de pagos ---
  List<PagoModel> misPagos = [];

  void _empezar() {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
  }

  void _terminar() {
    isLoading = false;
    notifyListeners();
  }

  /// Deja el mensaje limpio: quita el "Exception: " que antepone Dart.
  String _limpiar(Object e) =>
      e.toString().replaceFirst('Exception: ', '');

  // ---------- Catálogo ----------

  Future<void> cargarJobTypes() async {
    if (jobTypes.isNotEmpty) return; // ya está en memoria
    _empezar();
    try {
      jobTypes = await _service.jobTypes();
    } catch (e) {
      errorMessage = _limpiar(e);
    } finally {
      _terminar();
    }
  }

  JobTypeModel? jobTypePorKey(String? key) {
    if (key == null) return null;
    for (final t in jobTypes) {
      if (t.key == key) return t;
    }
    return null;
  }

  // ---------- Publicar (los 3 pasos) ----------

  /// Sube la foto, cobra el US$1 y crea la oferta.
  /// Devuelve true si todo salió bien.
  Future<bool> publicarOferta({
    required File foto,
    required String jobTypeKey,
    required String contractType,
    required String description,
    required String address,
    required double amount,
    required String cardNumber,
    required String cvv,
    required int expMonth,
    required int expYear,
    required String cardholder,
    DateTime? deadline,
    Map<String, String>? customAnswers,
  }) async {
    _empezar();
    try {
      // 1. Foto
      final photoUrl = await _service.subirFoto(foto);

      // 2. Pago
      final pago = await _service.cobrarTarjeta(
        cardNumber: cardNumber,
        cvv: cvv,
        expMonth: expMonth,
        expYear: expYear,
        cardholder: cardholder,
      );

      // 3. Oferta
      await _service.crearOferta(
        jobTypeKey: jobTypeKey,
        contractType: contractType,
        description: description,
        address: address,
        photoUrl: photoUrl,
        paymentId: pago.id,
        amount: amount,
        deadline: deadline,
        customAnswers: customAnswers,
      );

      await cargarMisOfertas(silencioso: true);
      return true;
    } catch (e) {
      errorMessage = _limpiar(e);
      return false;
    } finally {
      _terminar();
    }
  }

  // ---------- Mis ofertas ----------

  Future<void> cargarMisOfertas({bool silencioso = false}) async {
    if (!silencioso) _empezar();
    try {
      misOfertas = await _service.misOfertas();
    } catch (e) {
      errorMessage = _limpiar(e);
    } finally {
      if (!silencioso) {
        _terminar();
      } else {
        notifyListeners();
      }
    }
  }

  Future<bool> desactivarOferta(String ofertaId) async {
    try {
      await _service.desactivarOferta(ofertaId);
      await cargarMisOfertas(silencioso: true);
      return true;
    } catch (e) {
      errorMessage = _limpiar(e);
      notifyListeners();
      return false;
    }
  }

  // ---------- Aplicantes ----------

  Future<void> cargarAplicantes(String ofertaId) async {
    _empezar();
    aplicantes = [];
    try {
      aplicantes = await _service.aplicantes(ofertaId);
    } catch (e) {
      errorMessage = _limpiar(e);
    } finally {
      _terminar();
    }
  }

  Future<bool> elegirGanador(String ofertaId, String aplicacionId) async {
    try {
      await _service.elegirGanador(aplicacionId);
      await cargarAplicantes(ofertaId);
      return true;
    } catch (e) {
      errorMessage = _limpiar(e);
      notifyListeners();
      return false;
    }
  }

  // ---------- Pagos ----------

  Future<void> cargarMisPagos() async {
    _empezar();
    try {
      misPagos = await _service.misPagos();
    } catch (e) {
      errorMessage = _limpiar(e);
    } finally {
      _terminar();
    }
  }
}