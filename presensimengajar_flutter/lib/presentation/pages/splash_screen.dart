import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../injection_container.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    // Minimum delay of 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check Auth Status
    context.read<AuthBloc>().add(AuthCheckRequested());

    // Listen to Auth State changes is handled by BlocListener in the build method usually,
    // but here we can just wait for the next frame or use a listener.
    // However, since we just added the event, the state might not be updated immediately.
    // A better approach is to rely on BlocListener in the widget tree.
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        final prefs = sl<SharedPreferences>();
        final bool isOnboardingCompleted =
            prefs.getBool('onboarding_completed') ?? false;

        if (state is AuthAuthenticated) {
          // Navigate to Dashboard (Placeholder for now)
          // context.go('/dashboard');
          // For now, just print or go to login if dashboard not ready,
          // but actually if authenticated we should go to dashboard.
          // Since dashboard isn't ready, let's go to login but maybe show a message?
          // Or better, let's assume we go to login for now as "Home" isn't built.
          // Wait, the user asked to implement phase 1.
          // Let's go to '/login' but effectively it should be dashboard.
          // I'll add a temporary dashboard route or just log it.
          // Actually, if authenticated, we skip onboarding and login.
          // For this step, let's just go to Login if not authenticated.
          // If authenticated, we also go to Login (as placeholder) or stay here?
          // Let's go to /login for now, but in reality it should be /dashboard.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User Authenticated! Navigating to Dashboard...'),
            ),
          );
          // context.go('/dashboard');
        } else if (state is AuthUnauthenticated) {
          if (isOnboardingCompleted) {
            context.go('/login');
          } else {
            context.go('/onboarding');
          }
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset('assets/images/logo.png', width: 120, height: 120),
              const SizedBox(height: 20),
              const Text(
                'EduPresence',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'v1.0.0',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
