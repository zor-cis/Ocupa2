import 'package:flutter/foundation.dart';
import '../models/payment_transaction.dart';
import '../services/payment_service.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentService _paymentService = PaymentService();

  List<PaymentTransaction> _payments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PaymentTransaction> get payments => _payments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPayments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedPayments = await _paymentService.getMyPayments();
      // Ordenar por fecha descendente
      fetchedPayments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _payments = fetchedPayments;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
