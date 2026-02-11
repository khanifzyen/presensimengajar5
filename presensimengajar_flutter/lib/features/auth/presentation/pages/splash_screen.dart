import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/di/injection.dart';
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
          if (state.role == 'admin') {
            context.go('/admin-dashboard');
          } else {
            context.go('/teacher-dashboard');
          }
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
