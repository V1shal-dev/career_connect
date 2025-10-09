import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:career_connect/providers/auth_provider.dart';

class ManageJobsScreen extends StatelessWidget {
  const ManageJobsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Jobs'),
      ),
      body: user == null
          ? const Center(child: Text('Please login'))
          : const SizedBox(), // Placeholder - main logic is in recruiter_home.dart
    );
  }
}