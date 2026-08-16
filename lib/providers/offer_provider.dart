import 'package:flutter/foundation.dart';

import '../models/application.dart';
import '../models/offer.dart';
import '../services/offer_service.dart';

class OfferProvider extends ChangeNotifier {
  final OfferService _offerService = OfferService();

  List<Offer> _offers = [];
  List<Application> _myApplications = [];
  List<Offer> _likedOffers = [];
  Offer? _selectedOffer;

  bool _isLoading = false;
  bool _isApplying = false;
  String? _errorMessage;

  List<Offer> get offers => _offers;
  List<Application> get myApplications => _myApplications;
  List<Offer> get likedOffers => _likedOffers;
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

  Future<bool> loadMyApplications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _myApplications = await _offerService.getMyApplications();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loadLikedOffers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _likedOffers = await _offerService.getLikedOffers();
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

  Future<bool> unlikeOffer(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _offerService.unlikeOffer(id);
      _likedOffers.removeWhere((offer) => offer.id == id);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleLike(String id) async {
    _errorMessage = null;
    
    // Encontrar la oferta en las listas locales
    final offerIndex = _offers.indexWhere((o) => o.id == id);
    final likedIndex = _likedOffers.indexWhere((o) => o.id == id);
    
    final Offer? offer = offerIndex != -1 ? _offers[offerIndex] : (likedIndex != -1 ? _likedOffers[likedIndex] : null);
    if (offer == null) return false;

    final bool currentlyLiked = offer.likedByMe;
    
    try {
      if (currentlyLiked) {
        await _offerService.unlikeOffer(id);
        _likedOffers.removeWhere((o) => o.id == id);
      } else {
        await _offerService.likeOffer(id);
        if (!_likedOffers.any((o) => o.id == id)) {
          _likedOffers.add(offer);
        }
      }

      // Actualizar estado local en todas las listas
      _updateOfferLikeStatus(id, !currentlyLiked);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  void _updateOfferLikeStatus(String id, bool isLiked) {
    // Actualizar en lista general
    final offerIndex = _offers.indexWhere((o) => o.id == id);
    if (offerIndex != -1) {
      final o = _offers[offerIndex];
      _offers[offerIndex] = _cloneOfferWithLike(o, isLiked);
    }

    // Actualizar en oferta seleccionada
    if (_selectedOffer?.id == id) {
      _selectedOffer = _cloneOfferWithLike(_selectedOffer!, isLiked);
    }
    
    notifyListeners();
  }

  Offer _cloneOfferWithLike(Offer o, bool isLiked) {
    return Offer(
      id: o.id,
      jobTypeKey: o.jobTypeKey,
      jobTypeName: o.jobTypeName,
      contractType: o.contractType,
      description: o.description,
      address: o.address,
      location: o.location,
      payment: o.payment,
      photo: o.photo,
      deadline: o.deadline,
      customAnswers: o.customAnswers,
      questions: o.questions,
      status: o.status,
      applicantsCount: o.applicantsCount,
      likesCount: isLiked ? o.likesCount + 1 : (o.likesCount > 0 ? o.likesCount - 1 : 0),
      createdAt: o.createdAt,
      updatedAt: o.updatedAt,
      isIdentityRevealed: o.isIdentityRevealed,
      likedByMe: isLiked,
    );
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}