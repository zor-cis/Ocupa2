import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video.dart';
import '../utils/constants.dart';

class VideoService {
  Future<List<Video>> getVideos() async {
    final response = await http.get(
      Uri.parse(ApiConstants.videos),
    );

    if (response.statusCode >= 400) {
      throw Exception(_errorMessage(response));
    }

    final json = jsonDecode(response.body);
    final data = json['data'];

    return (data as List)
        .map((item) => Video.fromJson(item))
        .toList();
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
