import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_item.dart';
import '../utils/constants.dart';

class NewsService {
  Future<List<NewsItem>> getNews({int limit = 12}) async {
    final uri = Uri.parse(ApiConstants.news).replace(
      queryParameters: {'limit': limit.toString()},
    );

    final response = await http.get(uri);

    if (response.statusCode >= 400) {
      throw Exception(_errorMessage(response));
    }

    final json = jsonDecode(response.body);
    final data = json['data'];

    if (data == null) {
      return [];
    }

    return (data as List)
        .map((item) => NewsItem.fromJson(item))
        .toList();
  }

  String _errorMessage(http.Response response) {
    try {
      final json = jsonDecode(response.body);
      return json['message'] ??
          json['error'] ??
          'Error al cargar noticias (${response.statusCode})';
    } catch (_) {
      return 'Error del servidor (${response.statusCode})';
    }
  }
}
