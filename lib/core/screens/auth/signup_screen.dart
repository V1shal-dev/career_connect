import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';
import 'package:career_connect/providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  final String? role;

  const SignupScreen({Key? key, this.role}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isRecruiter = widget.role == 'recruiter';

    final success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      role: widget.role ?? 'jobseeker',
      phone: _phoneController.text.trim(),
      company: isRecruiter ? _companyController.text.trim() : null,
    );

    if (!mounted) return;

    if (success) {
      Helpers.showSnackBar(context, 'Account created successfully!');
      // Navigate based on role
      if (authProvider.isRecruiter) {
        context.go('/recruiter');
      } else {
        context.go('/jobseeker');
      }
    } else {
      Helpers.showSnackBar(
        context,
        authProvider.errorMessage ?? 'Signup failed',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isRecruiter = widget.role == 'recruiter';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.go('/login?role=${widget.role}'),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: 10),

                // Icon
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: isRecruiter
                        ? AppColors.primaryGradient
                        : AppColors.secondaryGradient,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    isRecruiter
                        ? Icons.business_center_rounded
                        : Icons.person_search_rounded,
                    size: 35,
                    color: Colors.white,
                  ),
                ).animate().scale(delay: 200.ms, duration: 600.ms),

                const SizedBox(height: 20),

                // Title
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

                const SizedBox(height: 8),

                Text(
                  'Sign up as ${isRecruiter ? "Recruiter" : "Job Seeker"}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 600.ms),

                const SizedBox(height: 30),

                // Full Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.fullName,
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: Validators.validateName,
                ).animate().fadeIn(delay: 500.ms, duration: 600.ms),

                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: AppStrings.email,
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: Validators.validateEmail,
                ).animate().fadeIn(delay: 550.ms, duration: 600.ms),

                const SizedBox(height: 16),

                // Phone
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: AppStrings.phoneNumber,
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: Validators.validatePhone,
                ).animate().fadeIn(delay: 600.ms, duration: 600.ms),

                const SizedBox(height: 16),

                // Company (only for recruiters)
                if (isRecruiter)
                  TextFormField(
                    controller: _companyController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.companyName,
                      prefixIcon: Icon(Icons.business_outlined),
                    ),
                    validator: (value) => Validators.validateRequired(value, 'Company name'),
                  ).animate().fadeIn(delay: 650.ms, duration: 600.ms),

                if (isRecruiter) const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: AppStrings.password,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: Validators.validatePassword,
                ).animate().fadeIn(delay: 700.ms, duration: 600.ms),

                const SizedBox(height: 16),

                // Confirm Password
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: AppStrings.confirmPassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                      },
                    ),
                  ),
                  validator: (value) => Validators.validateConfirmPassword(
                    value,
                    _passwordController.text,
                  ),
                ).animate().fadeIn(delay: 750.ms, duration: 600.ms),

                const SizedBox(height: 30),

                // Signup Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _handleSignup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRecruiter
                          ? AppColors.primary
                          : AppColors.secondary,
                    ),
                    child: authProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      AppStrings.signup,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ).animate().fadeIn(delay: 800.ms, duration: 600.ms),

                const SizedBox(height: 16),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.alreadyHaveAccount,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        context.go('/login?role=${widget.role}');
                      },
                      child: Text(
                        AppStrings.login,
                        style: TextStyle(
                          color: isRecruiter
                              ? AppColors.primary
                              : AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 850.ms, duration: 600.ms),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}