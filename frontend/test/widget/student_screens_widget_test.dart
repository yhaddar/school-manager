import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:school_manager/screens/student/learning_screen.dart';
import 'package:school_manager/screens/student/tasks_screen.dart';
import 'package:school_manager/screens/student/results_screen.dart';
import 'package:school_manager/main.dart';

void main() {
  group('Student Screens Widget Tests', () {
    testWidgets('LearningScreen displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const LearningScreen(),
        ),
      );

      await tester.pump(const Duration(seconds: 1));

      // Should display the screen
      expect(find.text('Learning'), findsOneWidget);
      expect(find.text('My Courses'), findsOneWidget);
      
      // After API call fails, should show error state or loading
      await tester.pump(const Duration(seconds: 1));
      
      // Check that scaffold has correct background
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(AppTheme.canvas));
    });

    testWidgets('TasksScreen displays tasks list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const TasksScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Tasks'), findsOneWidget);
      expect(find.text('My Tasks'), findsOneWidget);
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('ResultsScreen displays grades', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const ResultsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Results'), findsOneWidget);
      expect(find.text('My Grades'), findsOneWidget);
      expect(find.text('Mathematics'), findsOneWidget);
      expect(find.text('92/100'), findsOneWidget);
    });

    testWidgets('Student screens use correct theme colors', (WidgetTester tester) async {
      // LearningScreen
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const LearningScreen(),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));
      var scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(AppTheme.canvas));

      // TasksScreen
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const TasksScreen(),
        ),
      );
      await tester.pumpAndSettle();
      scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(AppTheme.canvas));

      // ResultsScreen
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const ResultsScreen(),
        ),
      );
      await tester.pumpAndSettle();
      scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(AppTheme.canvas));
    });
  });
}
