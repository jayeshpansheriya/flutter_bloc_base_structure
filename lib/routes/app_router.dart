import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:contribution/features/home/home_page.dart';
import 'package:contribution/features/auth/auth_login_page.dart';

/// App route names for type-safe navigation
class AppRoutes {
  // Auth routes
  static const String login = '/login';
  static const String register = '/register';

  // Main routes
  static const String home = '/';
  static const String profile = '/profile';
  static const String settings = '/settings';
}

/// Global GoRouter configuration
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  debugLogDiagnostics: true,

  // Error handling
  errorBuilder: (context, state) => ErrorPage(error: state.error.toString()),

  // Routes
  routes: [
    // ==================== Auth Routes ====================
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const AuthLoginPage(),
    ),

    // Uncomment when register page is created
    // GoRoute(
    //   path: AppRoutes.register,
    //   name: 'register',
    //   builder: (context, state) => const AuthRegisterPage(),
    // ),

    // ==================== Main Routes ====================
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const HomePage(title: 'Home'),
    ),

    // Uncomment when profile page is created
    // GoRoute(
    //   path: AppRoutes.profile,
    //   name: 'profile',
    //   builder: (context, state) => const ProfilePage(),
    // ),

    // Uncomment when settings page is created
    // GoRoute(
    //   path: AppRoutes.settings,
    //   name: 'settings',
    //   builder: (context, state) => const SettingsPage(),
    // ),
  ],

  // Redirect logic (e.g., for authentication)
  // redirect: (context, state) {
  //   final isAuthenticated = sl<DioClient>().isAuthenticated();
  //   final isLoginRoute = state.matchedLocation == AppRoutes.login;
  //
  //   // Redirect to login if not authenticated
  //   if (!isAuthenticated && !isLoginRoute) {
  //     return AppRoutes.login;
  //   }
  //
  //   // Redirect to home if already authenticated and trying to access login
  //   if (isAuthenticated && isLoginRoute) {
  //     return AppRoutes.home;
  //   }
  //
  //   return null; // No redirect
  // },
);

/// Error page widget
class ErrorPage extends StatelessWidget {
  final String error;

  const ErrorPage({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
