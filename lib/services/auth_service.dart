import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService {
  Future<UserModel> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String referralMatricula,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'password': password,
        'referralMatricula': referralMatricula,
      }),
    );

    if (response.statusCode >= 400) {
      throw Exception(_errorMessage(response));
    }

    final data = _unwrap(jsonDecode(response.body));
    final user = UserModel.fromJson(data['user']);
    await _saveSession(data['token'] ?? '', user);
    return user;
  }

  Future<UserModel> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode >= 400) {
      throw Exception(_errorMessage(response));
    }

    final data = _unwrap(jsonDecode(response.body));
    final user = UserModel.fromJson(data['user']);
    await _saveSession(data['token'] ?? '', user);
    return user;
  }

  Future<void> forgotPassword(String email, String referralMatricula) async {
    final response = await http.post(
      Uri.parse(ApiConstants.forgotPassword),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'referralMatricula': referralMatricula,
      }),
    );

    if (response.statusCode >= 400) {
      throw Exception(_errorMessage(response));
    }
  }

  Future<UserModel> completeProfile({
    required String firstName,
    required String lastName,
    required String cedula,
    required String gender,
    required DateTime birthDate,
  }) async {
    final token = await getToken();

    final response = await http.put(
      Uri.parse(ApiConstants.updateProfile),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'cedula': cedula,
        'gender': gender,
        'birthDate': DateFormat('yyyy-MM-dd').format(birthDate),
      }),
    );

    if (response.statusCode >= 400) {
      throw Exception(_errorMessage(response));
    }

    final data = _unwrap(jsonDecode(response.body));
    final user = UserModel.fromJson(data);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));

    return user;
  }

  Future<void> changePassword(String newPassword) async {
    final token = await getToken();

    final response = await http.put(
      Uri.parse(ApiConstants.updatePassword),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'password': newPassword}),
    );

    if (response.statusCode >= 400) {
      throw Exception(_errorMessage(response));
    }
  }

  Future<UserModel?> getCurrentUser() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.me),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode >= 400) return await _savedUser();

      final data = _unwrap(jsonDecode(response.body));
      final user = UserModel.fromJson(data);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(user.toJson()));

      return user;
    } catch (_) {
      return await _savedUser();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<UserModel?> _savedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('user');
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw));
  }

  Future<void> _saveSession(String token, UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user', jsonEncode(user.toJson()));
  }

  // El API envuelve las respuestas como { "ok": true, "data": {...} }
  Map<String, dynamic> _unwrap(Map<String, dynamic> json) {
    return json['data'] is Map<String, dynamic> ? json['data'] : json;
  }

  String _errorMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      return data['message'] ?? data['error'] ?? 'Error del servidor';
    } catch (_) {
      return 'Error del servidor (${response.statusCode})';
    }
  }
}