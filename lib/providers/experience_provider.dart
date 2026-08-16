import 'package:flutter/foundation.dart';
import '../models/experience.dart';
import '../models/job_type.dart';
import '../services/experience_service.dart';

class ExperienceProvider extends ChangeNotifier {
  final ExperienceService _experienceService = ExperienceService();

  List<Experience> _experiences = [];
  List<JobType> _jobTypes = [];
  bool _isLoading = false;
  bool _isAdding = false;
  String? _errorMessage;

  List<Experience> get experiences => _experiences;
  List<JobType> get jobTypes => _jobTypes;
  bool get isLoading => _isLoading;
  bool get isAdding => _isAdding;
  String? get errorMessage => _errorMessage;

  Future<void> loadJobTypes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _jobTypes = await _experienceService.getJobTypes();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadExperiences() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _experiences = await _experienceService.getExperiences();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addExperience({
    required String title,
    required String description,
    String? jobTypeKey,
    String? certificateImage,
  }) async {
    _isAdding = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _experienceService.addExperience(
        title: title,
        description: description,
        jobTypeKey: jobTypeKey,
        certificateImage: certificateImage,
      );
      await loadExperiences();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isAdding = false;
      notifyListeners();
    }
  }

  Future<bool> deleteExperience(String id) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await _experienceService.deleteExperience(id);
      await loadExperiences();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
