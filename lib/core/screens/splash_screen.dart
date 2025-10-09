import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Initialize auth
    await authProvider.initializeAuth();

    // Wait for animation
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Navigate based on auth state
    if (authProvider.isAuthenticated) {
      if (authProvider.isRecruiter) {
        context.go('/recruiter');
      } else {
        context.go('/jobseeker');
      }
    } else {
      context.go('/role-selection');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.work_rounded,
                  size: 60,
                  color: AppColors.primary,
                ),
              )
                  .animate()
                  .scale(delay: 200.ms, duration: 600.ms)
                  .fadeIn(duration: 600.ms),

              const SizedBox(height: 30),

              // App Name
              Text(
                AppStrings.appName,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              )
                  .animate()
                  .slideY(
                begin: 0.5,
                delay: 400.ms,
                duration: 600.ms,
              )
                  .fadeIn(duration: 600.ms),

              const SizedBox(height: 10),

              // Tagline
              Text(
                AppStrings.appTagline,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 0.5,
                ),
              )
                  .animate()
                  .slideY(
                begin: 0.5,
                delay: 600.ms,
                duration: 600.ms,
              )
                  .fadeIn(duration: 600.ms),

              const SizedBox(height: 50),

              // Loading Indicator
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.8),
                  ),
                  strokeWidth: 3,
                ),
              )
                  .animate(
                onPlay: (controller) => controller.repeat(),
              )
                  .fadeIn(delay: 800.ms, duration: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}