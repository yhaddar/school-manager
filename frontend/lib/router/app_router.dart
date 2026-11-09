import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/activate_screen.dart';
import '../screens/admin/home_screen.dart';
import '../screens/admin/people_screen.dart';
import '../screens/admin/academics_screen.dart';
import '../screens/admin/operations_screen.dart';
import '../screens/admin/more_screen.dart';
import '../screens/admin/reports_screen.dart' as admin_reports;
import '../screens/admin/exports_screen.dart' as admin_exports;
import '../screens/admin/imports_screen.dart' as admin_imports;
import '../screens/professor/home_screen.dart' as professor;
import '../screens/professor/more_screen.dart' as professor_more;
import '../screens/professor/classes_screen.dart' as professor_classes;
import '../screens/professor/assessments_screen.dart' as professor_assessments;
import '../screens/professor/messages_screen.dart' as professor_messages;
import '../screens/student/home_screen.dart' as student;
import '../screens/student/more_screen.dart' as student_more;
import '../screens/student/learning_screen.dart' as student_learning;
import '../screens/student/tasks_screen.dart' as student_tasks;
import '../screens/student/results_screen.dart' as student_results;
import '../screens/parent/home_screen.dart' as parent;
import '../screens/parent/more_screen.dart' as parent_more;
import '../screens/super_admin/home_screen.dart' as super_admin;
import '../screens/super_admin/institutions_screen.dart';
import '../screens/super_admin/institution_detail_screen.dart' as institution_detail;
import '../screens/super_admin/edit_institution_screen.dart' as edit_institution;
import '../screens/super_admin/create_institution_screen.dart' as create_institution;
import '../screens/super_admin/plan_detail_screen.dart' as plan_detail;
import '../screens/super_admin/create_plan_screen.dart' as create_plan;
import '../screens/super_admin/create_support_screen.dart' as create_support;
import '../screens/super_admin/support_request_detail_screen.dart' as support_request_detail;
import '../screens/super_admin/settings_screen.dart' as super_admin_settings;
import '../screens/search/search_screen.dart' as search;
import '../screens/communication/notifications_screen.dart' as comm_notifications;
import '../screens/communication/messages_screen.dart' as comm_messages;
import '../screens/communication/calendar_events_screen.dart' as comm_calendar;
import '../providers/auth_provider.dart';

