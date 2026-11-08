import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:school_manager/screens/admin/home_screen.dart';
import 'package:school_manager/main.dart';

void main() {
  group('AdminHomeScreen Widget Tests', () {
    testWidgets('renders app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const AdminHomeScreen(),
        ),
      );

      expect(find.text('School Manager'), findsOneWidget);
    });

    testWidgets('renders tab bar with correct labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const AdminHomeScreen(),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('People'), findsOneWidget);
      expect(find.text('Academics'), findsOneWidget);
      expect(find.text('Operations'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('displays welcome message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const AdminHomeScreen(),
        ),
      );

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Manage your institution'), findsOneWidget);
    });

    testWidgets('displays stat cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const AdminHomeScreen(),
        ),
      );

      expect(find.text('Students'), findsOneWidget);
      expect(find.text('Teachers'), findsOneWidget);
      expect(find.text('Classes'), findsOneWidget);
      expect(find.text('Parent Links'), findsOneWidget);
    });

    testWidgets('displays recent activity section', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const AdminHomeScreen(),
        ),
      );

      expect(find.text('Recent Activity'), findsOneWidget);
    });

    testWidgets('displays stat values', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const AdminHomeScreen(),
        ),
      );

      expect(find.text('1,248'), findsOneWidget);
      expect(find.text('84'), findsOneWidget);
      expect(find.text('32'), findsOneWidget);
      expect(find.text('1,182'), findsOneWidget);
    });

    testWidgets('uses correct theme colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const AdminHomeScreen(),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(AppTheme.canvas));
    });
  });
}
