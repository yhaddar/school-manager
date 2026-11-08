import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_manager/screens/auth/login_screen.dart';
import 'package:school_manager/main.dart';
import 'package:school_manager/providers/auth_provider.dart';
import 'package:school_manager/services/auth_service.dart';
import 'package:school_manager/services/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    late SharedPreferences sharedPreferences;

    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      sharedPreferences = await SharedPreferences.getInstance();
    });

    testWidgets('renders email and password fields', (WidgetTester tester) async {
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

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('displays logo and title', (WidgetTester tester) async {
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

      // Logo is an Icon with Iconsax.book
      expect(find.byType(Icon), findsWidgets);
      expect(find.text('School Manager'), findsOneWidget);
    });

    testWidgets('has login button', (WidgetTester tester) async {
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

    testWidgets('login button is enabled when form fields are empty', (WidgetTester tester) async {
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

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('validates empty email shows error', (WidgetTester tester) async {
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

      // Tap login button without entering email
      await tester.tap(find.text('Login'));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('validates invalid email shows error', (WidgetTester tester) async {
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

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.tap(find.text('Login'));
      await tester.pump();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('validates empty password shows error', (WidgetTester tester) async {
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

      // Enter email but leave password empty
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.tap(find.text('Login'));
      await tester.pump();

      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('uses correct theme colors', (WidgetTester tester) async {
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

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(AppTheme.canvas));
    });
  });
}
