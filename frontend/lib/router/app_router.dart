import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/activate_screen.dart';
import '../screens/admin/home_screen.dart' show AdminHomeScreen;
import '../screens/admin/people_screen.dart' show PeopleScreen;
import '../screens/admin/academics_screen.dart' show AcademicsScreen;
import '../screens/admin/operations_screen.dart' show OperationsScreen;
import '../screens/admin/more_screen.dart' show MoreScreen;
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
      // Admin routes
      GoRoute(
        path: '/admin/home',
        name: 'admin-home',
        builder: (BuildContext context, GoRouterState state) => const AdminHomeScreen(),
      ),
      GoRoute(
        path: '/admin/people',
        name: 'admin-people',
        builder: (BuildContext context, GoRouterState state) => const PeopleScreen(),
      ),
      GoRoute(
        path: '/admin/academics',
        name: 'admin-academics',
        builder: (BuildContext context, GoRouterState state) => const AcademicsScreen(),
      ),
      GoRoute(
        path: '/admin/operations',
        name: 'admin-operations',
        builder: (BuildContext context, GoRouterState state) => const OperationsScreen(),
      ),
      GoRoute(
        path: '/admin/more',
        name: 'admin-more',
        builder: (BuildContext context, GoRouterState state) => const MoreScreen(),
      ),
      // Professor routes
      GoRoute(
        path: '/professor/home',
        name: 'professor-home',
        builder: (BuildContext context, GoRouterState state) => const ProfessorHomeScreen(),
      ),
      // Student routes
      GoRoute(
        path: '/student/home',
        name: 'student-home',
        builder: (BuildContext context, GoRouterState state) => const StudentHomeScreen(),
      ),
      // Parent routes
      GoRoute(
        path: '/parent/home',
        name: 'parent-home',
        builder: (BuildContext context, GoRouterState state) => const ParentHomeScreen(),
      ),
    ],
  );

  static String _getHomeRoute(AuthProvider authProvider) {
    final user = authProvider.user;
    if (user == null) return '/login';
    
    if (user.isAdmin) return '/admin/home';
    if (user.isTeacher) return '/professor/home';
    if (user.isStudent) return '/student/home';
    if (user.isParent) return '/parent/home';
    
    return '/login';
  }
}

class _RouteRefreshListener extends ChangeNotifier {
  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}
