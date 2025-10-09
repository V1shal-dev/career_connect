import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/job_model.dart';
import '../models/application_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== USER OPERATIONS ====================

  // Create User
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      throw 'Failed to create user profile';
    }
  }

  // Get User
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update User
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw 'Failed to update user profile';
    }
  }

  // ==================== JOB OPERATIONS ====================

  // Create Job
  Future<String> createJob(JobModel job) async {
    try {
      final docRef = await _firestore.collection('jobs').add(job.toMap());
      await docRef.update({'jobId': docRef.id});
      return docRef.id;
    } catch (e) {
      throw 'Failed to create job posting';
    }
  }

  // Get All Jobs (with optional filters)
  Stream<List<JobModel>> getJobs({
    String? searchQuery,
    String? jobType,
    String? status,
  }) {
    try {
      Query query = _firestore.collection('jobs').orderBy('createdAt', descending: true);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      if (jobType != null && jobType.isNotEmpty) {
        query = query.where('type', isEqualTo: jobType);
      }

      return query.snapshots().map((snapshot) {
        List<JobModel> jobs = snapshot.docs
            .map((doc) => JobModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList();

        // Apply search filter (client-side)
        if (searchQuery != null && searchQuery.isNotEmpty) {
          final lowerQuery = searchQuery.toLowerCase();
          jobs = jobs.where((job) {
            return job.title.toLowerCase().contains(lowerQuery) ||
                job.company.toLowerCase().contains(lowerQuery) ||
                job.location.toLowerCase().contains(lowerQuery);
          }).toList();
        }

        return jobs;
      });
    } catch (e) {
      return Stream.value([]);
    }
  }

  // Get Jobs by Recruiter
  Stream<List<JobModel>> getJobsByRecruiter(String recruiterId) {
    try {
      return _firestore
          .collection('jobs')
          .where('recruiterId', isEqualTo: recruiterId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => JobModel.fromMap(doc.data()))
          .toList());
    } catch (e) {
      return Stream.value([]);
    }
  }

  // Get Single Job
  Future<JobModel?> getJob(String jobId) async {
    try {
      final doc = await _firestore.collection('jobs').doc(jobId).get();
      if (doc.exists) {
        return JobModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update Job
  Future<void> updateJob(String jobId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = Timestamp.now();
      await _firestore.collection('jobs').doc(jobId).update(data);
    } catch (e) {
      throw 'Failed to update job';
    }
  }

  // Delete Job
  Future<void> deleteJob(String jobId) async {
    try {
      // Delete all applications for this job first
      final applications = await _firestore
          .collection('applications')
          .where('jobId', isEqualTo: jobId)
          .get();

      for (var doc in applications.docs) {
        await doc.reference.delete();
      }

      // Delete the job
      await _firestore.collection('jobs').doc(jobId).delete();
    } catch (e) {
      throw 'Failed to delete job';
    }
  }

  // ==================== APPLICATION OPERATIONS ====================

  // Create Application
  Future<String> createApplication(ApplicationModel application) async {
    try {
      final docRef = await _firestore.collection('applications').add(application.toMap());
      await docRef.update({'applicationId': docRef.id});

      // Increment applicants count
      await _firestore.collection('jobs').doc(application.jobId).update({
        'applicantsCount': FieldValue.increment(1),
      });

      return docRef.id;
    } catch (e) {
      throw 'Failed to submit application';
    }
  }

  // Get Applications by User
  Stream<List<ApplicationModel>> getApplicationsByUser(String userId) {
    try {
      return _firestore
          .collection('applications')
          .where('userId', isEqualTo: userId)
          .orderBy('appliedAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => ApplicationModel.fromMap(doc.data()))
          .toList());
    } catch (e) {
      return Stream.value([]);
    }
  }

  // Get Applications by Job
  Stream<List<ApplicationModel>> getApplicationsByJob(String jobId) {
    try {
      return _firestore
          .collection('applications')
          .where('jobId', isEqualTo: jobId)
          .orderBy('appliedAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => ApplicationModel.fromMap(doc.data()))
          .toList());
    } catch (e) {
      return Stream.value([]);
    }
  }

  // Get All Applications for Recruiter (across all their jobs)
  Stream<List<ApplicationModel>> getApplicationsForRecruiter(String recruiterId) async* {
    try {
      // First get all jobs by this recruiter
      final jobsSnapshot = await _firestore
          .collection('jobs')
          .where('recruiterId', isEqualTo: recruiterId)
          .get();

      if (jobsSnapshot.docs.isEmpty) {
        yield [];
        return;
      }

      final jobIds = jobsSnapshot.docs.map((doc) => doc.id).toList();

      // Get applications for these jobs
      yield* _firestore
          .collection('applications')
          .where('jobId', whereIn: jobIds)
          .orderBy('appliedAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => ApplicationModel.fromMap(doc.data()))
          .toList());
    } catch (e) {
      yield [];
    }
  }

  // Update Application Status
  Future<void> updateApplicationStatus(String applicationId, String status) async {
    try {
      await _firestore.collection('applications').doc(applicationId).update({
        'status': status,
        'reviewedAt': Timestamp.now(),
      });
    } catch (e) {
      throw 'Failed to update application status';
    }
  }

  // Check if user already applied
  Future<bool> hasUserApplied(String userId, String jobId) async {
    try {
      final snapshot = await _firestore
          .collection('applications')
          .where('userId', isEqualTo: userId)
          .where('jobId', isEqualTo: jobId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // ==================== STATISTICS ====================

  // Get Recruiter Stats
  Future<Map<String, int>> getRecruiterStats(String recruiterId) async {
    try {
      // Get total jobs
      final jobsSnapshot = await _firestore
          .collection('jobs')
          .where('recruiterId', isEqualTo: recruiterId)
          .get();

      final totalJobs = jobsSnapshot.docs.length;

      // Get active jobs
      final activeJobsCount = jobsSnapshot.docs
          .where((doc) => doc.data()['status'] == 'active')
          .length;

      // Get total applicants
      int totalApplicants = 0;
      for (var doc in jobsSnapshot.docs) {
        totalApplicants += (doc.data()['applicantsCount'] as int? ?? 0);
      }

      return {
        'totalJobs': totalJobs,
        'activeJobs': activeJobsCount,
        'totalApplicants': totalApplicants,
      };
    } catch (e) {
      return {
        'totalJobs': 0,
        'activeJobs': 0,
        'totalApplicants': 0,
      };
    }
  }
}