import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_manager/screens/auth/login_screen.dart';
import 'package:school_manager/screens/auth/activate_screen.dart';
import 'package:school_manager/screens/super_admin/home_screen.dart';
import 'package:school_manager/providers/auth_provider.dart';
import 'package:school_manager/services/auth_service.dart';
import 'package:school_manager/services/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LoginScreen Accessibility Tests', () {
    late SharedPreferences sharedPreferences;

    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      sharedPreferences = await SharedPreferences.getInstance();
    });

    testWidgets('email TextFormField displays label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => AuthProvider(
                authService: AuthService(
                  apiClient: ApiClient(),
                  sharedPreferences: sharedPreferences,
                ),
              ),
            ),
          ],
          child: MaterialApp(
            theme: ThemeData.light(),
            home: const LoginScreen(),
          ),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
      expect(find.byType(TextFormField).first, findsOneWidget);
    });

    testWidgets('password TextFormField displays label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => AuthProvider(
                authService: AuthService(
                  apiClient: ApiClient(),
                  sharedPreferences: sharedPreferences,
                ),
              ),
            ),
          ],
          child: MaterialApp(
            theme: ThemeData.light(),
            home: const LoginScreen(),
          ),
        ),
      );

      expect(find.text('Password'), findsOneWidget);
      expect(find.byType(TextFormField).last, findsOneWidget);
    });

    testWidgets('login button displays correct text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => AuthProvider(
                authService: AuthService(
                  apiClient: ApiClient(),
                  sharedPreferences: sharedPreferences,
                ),
              ),
            ),
          ],
          child: MaterialApp(
            theme: ThemeData.light(),
            home: const LoginScreen(),
          ),
        ),
      );

      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('screen title is visible', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => AuthProvider(
                authService: AuthService(
                  apiClient: ApiClient(),
                  sharedPreferences: sharedPreferences,
                ),
              ),
            ),
          ],
          child: MaterialApp(
            theme: ThemeData.light(),
            home: const LoginScreen(),
          ),
        ),
      );

      expect(find.text('School Manager'), findsOneWidget);
    });

    testWidgets('logo icon is visible', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => AuthProvider(
                authService: AuthService(
                  apiClient: ApiClient(),
                  sharedPreferences: sharedPreferences,
                ),
              ),
            ),
          ],
          child: MaterialApp(
            theme: ThemeData.light(),
            home: const LoginScreen(),
          ),
        ),
      );

      expect(find.byType(Icon), findsWidgets);
    });
  });

  group('SuperAdminHomeScreen Accessibility Tests', () {
    testWidgets('tab bar has correct labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SuperAdminHomeScreen(),
        ),
      );

      expect(find.text('Institutions'), findsOneWidget);
      expect(find.text('Analytics'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('bottom navigation displays correct labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SuperAdminHomeScreen(),
        ),
      );

      final institutionsTab = find.text('Institutions');
      expect(institutionsTab, findsOneWidget);
    });

    testWidgets('app bar displays correct title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SuperAdminHomeScreen(),
        ),
      );

      expect(find.text('Super Admin'), findsOneWidget);
    });
  });

  group('ActivateScreen Accessibility Tests', () {
    testWidgets('screen title is visible', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: AuthService(
              apiClient: ApiClient(),
              sharedPreferences: prefs,
            ),
          ),
          child: const MaterialApp(
            home: ActivateScreen(),
          ),
        ),
      );

      expect(find.text('Activate your account'), findsOneWidget);
    });

    testWidgets('activate button is visible', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: AuthService(
              apiClient: ApiClient(),
              sharedPreferences: prefs,
            ),
          ),
          child: const MaterialApp(
            home: ActivateScreen(),
          ),
        ),
      );

      expect(find.text('Activate'), findsOneWidget);
    });

    testWidgets('all form fields are visible', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: AuthService(
              apiClient: ApiClient(),
              sharedPreferences: prefs,
            ),
          ),
          child: const MaterialApp(
            home: ActivateScreen(),
          ),
        ),
      );

      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Temporary Password'), findsOneWidget);
      expect(find.text('New Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
    });
  });
}
