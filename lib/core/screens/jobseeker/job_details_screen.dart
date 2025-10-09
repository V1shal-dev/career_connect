import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../utils/helpers.dart';
import 'package:career_connect/providers/auth_provider.dart';
import 'package:career_connect/providers/job_provider.dart';
import 'package:career_connect/providers/application_provider.dart';
import 'package:career_connect/models/job_model.dart';

class JobDetailsScreen extends StatefulWidget {
  final String jobId;

  const JobDetailsScreen({Key? key, required this.jobId}) : super(key: key);

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  bool _hasApplied = false;
  bool _isLoading = true;
  JobModel? _cachedJob;

  @override
  void initState() {
    super.initState();
    _checkApplicationStatus();
  }

  Future<void> _checkApplicationStatus() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final applicationProvider = Provider.of<ApplicationProvider>(context, listen: false);

      if (authProvider.currentUser != null) {
        final hasApplied = await applicationProvider.checkIfApplied(
          authProvider.currentUser!.uid,
          widget.jobId,
        );
        if (mounted) {
          setState(() {
            _hasApplied = hasApplied;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);

    return Scaffold(
      body: FutureBuilder<JobModel?>(
        future: jobProvider.getJob(widget.jobId),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              decoration: BoxDecoration(
                gradient: AppColors.secondaryGradient,
              ),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }

          // Error state
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Error'),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'Failed to load job details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                      ),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            );
          }

          // No data state
          if (!snapshot.hasData || snapshot.data == null) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Job Not Found'),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.work_off, size: 60, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Job not found',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This job may have been removed',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                      ),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            );
          }

          final job = snapshot.data!;
          _cachedJob = job;

          // Build the main content
          return CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    job.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.secondaryGradient,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.business_center_rounded,
                        size: 80,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Company Info Card
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.company,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _InfoRow(
                              icon: Icons.location_on_outlined,
                              text: job.location,
                            ),
                            const SizedBox(height: 8),
                            _InfoRow(
                              icon: Icons.work_outline,
                              text: job.type,
                            ),
                            const SizedBox(height: 8),
                            _InfoRow(
                              icon: Icons.attach_money,
                              text: job.salary,
                            ),
                            const SizedBox(height: 8),
                            _InfoRow(
                              icon: Icons.access_time,
                              text: 'Posted ${Helpers.timeAgo(job.createdAt)}',
                            ),
                            if (job.contactEmail != null && job.contactEmail!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              _InfoRow(
                                icon: Icons.email_outlined,
                                text: job.contactEmail!,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Job Description
                    Text(
                      'Job Description',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      job.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Requirements
                    if (job.requirements.isNotEmpty) ...[
                      Text(
                        'Requirements',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...job.requirements.map((requirement) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.success,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  requirement,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],

                    const SizedBox(height: 100), // Space for bottom button
                  ]),
                ),
              ),
            ],
          );
        },
      ),
      // Bottom Apply Button
      bottomNavigationBar: _isLoading
          ? null
          : Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _hasApplied
                  ? null
                  : () async {
                if (_cachedJob != null && mounted) {
                  context.push('/jobseeker/apply/${widget.jobId}', extra: _cachedJob);
                } else {
                  final jobProvider = Provider.of<JobProvider>(context, listen: false);
                  final job = await jobProvider.getJob(widget.jobId);
                  if (job != null && mounted) {
                    context.push('/jobseeker/apply/${widget.jobId}', extra: job);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                disabledBackgroundColor: Colors.grey.shade400,
              ),
              child: Text(
                _hasApplied ? 'Already Applied' : AppStrings.applyNow,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Info Row Widget
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}