import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_manager/screens/student/home_screen.dart';
import 'package:school_manager/main.dart';
import 'package:school_manager/providers/auth_provider.dart';
import 'package:school_manager/services/auth_service.dart';
import 'package:school_manager/services/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('StudentHomeScreen Widget Tests', () {
    late SharedPreferences sharedPreferences;

    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      sharedPreferences = await SharedPreferences.getInstance();
    });

    Widget buildApp() {
      return MaterialApp(
        theme: ThemeData.light(),
        home: const StudentHomeScreen(),
      );
    }

    testWidgets('renders tab bar with correct labels', (WidgetTester tester) async {
      await tester.pumpWidget(buildApp());

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Learning'), findsOneWidget);
      expect(find.text('Tasks'), findsOneWidget);
      expect(find.text('Results'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('displays welcome message on Today tab', (WidgetTester tester) async {
      await tester.pumpWidget(buildApp());

      expect(find.text('Good morning, Alex'), findsOneWidget);
      expect(find.text("Today's Schedule"), findsOneWidget);
    });

    testWidgets('displays learning courses', (WidgetTester tester) async {
      await tester.pumpWidget(buildApp());

      await tester.tap(find.text('Learning'));
      await tester.pump();

      expect(find.text('My Courses'), findsOneWidget);
    });

    testWidgets('displays tasks list', (WidgetTester tester) async {
      await tester.pumpWidget(buildApp());

      await tester.tap(find.text('Tasks'));
      await tester.pump();

      expect(find.text('My Tasks'), findsOneWidget);
    });

    testWidgets('displays results grades', (WidgetTester tester) async {
      await tester.pumpWidget(buildApp());

      await tester.tap(find.text('Results'));
      await tester.pump();

      expect(find.text('My Grades'), findsOneWidget);
    });

    testWidgets('displays more settings', (WidgetTester tester) async {
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
          child: buildApp(),
        ),
      );

      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('School Calendar'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('uses correct theme colors for text', (WidgetTester tester) async {
      await tester.pumpWidget(buildApp());

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(AppTheme.canvas));
    });
  });
}
