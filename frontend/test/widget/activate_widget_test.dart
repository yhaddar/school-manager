import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_manager/screens/auth/activate_screen.dart';
import 'package:school_manager/main.dart';
import 'package:school_manager/providers/auth_provider.dart';
import 'package:school_manager/services/auth_service.dart';
import 'package:school_manager/services/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ActivateScreen Widget Tests', () {
    late SharedPreferences sharedPreferences;

    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      sharedPreferences = await SharedPreferences.getInstance();
    });

    Widget buildTestApp() {
      return MultiProvider(
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
          home: const ActivateScreen(),
        ),
      );
    }

    testWidgets('renders all input fields', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());

      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(find.text('Username'), findsWidgets);
      expect(find.text('Temporary Password'), findsWidgets);
      expect(find.text('New Password'), findsWidgets);
      expect(find.text('Confirm Password'), findsWidgets);
    });

    testWidgets('displays activate button', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());

      expect(find.text('Activate your account'), findsOneWidget);
      expect(find.text('Activate'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('validates empty username shows error', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());

      await tester.tap(find.text('Activate'));
      await tester.pump();

      expect(find.text('Please enter your username'), findsOneWidget);
    });

    testWidgets('validates short password shows error', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());

      // Find all TextFormFields and enter text in them
      final textFields = find.byType(TextFormField);
      
      // First field: Username
      await tester.enterText(textFields.at(0), 'testuser');
      
      // Second field: Temporary Password
      await tester.enterText(textFields.at(1), 'temppass12345');
      
      // Third field: New Password (too short)
      await tester.enterText(textFields.at(2), 'short');
      
      await tester.tap(find.text('Activate'));
      await tester.pump();

      expect(find.text('Password must be at least 12 characters'), findsOneWidget);
    });

    testWidgets('validates password confirmation mismatch', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());

      final textFields = find.byType(TextFormField);
      
      // First field: Username
      await tester.enterText(textFields.at(0), 'testuser');
      
      // Second field: Temporary Password
      await tester.enterText(textFields.at(1), 'temppass12345');
      
      // Third field: New Password
      await tester.enterText(textFields.at(2), 'newpassword12345');
      
      // Fourth field: Confirm Password (different)
      await tester.enterText(textFields.at(3), 'differentpassword1');
      
      await tester.tap(find.text('Activate'));
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('uses correct theme colors', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(AppTheme.canvas));
    });
  });
}
