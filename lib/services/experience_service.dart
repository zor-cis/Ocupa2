import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/experience.dart';
import '../models/job_type.dart';
import '../utils/constants.dart';

class ExperienceService {
  Future<List<JobType>> getJobTypes() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(ApiConstants.jobTypes),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode >= 400) {
      throw Exception(_errorMessage(response));
    }

    final json = jsonDecode(response.body);
    final data = json['data'];

    if (data == null) return [];

    return (data as List)
        .map((item) => JobType.fromJson(item))
        .toList();
  }

  Future<List<Experience>> getExperiences() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(ApiConstants.experiences),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode >= 400) {
      throw Exception(_errorMessage(response));
    }

    final json = jsonDecode(response.body);
    final data = json['data'];

    if (data == null) return [];

    return (data as List)
        .map((item) => Experience.fromJson(item))
        .toList();
  }

  Future<void> addExperience({
    required String title,
    required String description,
    String? jobTypeKey,
    String? certificateImage,
  }) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse(ApiConstants.experiences),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'jobTypeKey': jobTypeKey,
        'certificateImage': certificateImage,
      }),
    );

    if (response.statusCode >= 400) {
      throw Exception(_errorMessage(response));
    }
  }

  Future<void> deleteExperience(String id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('${ApiConstants.experiences}/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode >= 400) {
      throw Exception(_errorMessage(response));
    }
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
