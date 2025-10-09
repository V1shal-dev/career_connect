import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/application_model.dart';
import '../services/firestore_service.dart';
import '../services/cloudinary_service.dart';

class ApplicationProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  List<ApplicationModel> _applications = [];
  bool _isLoading = false;
  bool _isUploading = false;
  String? _errorMessage;
  double _uploadProgress = 0.0;

  List<ApplicationModel> get applications => _applications;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;
  double get uploadProgress => _uploadProgress;

  // Stream user applications
  Stream<List<ApplicationModel>> streamUserApplications(String userId) {
    return _firestoreService.getApplicationsByUser(userId);
  }

  // Stream job applications
  Stream<List<ApplicationModel>> streamJobApplications(String jobId) {
    return _firestoreService.getApplicationsByJob(jobId);
  }

  // Stream recruiter applications
  Stream<List<ApplicationModel>> streamRecruiterApplications(String recruiterId) {
    return _firestoreService.getApplicationsForRecruiter(recruiterId);
  }

  // Upload resume to Cloudinary
  Future<String?> uploadResume(File file) async {
    _isUploading = true;
    _uploadProgress = 0.0;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validate file
      if (!_cloudinaryService.validateFile(file)) {
        _errorMessage = 'Invalid file. Please upload PDF, DOC, or DOCX under 5MB';
        _isUploading = false;
        notifyListeners();
        return null;
      }

      // Upload to Cloudinary
      _uploadProgress = 0.5;
      notifyListeners();

      final url = await _cloudinaryService.uploadFile(file);

      if (url != null) {
        _uploadProgress = 1.0;
        _isUploading = false;
        notifyListeners();
        return url;
      }

      _errorMessage = 'Failed to upload resume';
      _isUploading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _errorMessage = 'Upload failed: ${e.toString()}';
      _isUploading = false;
      notifyListeners();
      return null;
    }
  }

  // Submit Application
  Future<bool> submitApplication(ApplicationModel application) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if already applied
      final hasApplied = await _firestoreService.hasUserApplied(
        application.userId,
        application.jobId,
      );

      if (hasApplied) {
        _errorMessage = 'You have already applied for this job';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _firestoreService.createApplication(application);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update application status
  Future<bool> updateApplicationStatus(String applicationId, String status) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.updateApplicationStatus(applicationId, status);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Check if user has applied
  Future<bool> checkIfApplied(String userId, String jobId) async {
    try {
      return await _firestoreService.hasUserApplied(userId, jobId);
    } catch (e) {
      return false;
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}