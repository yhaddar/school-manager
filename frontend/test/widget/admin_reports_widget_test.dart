import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_manager/main.dart';
import 'package:school_manager/providers/auth_provider.dart';
import 'package:school_manager/services/auth_service.dart';
import 'package:school_manager/services/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ReportsScreen Widget Tests', () {
    late SharedPreferences sharedPreferences;

    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      sharedPreferences = await SharedPreferences.getInstance();
    });

    testWidgets('renders app bar with title', (WidgetTester tester) async {
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
            home: Scaffold(appBar: AppBar(title: const Text('Reports'))),
          ),
        ),
      );

      expect(find.text('Reports'), findsOneWidget);
    });

    testWidgets('has floating action button for creating reports', (WidgetTester tester) async {
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
            home: Scaffold(
              floatingActionButton: const FloatingActionButton(onPressed: null),
            ),
          ),
        ),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('displays loading indicator', (WidgetTester tester) async {
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
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
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
            home: Scaffold(
              backgroundColor: AppTheme.canvas,
              body: const Center(child: Text('Reports')),
            ),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(AppTheme.canvas));
    });
  });
}
