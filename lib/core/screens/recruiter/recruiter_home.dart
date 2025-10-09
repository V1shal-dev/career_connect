import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import 'package:career_connect/providers/auth_provider.dart';
import 'package:career_connect/providers/job_provider.dart';
import 'package:career_connect/models/job_model.dart';
import '/core/utils/helpers.dart';


class RecruiterHome extends StatefulWidget {
  const RecruiterHome({Key? key}) : super(key: key);

  @override
  State<RecruiterHome> createState() => _RecruiterHomeState();
}

class _RecruiterHomeState extends State<RecruiterHome> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final jobProvider = Provider.of<JobProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      jobProvider.loadRecruiterStats(authProvider.currentUser!.uid);
    }
  }

  Future<void> _handleDeleteJob(String jobId) async {
    final confirm = await Helpers.showConfirmDialog(
      context,
      title: 'Delete Job',
      message: 'Are you sure you want to delete this job?',
      confirmText: 'Delete',
    );

    if (confirm) {
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      Helpers.showLoadingDialog(context);
      final success = await jobProvider.deleteJob(jobId);
      if (!mounted) return;
      Helpers.hideLoadingDialog(context);

      if (success) {
        Helpers.showSnackBar(context, 'Job deleted successfully');
        _loadStats();
      } else {
        Helpers.showSnackBar(context, 'Failed to delete job', isError: true);
      }
    }
  }

  Future<void> _handleToggleStatus(JobModel job) async {
    final newStatus = job.status == 'active' ? 'closed' : 'active';
    final jobProvider = Provider.of<JobProvider>(context, listen: false);

    Helpers.showLoadingDialog(context);
    final success = await jobProvider.updateJob(job.jobId, {'status': newStatus});
    if (!mounted) return;
    Helpers.hideLoadingDialog(context);

    if (success) {
      Helpers.showSnackBar(context, 'Job status updated');
    } else {
      Helpers.showSnackBar(context, 'Failed to update status', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.dashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          PopupMenuButton(
            icon: CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Text(
                user?.name.substring(0, 1).toUpperCase() ?? 'R',
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
      body: _selectedIndex == 0 ? _buildDashboard() : _buildManageJobs(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: 'My Jobs',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/recruiter/add-job'),
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.postJob),
      ),
    );
  }

  Widget _buildDashboard() {
    final authProvider = Provider.of<AuthProvider>(context);
    final jobProvider = Provider.of<JobProvider>(context);
    final user = authProvider.currentUser;
    final stats = jobProvider.recruiterStats;

    return RefreshIndicator(
      onRefresh: () async => _loadStats(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 4),
            Text(
              user?.name ?? 'Recruiter',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total Jobs',
                    value: '${stats['totalJobs'] ?? 0}',
                    icon: Icons.work_outline,
                    color: AppColors.primary,
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Active Jobs',
                    value: '${stats['activeJobs'] ?? 0}',
                    icon: Icons.trending_up,
                    color: AppColors.success,
                  ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _StatCard(
              title: 'Total Applicants',
              value: '${stats['totalApplicants'] ?? 0}',
              icon: Icons.people_outline,
              color: AppColors.secondary,
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Job Posts',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _selectedIndex = 1),
                  child: const Text('View All'),
                ),
              ],
            ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

            const SizedBox(height: 16),

            StreamBuilder<List<JobModel>>(
              stream: jobProvider.streamRecruiterJobs(user!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text('Error: ${snapshot.error}'),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.work_off_outlined,
                            size: 64,
                            color: AppColors.textLight,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No jobs posted yet',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create your first job posting',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final jobs = snapshot.data!.take(5).toList();

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: jobs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    return _JobCard(
                      job: job,
                      onTap: () {
                        context.push(
                          '/recruiter/applicants/${job.jobId}?title=${Uri.encodeComponent(job.title)}',
                        );
                      },
                      onToggleStatus: () => _handleToggleStatus(job),
                      onDelete: () => _handleDeleteJob(job.jobId),
                    ).animate().fadeIn(
                      delay: Duration(milliseconds: 600 + (index * 100)),
                      duration: 400.ms,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManageJobs() {
    final authProvider = Provider.of<AuthProvider>(context);
    final jobProvider = Provider.of<JobProvider>(context);
    final user = authProvider.currentUser;

    return StreamBuilder<List<JobModel>>(
      stream: jobProvider.streamRecruiterJobs(user!.uid),
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
                  Icons.work_off_outlined,
                  size: 80,
                  color: AppColors.textLight,
                ),
                const SizedBox(height: 16),
                Text(
                  'No jobs found',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Start by posting your first job',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        final jobs = snapshot.data!;

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: jobs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final job = jobs[index];
            return _JobCard(
              job: job,
              showActions: true,
              onTap: () {
                context.push(
                  '/recruiter/applicants/${job.jobId}?title=${Uri.encodeComponent(job.title)}',
                );
              },
              onToggleStatus: () => _handleToggleStatus(job),
              onDelete: () => _handleDeleteJob(job.jobId),
            );
          },
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback onTap;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onDelete;
  final bool showActions;

  const _JobCard({
    required this.job,
    required this.onTap,
    this.onToggleStatus,
    this.onDelete,
    this.showActions = false,
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: job.isActive
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      job.status.toUpperCase(),
                      style: TextStyle(
                        color: job.isActive ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (showActions) ...[
                    const SizedBox(width: 8),
                    PopupMenuButton(
                      icon: const Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          onTap: onToggleStatus,
                          child: Row(
                            children: [
                              Icon(
                                job.isActive ? Icons.pause_circle_outline : Icons.play_circle_outline,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(job.isActive ? 'Deactivate' : 'Activate'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          onTap: onDelete,
                          child: const Row(
                            children: [
                              Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                              SizedBox(width: 12),
                              Text('Delete', style: TextStyle(color: AppColors.error)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
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
                children: [
                  Icon(Icons.people_outline, size: 18, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    '${job.applicantsCount} Applicants',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
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