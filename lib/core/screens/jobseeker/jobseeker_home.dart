import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import 'package:career_connect/providers/auth_provider.dart';
import 'package:career_connect/providers/job_provider.dart';
import 'package:career_connect/models/job_model.dart';
import 'package:career_connect/core/utils/helpers.dart';
import '/providers/application_provider.dart';
import '/models/application_model.dart';

class JobSeekerHome extends StatefulWidget {
  const JobSeekerHome({Key? key}) : super(key: key);

  @override
  State<JobSeekerHome> createState() => _JobSeekerHomeState();
}

class _JobSeekerHomeState extends State<JobSeekerHome> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? AppStrings.browseJobs : AppStrings.myApplications),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          PopupMenuButton(
            icon: CircleAvatar(
              backgroundColor: AppColors.secondary,
              child: Text(
                user?.name.substring(0, 1).toUpperCase() ?? 'J',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Profile'),
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to profile
                  },
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text(AppStrings.logout),
                  contentPadding: EdgeInsets.zero,
                  onTap: () async {
                    Navigator.pop(context);
                    await authProvider.signOut();
                    if (context.mounted) {
                      context.go('/role-selection');
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _selectedIndex == 0 ? _buildBrowseJobs() : _buildMyApplications(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Browse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            label: 'Applications',
          ),
        ],
      ),
    );
  }

  Widget _buildBrowseJobs() {
    final jobProvider = Provider.of<JobProvider>(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: AppStrings.searchJobs,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      jobProvider.setSearchQuery('');
                    },
                  )
                      : null,
                ),
                onChanged: (value) {
                  jobProvider.setSearchQuery(value);
                },
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _FilterChip(
                      label: 'All',
                      isSelected: jobProvider.selectedJobType == null,
                      onTap: () => jobProvider.setJobTypeFilter(null),
                    ),
                    _FilterChip(
                      label: 'Full-time',
                      isSelected: jobProvider.selectedJobType == 'Full-time',
                      onTap: () => jobProvider.setJobTypeFilter('Full-time'),
                    ),
                    _FilterChip(
                      label: 'Part-time',
                      isSelected: jobProvider.selectedJobType == 'Part-time',
                      onTap: () => jobProvider.setJobTypeFilter('Part-time'),
                    ),
                    _FilterChip(
                      label: 'Remote',
                      isSelected: jobProvider.selectedJobType == 'Remote',
                      onTap: () => jobProvider.setJobTypeFilter('Remote'),
                    ),
                    _FilterChip(
                      label: 'Internship',
                      isSelected: jobProvider.selectedJobType == 'Internship',
                      onTap: () => jobProvider.setJobTypeFilter('Internship'),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
            ],
          ),
        ),

        Expanded(
          child: StreamBuilder<List<JobModel>>(
            stream: jobProvider.streamJobs(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text('Error: ${snapshot.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => setState(() {}),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.work_off_outlined,
                        size: 80,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.noJobsFound,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try adjusting your search filters',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final jobs = snapshot.data!;

              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                  await Future.delayed(const Duration(seconds: 1));
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: jobs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    return _JobCard(
                      job: job,
                      onTap: () {
                        context.push('/jobseeker/job-details/${job.jobId}');
                      },
                    ).animate().fadeIn(
                      delay: Duration(milliseconds: index * 50),
                      duration: 400.ms,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMyApplications() {
    final authProvider = Provider.of<AuthProvider>(context);
    final applicationProvider = Provider.of<ApplicationProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return const Center(child: Text('Please login'));
    }

    return StreamBuilder<List<ApplicationModel>>(
      stream: applicationProvider.streamUserApplications(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 80,
                  color: AppColors.textLight,
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.noApplicationsFound,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Start applying to jobs',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        final applications = snapshot.data!;

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: applications.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final application = applications[index];
            return _ApplicationCard(application: application);
          },
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.white,
        selectedColor: AppColors.secondary.withOpacity(0.2),
        checkmarkColor: AppColors.secondary,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.secondary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback onTap;

  const _JobCard({
    required this.job,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.business_center_outlined,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job.company,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(job.location, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(width: 16),
                  Icon(Icons.work_outline, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(job.type, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    job.salary,
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Posted ${Helpers.timeAgo(job.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final ApplicationModel application;

  const _ApplicationCard({required this.application});

  Color _getStatusColor() {
    switch (application.status) {
      case 'pending':
        return AppColors.warning;
      case 'reviewed':
        return AppColors.info;
      case 'accepted':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (application.status) {
      case 'pending':
        return Icons.schedule;
      case 'reviewed':
        return Icons.visibility;
      case 'accepted':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.jobTitle,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        application.company,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getStatusIcon(), size: 16, color: _getStatusColor()),
                      const SizedBox(width: 4),
                      Text(
                        application.status.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Applied ${Helpers.timeAgo(application.appliedAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            if (application.reviewedAt != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.update, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Updated ${Helpers.timeAgo(application.reviewedAt!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}