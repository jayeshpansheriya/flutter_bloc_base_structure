import 'package:go_router/go_router.dart';
import '../features/home/home_page.dart';
import '../features/auth/auth_login_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) =>
          const HomePage(title: 'Flutter Demo Home Page'),
    ),
    GoRoute(path: '/login', builder: (context, state) => const AuthLoginPage()),
  ],
);
