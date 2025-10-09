import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/recruiter/recruiter_home.dart';
import '../screens/recruiter/add_job_screen.dart';
import '../screens/recruiter/manage_jobs_screen.dart';
import '../screens/recruiter/applicants_screen.dart';
import '../screens/jobseeker/jobseeker_home.dart';
import '../screens/jobseeker/job_details_screen.dart';
import '../screens/jobseeker/apply_screen.dart';
import '../screens/jobseeker/my_applications_screen.dart';
import '../../models/job_model.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: '/role-selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'];
          return LoginScreen(role: role);
        },
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'];
          return SignupScreen(role: role);
        },
      ),

      // Recruiter Routes
      GoRoute(
        path: '/recruiter',
        builder: (context, state) => const RecruiterHome(),
      ),
      GoRoute(
        path: '/recruiter/add-job',
        builder: (context, state) => const AddJobScreen(),
      ),
      GoRoute(
        path: '/recruiter/manage-jobs',
        builder: (context, state) => const ManageJobsScreen(),
      ),
      GoRoute(
        path: '/recruiter/applicants/:jobId',
        builder: (context, state) {
          final jobId = state.pathParameters['jobId']!;
          final jobTitle = state.uri.queryParameters['title'] ?? '';
          return ApplicantsScreen(jobId: jobId, jobTitle: jobTitle);
        },
      ),

      // Job Seeker Routes
      GoRoute(
        path: '/jobseeker',
        builder: (context, state) => const JobSeekerHome(),
      ),
      GoRoute(
        path: '/jobseeker/job-details/:jobId',
        builder: (context, state) {
          final jobId = state.pathParameters['jobId']!;
          return JobDetailsScreen(jobId: jobId);
        },
      ),
      GoRoute(
        path: '/jobseeker/apply/:jobId',
        builder: (context, state) {
          final job = state.extra as JobModel;
          return ApplyScreen(job: job);
        },
      ),
      GoRoute(
        path: '/jobseeker/my-applications',
        builder: (context, state) => const MyApplicationsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
}