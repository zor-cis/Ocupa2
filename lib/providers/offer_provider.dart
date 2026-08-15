import 'package:flutter/foundation.dart';

import '../models/offer.dart';
import '../services/offer_service.dart';

class OfferProvider extends ChangeNotifier {
  final OfferService _offerService = OfferService();

  List<Offer> _offers = [];
  Offer? _selectedOffer;

  bool _isLoading = false;
  bool _isApplying = false;
  String? _errorMessage;

  List<Offer> get offers => _offers;
  Offer? get selectedOffer => _selectedOffer;

  bool get isLoading => _isLoading;
  bool get isApplying => _isApplying;

  String? get errorMessage => _errorMessage;

  Future<bool> loadOffers({
    String? jobTypeKey,
    String? contractType,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _offers = await _offerService.getOffers(
        jobTypeKey: jobTypeKey,
        contractType: contractType,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loadOfferDetail(String id) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedOffer = null;
    notifyListeners();

    try {
      _selectedOffer = await _offerService.getOfferDetail(id);

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> applyToOffer(
    String id,
    String comment,
    List<Map<String, dynamic>> answers,
  ) async {
    _isApplying = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _offerService.applyToOffer(
        id,
        comment,
        answers,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isApplying = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}