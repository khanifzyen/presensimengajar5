import 'package:go_router/go_router.dart';
import '../presentation/pages/splash_screen.dart';
import '../presentation/pages/onboarding_screen.dart';
import '../presentation/pages/login_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      // Add Dashboard route later
    ],
  );
}
