import 'package:flutter/foundation.dart';
import '../models/job_model.dart';
import '../services/firestore_service.dart';

class JobProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<JobModel> _jobs = [];
  List<JobModel> _recruiterJobs = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String? _selectedJobType;
  Map<String, int> _recruiterStats = {};

  List<JobModel> get jobs => _jobs;
  List<JobModel> get recruiterJobs => _recruiterJobs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String? get selectedJobType => _selectedJobType;
  Map<String, int> get recruiterStats => _recruiterStats;

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Set job type filter
  void setJobTypeFilter(String? type) {
    _selectedJobType = type;
    notifyListeners();
  }

  // Stream all jobs
  Stream<List<JobModel>> streamJobs() {
    return _firestoreService.getJobs(
      searchQuery: _searchQuery,
      jobType: _selectedJobType,
      status: 'active',
    );
  }

  // Stream recruiter jobs
  Stream<List<JobModel>> streamRecruiterJobs(String recruiterId) {
    return _firestoreService.getJobsByRecruiter(recruiterId);
  }

  // Create Job
  Future<bool> createJob(JobModel job) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.createJob(job);
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

  // Update Job
  Future<bool> updateJob(String jobId, Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.updateJob(jobId, data);
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

  // Delete Job
  Future<bool> deleteJob(String jobId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.deleteJob(jobId);
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

  // Get single job
  Future<JobModel?> getJob(String jobId) async {
    try {
      return await _firestoreService.getJob(jobId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Load recruiter statistics
  Future<void> loadRecruiterStats(String recruiterId) async {
    try {
      _recruiterStats = await _firestoreService.getRecruiterStats(recruiterId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}