import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final _authService = AuthService();

  bool isLoading = false;
  String? errorMessage;
  UserModel? currentUser;

  Future<bool> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String referralMatricula,
  }) {
    return _handle(() async {
      currentUser = await _authService.register(
        email: email,
        firstName: firstName,
        lastName: lastName,
        password: password,
        referralMatricula: referralMatricula,
      );
    });
  }

  Future<bool> login(String email, String password) {
    return _handle(() async {
      currentUser = await _authService.login(email, password);
    });
  }

  Future<bool> recoverPassword(String email, String referralMatricula) {
    return _handle(() => _authService.forgotPassword(email, referralMatricula));
  }

  Future<bool> completeProfile({
    required String firstName,
    required String lastName,
    required String cedula,
    required String gender,
    required DateTime birthDate,
  }) {
    return _handle(() async {
      currentUser = await _authService.completeProfile(
        firstName: firstName,
        lastName: lastName,
        cedula: cedula,
        gender: gender,
        birthDate: birthDate,
      );
    });
  }

  Future<bool> changePassword(String newPassword) {
    return _handle(() => _authService.changePassword(newPassword));
  }

  Future<void> loadSession() async {
    currentUser = await _authService.getCurrentUser();
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    currentUser = null;
    notifyListeners();
  }

  Future<bool> _handle(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await action();
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}