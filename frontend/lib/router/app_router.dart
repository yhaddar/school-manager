import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/activate_screen.dart';
import '../screens/admin/home_screen.dart' show AdminHomeScreen;
import '../screens/professor/home_screen.dart' show ProfessorHomeScreen;
import '../screens/student/home_screen.dart' show StudentHomeScreen;
import '../screens/parent/home_screen.dart' show ParentHomeScreen;

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
      
      // If authenticated, redirect from login/activation to appropriate home
      if (isLoggedIn && (location == '/login' || location == '/activate')) {
        return _getHomeRoute(authProvider);
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
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          return _buildHomeScreen(authProvider);
        },
      ),
    ],
  );

  static String _getHomeRoute(AuthProvider authProvider) {
    final user = authProvider.user;
    if (user == null) return '/login';
    
    if (user.isAdmin) return '/home';
    if (user.isTeacher) return '/home';
    if (user.isStudent) return '/home';
    if (user.isParent) return '/home';
    
    return '/login';
  }

  static Widget _buildHomeScreen(AuthProvider authProvider) {
    final user = authProvider.user;
    if (user == null) return const LoginScreen();
    
    // Return appropriate home screen based on user role
    if (user.isAdmin) {
      return const AdminHomeScreen();
    } else if (user.isTeacher) {
      return const ProfessorHomeScreen();
    } else if (user.isStudent) {
      return const StudentHomeScreen();
    } else if (user.isParent) {
      return const ParentHomeScreen();
    }
    
    return const LoginScreen();
  }
}

class _RouteRefreshListener extends ChangeNotifier {
  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}