class AppRouter {
  static List<GetPage> pages = [
    GetPage(
      name: '/login',
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: '/activate',
      page: () => const ActivateScreen(),
    ),
    GetPage(
      name: '/',
      page: () => const LoginScreen(),
    ),
    // Global search route
    GetPage(
      name: '/search',
      page: () => const search.SearchScreen(),
    ),
    // Super Admin routes
    GetPage(
      name: '/super-admin/home',
      page: () => const super_admin.SuperAdminHomeScreen(),
    ),
    GetPage(
      name: '/super-admin/institutions',
      page: () => const InstitutionsScreen(),
    ),
    GetPage(
      name: '/super-admin/create-institution',
      page: () => const create_institution.CreateInstitutionScreen(),
    ),
    GetPage(
      name: '/super-admin/institutions/:id',
      page: () => const institution_detail.InstitutionDetailScreen(),
    ),
    GetPage(
      name: '/super-admin/edit-institution/:id',
      page: () => const edit_institution.EditInstitutionScreen(),
    ),
    GetPage(
      name: '/super-admin/create-plan',
      page: () => const create_plan.CreatePlanScreen(),
    ),
    GetPage(
      name: '/super-admin/subscriptions/:id',
      page: () => const plan_detail.PlanDetailScreen(),
    ),
    GetPage(
      name: '/super-admin/support/requests',
      page: () => const create_support.CreateSupportScreen(),
    ),
    GetPage(
      name: '/super-admin/support/requests/:id',
      page: () => const support_request_detail.SupportRequestDetailScreen(),
    ),
    GetPage(
      name: '/super-admin/settings',
      page: () => const super_admin_settings.SettingsScreen(),
    ),
    // Admin routes
    GetPage(
      name: '/admin/home',
      page: () => const AdminHomeScreen(),
    ),
    GetPage(
      name: '/admin/people',
      page: () => const PeopleScreen(),
    ),
    GetPage(
      name: '/admin/academics',
      page: () => const AcademicsScreen(),
    ),
    GetPage(
      name: '/admin/operations',
      page: () => const OperationsScreen(),
    ),
    GetPage(
      name: '/admin/reports',
      page: () => const admin_reports.ReportsScreen(),
    ),
    GetPage(
      name: '/admin/exports',
      page: () => const admin_exports.ExportsScreen(),
    ),
    GetPage(
      name: '/admin/imports',
      page: () => const admin_imports.ImportsScreen(),
    ),
    GetPage(
      name: '/admin/more',
      page: () => const MoreScreen(),
    ),
    // Professor routes
    GetPage(
      name: '/professor/home',
      page: () => const professor.ProfessorHomeScreen(),
    ),
    GetPage(
      name: '/professor/classes',
      page: () => const professor_classes.ProfessorClassesScreen(),
    ),
    GetPage(
      name: '/professor/assessments',
      page: () => const professor_assessments.ProfessorAssessmentsScreen(),
    ),
    GetPage(
      name: '/professor/messages',
      page: () => const professor_messages.ProfessorMessagesScreen(),
    ),
    GetPage(
      name: '/professor/notifications',
      page: () => const comm_notifications.NotificationsScreen(),
    ),
    GetPage(
      name: '/professor/profile',
      page: () => const professor_more.ProfessorMoreScreen(),
    ),
    GetPage(
      name: '/professor/more',
      page: () => const professor_more.ProfessorMoreScreen(),
    ),
    // Student routes
    GetPage(
      name: '/student/home',
      page: () => const student.StudentHomeScreen(),
    ),
    GetPage(
      name: '/student/learning',
      page: () => const student_learning.LearningScreen(),
    ),
    GetPage(
      name: '/student/tasks',
      page: () => const student_tasks.TasksScreen(),
    ),
    GetPage(
      name: '/student/results',
      page: () => const student_results.ResultsScreen(),
    ),
    GetPage(
      name: '/student/more',
      page: () => const student_more.MoreScreen(),
    ),
    // Parent routes
    GetPage(
      name: '/parent/home',
      page: () => const parent.ParentHomeScreen(),
    ),
    GetPage(
      name: '/parent/more',
      page: () => const parent_more.ParentMoreScreen(),
    ),
    // Communication routes (shared)
    GetPage(
      name: '/communications/notifications',
      page: () => const comm_notifications.NotificationsScreen(),
    ),
    GetPage(
      name: '/communications/messages',
      page: () => const comm_messages.MessagesScreen(),
    ),
    GetPage(
      name: '/communications/calendar-events',
      page: () => const comm_calendar.CalendarEventsScreen(),
    ),
    GetPage(
      name: '/communications/events',
      page: () => const _EventsScreenPlaceholder(),
    ),
  ];

  static String getInitialRoute(AuthProvider authProvider) {
    if (authProvider.isAuthenticated) {
      return _getHomeRoute(authProvider);
    }
    return '/login';
  }

  static String _getHomeRoute(AuthProvider authProvider) {
    final user = authProvider.user;
    if (user == null) return '/login';
    
    if (user.isSuperAdmin) return '/super-admin/home';
    if (user.isAdmin) return '/admin/home';
    if (user.isTeacher) return '/professor/home';
    if (user.isStudent) return '/student/home';
    if (user.isParent) return '/parent/home';
    
    return '/login';
  }

  static Future<String?> middlewareRedirect(String? currentRoute, AuthProvider authProvider) async {
    final isLoggedIn = authProvider.isAuthenticated;
    
    if (!isLoggedIn && currentRoute != '/login' && currentRoute != '/activate') {
      return '/login';
    }
    
    if (isLoggedIn && (currentRoute == '/login' || currentRoute == '/activate')) {
      return _getHomeRoute(authProvider);
    }
    
    return null;
  }
}

class _EventsScreenPlaceholder extends StatelessWidget {
  const _EventsScreenPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Events Screen - Coming Soon'),
      ),
    );
  }
}
