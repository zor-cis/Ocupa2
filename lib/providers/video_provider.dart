import 'package:flutter/foundation.dart';
import '../models/video.dart';
import '../services/video_service.dart';

class VideoProvider extends ChangeNotifier {
  final VideoService _videoService = VideoService();

  List<Video> _videos = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Video> get videos => _videos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadVideos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _videos = await _videoService.getVideos();
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
