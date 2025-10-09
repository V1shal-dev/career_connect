import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/colors.dart';
import '../../utils/helpers.dart';
import 'package:career_connect/providers/application_provider.dart';
import 'package:career_connect/models/application_model.dart';
import 'package:career_connect/services/cloudinary_service.dart';


class ApplicantsScreen extends StatelessWidget {
  final String jobId;
  final String jobTitle;

  const ApplicantsScreen({
    Key? key,
    required this.jobId,
    required this.jobTitle,
  }) : super(key: key);

  String _fixCloudinaryUrl(String url) {
    // Ensure URL uses /raw/upload for documents
    if (url.contains('res.cloudinary.com') && !url.contains('/raw/upload')) {
      url = url.replaceAll('/image/upload', '/raw/upload');
    }

    // Add fl_attachment to force download/proper viewing
    if (url.contains('/upload/') && !url.contains('fl_attachment')) {
      url = url.replaceAll('/upload/', '/upload/fl_attachment/');
    }

    return url;
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    try {
      if (url.isEmpty) {
        Helpers.showSnackBar(
          context,
          'Resume URL not available',
          isError: true,
        );
        return;
      }

      // Fix Cloudinary URL format
      String fixedUrl = _fixCloudinaryUrl(url.trim());

      print('==========================================');
      print('Original URL: $url');
      print('Fixed URL: $fixedUrl');
      print('==========================================');

      final uri = Uri.parse(fixedUrl);

      // Try to launch URL
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        // Show options dialog as fallback
        _showResumeOptionsDialog(context, fixedUrl);
      }

    } catch (e) {
      print('Error launching URL: $e');

      if (context.mounted) {
        _showResumeOptionsDialog(context, url);
      }
    }
  }

  void _showResumeOptionsDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Open Resume'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose an option:'),
            const SizedBox(height: 8),
            Text(
              url,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              Navigator.pop(context);
              Helpers.showSnackBar(
                context,
                'Resume URL copied! Paste it in your browser.',
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy URL'),
          ),
          TextButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final uri = Uri.parse(url);
                await launchUrl(uri, mode: LaunchMode.platformDefault);
              } catch (e) {
                if (context.mounted) {
                  Helpers.showSnackBar(
                    context,
                    'Please copy the URL and open it in a browser',
                    isError: true,
                  );
                }
              }
            },
            icon: const Icon(Icons.open_in_browser),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final applicationProvider = Provider.of<ApplicationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(jobTitle),
      ),
      body: StreamBuilder<List<ApplicationModel>>(
        stream: applicationProvider.streamJobApplications(jobId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Stream Error: ${snapshot.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading applications',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      snapshot.error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 80,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No applicants yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Applications will appear here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          final applications = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final application = applications[index];

              return _ApplicantCard(
                application: application,
                onViewResume: () => _launchUrl(context, application.resumeUrl),
                onUpdateStatus: (status) async {
                  final success = await applicationProvider.updateApplicationStatus(
                    application.applicationId,
                    status,
                  );
                  if (context.mounted) {
                    Helpers.showSnackBar(
                      context,
                      success ? 'Status updated' : 'Failed to update status',
                      isError: !success,
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  final ApplicationModel application;
  final VoidCallback onViewResume;
  final Function(String) onUpdateStatus;

  const _ApplicantCard({
    required this.application,
    required this.onViewResume,
    required this.onUpdateStatus,
  });

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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Text(
            application.userName.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          application.userName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(application.userEmail),
            const SizedBox(height: 4),
            Text(
              'Applied ${Helpers.timeAgo(application.appliedAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            application.status.toUpperCase(),
            style: TextStyle(
              color: _getStatusColor(),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (application.userPhone != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 18),
                      const SizedBox(width: 8),
                      Text(application.userPhone!),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  'Cover Letter:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(application.coverLetter),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: application.resumeUrl.isNotEmpty
                            ? onViewResume
                            : null,
                        icon: const Icon(Icons.description_outlined),
                        label: const Text('View Resume'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: onUpdateStatus,
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'reviewed',
                          child: Text('Mark as Reviewed'),
                        ),
                        const PopupMenuItem(
                          value: 'accepted',
                          child: Text('Accept'),
                        ),
                        const PopupMenuItem(
                          value: 'rejected',
                          child: Text('Reject'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}