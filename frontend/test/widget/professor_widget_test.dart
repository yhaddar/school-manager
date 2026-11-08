import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:school_manager/screens/professor/home_screen.dart';
import 'package:school_manager/main.dart';

void main() {
  group('ProfessorHomeScreen Widget Tests', () {
    testWidgets('renders app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const ProfessorHomeScreen(),
        ),
      );

      expect(find.text('School Manager'), findsOneWidget);
    });

    testWidgets('renders tab bar with correct labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const ProfessorHomeScreen(),
        ),
      );

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Classes'), findsOneWidget);
      expect(find.text('Assessments'), findsOneWidget);
      expect(find.text('Messages'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('displays welcome message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const ProfessorHomeScreen(),
        ),
      );

      expect(find.text('Good morning, Professor'), findsOneWidget);
    });

    testWidgets('displays today schedule', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const ProfessorHomeScreen(),
        ),
      );

      expect(find.text('Your schedule for today:'), findsOneWidget);
    });

    testWidgets('uses correct theme colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const ProfessorHomeScreen(),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(AppTheme.canvas));
    });
  });
}
