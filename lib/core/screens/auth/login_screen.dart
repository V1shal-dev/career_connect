import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';

class LoginScreen extends StatefulWidget {
  final String? role;

  const LoginScreen({Key? key, this.role}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      // Navigate based on role
      if (authProvider.isRecruiter) {
        context.go('/recruiter');
      } else {
        context.go('/jobseeker');
      }
    } else {
      Helpers.showSnackBar(
        context,
        authProvider.errorMessage ?? 'Login failed',
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
                const SizedBox(height: 40),

                // Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.go('/role-selection'),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: 20),

                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: isRecruiter
                        ? AppColors.primaryGradient
                        : AppColors.secondaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    isRecruiter
                        ? Icons.business_center_rounded
                        : Icons.person_search_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ).animate().scale(delay: 200.ms, duration: 600.ms),

                const SizedBox(height: 24),

                // Title
                Text(
                  'Welcome Back!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

                const SizedBox(height: 8),

                Text(
                  'Login as ${isRecruiter ? "Recruiter" : "Job Seeker"}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 600.ms),

                const SizedBox(height: 40),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: AppStrings.email,
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: Validators.validateEmail,
                ).animate().fadeIn(delay: 500.ms, duration: 600.ms),

                const SizedBox(height: 20),

                // Password Field
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
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: Validators.validatePassword,
                ).animate().fadeIn(delay: 600.ms, duration: 600.ms),

                const SizedBox(height: 30),

                // Login Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRecruiter
                          ? AppColors.primary
                          : AppColors.secondary,
                    ),
                    child: authProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      AppStrings.login,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ).animate().fadeIn(delay: 700.ms, duration: 600.ms),

                const SizedBox(height: 20),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.dontHaveAccount,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        context.go('/signup?role=${widget.role}');
                      },
                      child: Text(
                        AppStrings.signup,
                        style: TextStyle(
                          color: isRecruiter
                              ? AppColors.primary
                              : AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 800.ms, duration: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}