import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';
import 'package:career_connect/providers/auth_provider.dart';
import 'package:career_connect/providers/job_provider.dart';
import 'package:career_connect/models/job_model.dart';

class AddJobScreen extends StatefulWidget {
  const AddJobScreen({Key? key}) : super(key: key);

  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactEmailController = TextEditingController();

  String _selectedJobType = 'Full-time';
  final List<String> _jobTypes = ['Full-time', 'Part-time', 'Contract', 'Internship', 'Remote'];

  final List<TextEditingController> _requirementControllers = [TextEditingController()];

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null && user.company != null) {
      _companyController.text = user.company!;
    }
    if (user != null) {
      _contactEmailController.text = user.email;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _descriptionController.dispose();
    _contactEmailController.dispose();
    for (var controller in _requirementControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addRequirementField() {
    setState(() {
      _requirementControllers.add(TextEditingController());
    });
  }

  void _removeRequirementField(int index) {
    if (_requirementControllers.length > 1) {
      setState(() {
        _requirementControllers[index].dispose();
        _requirementControllers.removeAt(index);
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) return;

    // Get requirements
    final requirements = _requirementControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    if (requirements.isEmpty) {
      Helpers.showSnackBar(context, 'Please add at least one requirement', isError: true);
      return;
    }

    final job = JobModel(
      jobId: '',
      title: _titleController.text.trim(),
      company: _companyController.text.trim(),
      location: _locationController.text.trim(),
      salary: _salaryController.text.trim(),
      type: _selectedJobType,
      description: _descriptionController.text.trim(),
      requirements: requirements,
      recruiterId: user.uid,
      recruiterName: user.name,
      contactEmail: _contactEmailController.text.trim(),
      createdAt: DateTime.now(),
    );

    Helpers.showLoadingDialog(context);
    final success = await jobProvider.createJob(job);
    if (!mounted) return;
    Helpers.hideLoadingDialog(context);

    if (success) {
      Helpers.showSnackBar(context, AppStrings.jobPosted);
      context.pop();
    } else {
      Helpers.showSnackBar(
        context,
        jobProvider.errorMessage ?? 'Failed to post job',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post New Job'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Job Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: AppStrings.jobTitle,
                  prefixIcon: Icon(Icons.work_outline),
                  hintText: 'e.g. Senior Flutter Developer',
                ),
                validator: (value) => Validators.validateRequired(value, 'Job title'),
              ),
              const SizedBox(height: 16),

              // Company
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: AppStrings.company,
                  prefixIcon: Icon(Icons.business_outlined),
                ),
                validator: (value) => Validators.validateRequired(value, 'Company'),
              ),
              const SizedBox(height: 16),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: AppStrings.location,
                  prefixIcon: Icon(Icons.location_on_outlined),
                  hintText: 'e.g. Remote, New York, USA',
                ),
                validator: (value) => Validators.validateRequired(value, 'Location'),
              ),
              const SizedBox(height: 16),

              // Job Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedJobType,
                decoration: const InputDecoration(
                  labelText: AppStrings.jobType,
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _jobTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedJobType = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Salary
              TextFormField(
                controller: _salaryController,
                decoration: const InputDecoration(
                  labelText: AppStrings.salary,
                  prefixIcon: Icon(Icons.attach_money),
                  hintText: 'e.g. \$80,000 - \$120,000',
                ),
                validator: Validators.validateSalary,
              ),
              const SizedBox(height: 16),

              // Contact Email
              TextFormField(
                controller: _contactEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Contact Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  hintText: 'Email for applicants to contact',
                ),
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: AppStrings.jobDescription,
                  prefixIcon: Icon(Icons.description_outlined),
                  hintText: 'Describe the role, responsibilities, and what you\'re looking for...',
                  alignLabelWithHint: true,
                ),
                validator: (value) => Validators.validateRequired(value, 'Description'),
              ),
              const SizedBox(height: 24),

              // Requirements Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.jobRequirements,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: _addRequirementField,
                    icon: const Icon(Icons.add_circle_outline),
                    color: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Dynamic Requirements Fields
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _requirementControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _requirementControllers[index],
                            decoration: InputDecoration(
                              labelText: 'Requirement ${index + 1}',
                              hintText: 'e.g. 3+ years of Flutter experience',
                              prefixIcon: const Icon(Icons.check_circle_outline),
                            ),
                            validator: (value) {
                              if (index == 0 && (value == null || value.isEmpty)) {
                                return 'At least one requirement is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        if (_requirementControllers.length > 1)
                          IconButton(
                            onPressed: () => _removeRequirementField(index),
                            icon: const Icon(Icons.remove_circle_outline),
                            color: AppColors.error,
                          ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  child: const Text(
                    'Post Job',
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