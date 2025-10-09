import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';
import 'package:career_connect/providers/auth_provider.dart';
import 'package:career_connect/providers/application_provider.dart';
import 'package:career_connect/models/job_model.dart';
import 'package:career_connect/models/application_model.dart';

class ApplyScreen extends StatefulWidget {
  final JobModel job;

  const ApplyScreen({Key? key, required this.job}) : super(key: key);

  @override
  State<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends State<ApplyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _coverLetterController = TextEditingController();

  File? _selectedFile;
  String? _fileName;
  String? _uploadedResumeUrl;

  @override
  void dispose() {
    _coverLetterController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _fileName = result.files.single.name;
        });
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(context, 'Error picking file: $e', isError: true);
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFile == null) {
      Helpers.showSnackBar(context, 'Please upload your resume', isError: true);
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final applicationProvider = Provider.of<ApplicationProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) return;

    // Show loading
    Helpers.showLoadingDialog(context);

    try {
      // Upload resume to Cloudinary
      final resumeUrl = await applicationProvider.uploadResume(_selectedFile!);

      if (resumeUrl == null) {
        if (mounted) {
          Helpers.hideLoadingDialog(context);
          Helpers.showSnackBar(
            context,
            applicationProvider.errorMessage ?? 'Failed to upload resume',
            isError: true,
          );
        }
        return;
      }

      // Create application
      final application = ApplicationModel(
        applicationId: '',
        jobId: widget.job.jobId,
        jobTitle: widget.job.title,
        company: widget.job.company,
        userId: user.uid,
        userName: user.name,
        userEmail: user.email,
        userPhone: user.phone,
        resumeUrl: resumeUrl,
        coverLetter: _coverLetterController.text.trim(),
        appliedAt: DateTime.now(),
      );

      final success = await applicationProvider.submitApplication(application);

      if (!mounted) return;
      Helpers.hideLoadingDialog(context);

      if (success) {
        Helpers.showSnackBar(context, AppStrings.applicationSubmitted);
        context.pop();
        context.pop(); // Go back to job list
      } else {
        Helpers.showSnackBar(
          context,
          applicationProvider.errorMessage ?? 'Failed to submit application',
          isError: true,
        );
      }
    } catch (e) {
      if (mounted) {
        Helpers.hideLoadingDialog(context);
        Helpers.showSnackBar(context, 'Error: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final applicationProvider = Provider.of<ApplicationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply for Job'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Job Info Card
              Card(
                color: AppColors.secondary.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.job.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.job.company,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(widget.job.location),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Resume Upload Section
              Text(
                'Upload Resume *',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              InkWell(
                onTap: applicationProvider.isUploading ? null : _pickFile,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _selectedFile != null
                          ? AppColors.success
                          : AppColors.greyLight,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: _selectedFile != null
                        ? AppColors.success.withOpacity(0.05)
                        : Colors.white,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _selectedFile != null
                            ? Icons.check_circle
                            : Icons.cloud_upload_outlined,
                        size: 48,
                        color: _selectedFile != null
                            ? AppColors.success
                            : AppColors.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _selectedFile != null
                            ? _fileName!
                            : 'Tap to upload your resume',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'PDF, DOC, DOCX (Max 5MB)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (applicationProvider.isUploading) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: applicationProvider.uploadProgress,
                  backgroundColor: AppColors.greyLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ],

              const SizedBox(height: 24),

              // Cover Letter
              Text(
                'Cover Letter *',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _coverLetterController,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: 'Tell us why you\'re a great fit for this role...',
                  alignLabelWithHint: true,
                ),
                validator: (value) => Validators.validateRequired(value, 'Cover letter'),
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: applicationProvider.isLoading || applicationProvider.isUploading
                      ? null
                      : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                  ),
                  child: applicationProvider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Submit Application',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}