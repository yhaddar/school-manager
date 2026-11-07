import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/activate_screen.dart';
import '../screens/admin/home_screen.dart' show AdminHomeScreen;

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable: _RouteRefreshListener(),
    redirect: (BuildContext context, GoRouterState state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isLoggedIn = authProvider.isAuthenticated;
      final location = state.uri.path;

      // If accessing protected routes while not authenticated
      if (!isLoggedIn && location != '/login' && location != '/activate') {
        return '/login';
      }
      
      // If authenticated, redirect from login to home
      if (isLoggedIn && (location == '/login' || location == '/activate')) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (BuildContext context, GoRouterState state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/activate',
        name: 'activate',
        builder: (BuildContext context, GoRouterState state) => const ActivateScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (BuildContext context, GoRouterState state) {
          // TODO: Determine user role and show appropriate home screen
          // This is a placeholder - actual implementation will check user role
          return const AdminHomeScreen();
        },
      ),
    ],
  );
}

class _RouteRefreshListener extends ChangeNotifier {
  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}
