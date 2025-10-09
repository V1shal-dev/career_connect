import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role; // 'recruiter' or 'jobseeker'
  final String? phone;
  final String? company; // For recruiters
  final String? resumeUrl; // For job seekers
  final String? profilePicture;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    this.company,
    this.resumeUrl,
    this.profilePicture,
    required this.createdAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'phone': phone,
      'company': company,
      'resumeUrl': resumeUrl,
      'profilePicture': profilePicture,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create from Firestore Document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'jobseeker',
      phone: map['phone'],
      company: map['company'],
      resumeUrl: map['resumeUrl'],
      profilePicture: map['profilePicture'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Copy with method for updates
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? role,
    String? phone,
    String? company,
    String? resumeUrl,
    String? profilePicture,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      profilePicture: profilePicture ?? this.profilePicture,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isRecruiter => role == 'recruiter';
  bool get isJobSeeker => role == 'jobseeker';
}