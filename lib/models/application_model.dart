import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationModel {
  final String applicationId;
  final String jobId;
  final String jobTitle;
  final String company;
  final String userId;
  final String userName;
  final String userEmail;
  final String? userPhone;
  final String resumeUrl;
  final String coverLetter;
  final String status; // pending, reviewed, accepted, rejected
  final DateTime appliedAt;
  final DateTime? reviewedAt;

  ApplicationModel({
    required this.applicationId,
    required this.jobId,
    required this.jobTitle,
    required this.company,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userPhone,
    required this.resumeUrl,
    required this.coverLetter,
    this.status = 'pending',
    required this.appliedAt,
    this.reviewedAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'applicationId': applicationId,
      'jobId': jobId,
      'jobTitle': jobTitle,
      'company': company,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'resumeUrl': resumeUrl,
      'coverLetter': coverLetter,
      'status': status,
      'appliedAt': Timestamp.fromDate(appliedAt),
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
    };
  }

  // Create from Firestore Document
  factory ApplicationModel.fromMap(Map<String, dynamic> map) {
    return ApplicationModel(
      applicationId: map['applicationId'] ?? '',
      jobId: map['jobId'] ?? '',
      jobTitle: map['jobTitle'] ?? '',
      company: map['company'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      userPhone: map['userPhone'],
      resumeUrl: map['resumeUrl'] ?? '',
      coverLetter: map['coverLetter'] ?? '',
      status: map['status'] ?? 'pending',
      appliedAt: (map['appliedAt'] as Timestamp).toDate(),
      reviewedAt: map['reviewedAt'] != null
          ? (map['reviewedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Copy with method
  ApplicationModel copyWith({
    String? applicationId,
    String? jobId,
    String? jobTitle,
    String? company,
    String? userId,
    String? userName,
    String? userEmail,
    String? userPhone,
    String? resumeUrl,
    String? coverLetter,
    String? status,
    DateTime? appliedAt,
    DateTime? reviewedAt,
  }) {
    return ApplicationModel(
      applicationId: applicationId ?? this.applicationId,
      jobId: jobId ?? this.jobId,
      jobTitle: jobTitle ?? this.jobTitle,
      company: company ?? this.company,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      coverLetter: coverLetter ?? this.coverLetter,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }

  bool get isPending => status == 'pending';
  bool get isReviewed => status == 'reviewed';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
}