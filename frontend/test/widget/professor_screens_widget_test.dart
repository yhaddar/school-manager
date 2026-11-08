import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:school_manager/screens/professor/classes_screen.dart';
import 'package:school_manager/screens/professor/assessments_screen.dart';
import 'package:school_manager/screens/professor/messages_screen.dart';
import 'package:school_manager/main.dart';

void main() {
  group('Professor Screens Widget Tests', () {
    testWidgets('ProfessorClassesScreen displays classes list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const ProfessorClassesScreen(),
        ),
      );

      expect(find.text('My Classes'), findsOneWidget);
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('ProfessorAssessmentsScreen displays assessments', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const ProfessorAssessmentsScreen(),
        ),
      );

      expect(find.text('Assessments'), findsOneWidget);
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('ProfessorMessagesScreen displays messages', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const ProfessorMessagesScreen(),
        ),
      );

      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('Professor screens use correct theme colors', (WidgetTester tester) async {
      // ClassesScreen
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const ProfessorClassesScreen(),
        ),
      );
      var scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(AppTheme.canvas));

      // AssessementsScreen
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const ProfessorAssessmentsScreen(),
        ),
      );
      scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(AppTheme.canvas));

      // MessagesScreen
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const ProfessorMessagesScreen(),
        ),
      );
      scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(AppTheme.canvas));
    });
  });
}
