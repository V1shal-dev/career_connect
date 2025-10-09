import 'package:cloud_firestore/cloud_firestore.dart';

class JobModel {
  final String jobId;
  final String title;
  final String company;
  final String location;
  final String salary;
  final String type; // Full-time, Part-time, Contract, Internship
  final String description;
  final List<String> requirements;
  final String recruiterId;
  final String recruiterName;
  final String? contactEmail;
  final String status; // active, closed
  final int applicantsCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  JobModel({
    required this.jobId,
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.type,
    required this.description,
    required this.requirements,
    required this.recruiterId,
    required this.recruiterName,
    this.contactEmail,
    this.status = 'active',
    this.applicantsCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'title': title,
      'company': company,
      'location': location,
      'salary': salary,
      'type': type,
      'description': description,
      'requirements': requirements,
      'recruiterId': recruiterId,
      'recruiterName': recruiterName,
      'contactEmail': contactEmail,
      'status': status,
      'applicantsCount': applicantsCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Create from Firestore Document
  factory JobModel.fromMap(Map<String, dynamic> map) {
    return JobModel(
      jobId: map['jobId'] ?? '',
      title: map['title'] ?? '',
      company: map['company'] ?? '',
      location: map['location'] ?? '',
      salary: map['salary'] ?? '',
      type: map['type'] ?? '',
      description: map['description'] ?? '',
      requirements: List<String>.from(map['requirements'] ?? []),
      recruiterId: map['recruiterId'] ?? '',
      recruiterName: map['recruiterName'] ?? '',
      contactEmail: map['contactEmail'],
      status: map['status'] ?? 'active',
      applicantsCount: map['applicantsCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Copy with method
  JobModel copyWith({
    String? jobId,
    String? title,
    String? company,
    String? location,
    String? salary,
    String? type,
    String? description,
    List<String>? requirements,
    String? recruiterId,
    String? recruiterName,
    String? contactEmail,
    String? status,
    int? applicantsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JobModel(
      jobId: jobId ?? this.jobId,
      title: title ?? this.title,
      company: company ?? this.company,
      location: location ?? this.location,
      salary: salary ?? this.salary,
      type: type ?? this.type,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      recruiterId: recruiterId ?? this.recruiterId,
      recruiterName: recruiterName ?? this.recruiterName,
      contactEmail: contactEmail ?? this.contactEmail,
      status: status ?? this.status,
      applicantsCount: applicantsCount ?? this.applicantsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isActive => status == 'active';
}