import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:school_manager/screens/admin/people_screen.dart';
import 'package:school_manager/screens/admin/academics_screen.dart';
import 'package:school_manager/screens/admin/operations_screen.dart';
import 'package:school_manager/screens/admin/roles_delegation_screen.dart';
import 'package:school_manager/screens/admin/person_profile_screen.dart';
import 'package:school_manager/main.dart';

void main() {
  group('Admin Screens Widget Tests', () {
    testWidgets('PeopleScreen displays people directory', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: ThemeData.light(), home: const PeopleScreen()),
      );

      expect(find.text('People Directory'), findsOneWidget);
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('AcademicsScreen displays academic grid', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: ThemeData.light(), home: const AcademicsScreen()),
      );

      expect(find.text('Academics'), findsOneWidget);
      expect(find.text('Academic Structure'), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('OperationsScreen displays operations grid', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: ThemeData.light(), home: const OperationsScreen()),
      );

      expect(find.text('Operations'), findsOneWidget);
      expect(find.text('Operations Management'), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('RolesDelegationScreen displays role management', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const RolesDelegationScreen(),
        ),
      );

      expect(find.text('Roles & Permissions'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('PersonProfileScreen displays profile info', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const PersonProfileScreen(personId: '1'),
        ),
      );

      expect(find.text('Person Profile'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Teacher'), findsOneWidget);
    });

    testWidgets('Admin screens use correct theme colors', (
      WidgetTester tester,
    ) async {
      // PeopleScreen
      await tester.pumpWidget(
        MaterialApp(theme: ThemeData.light(), home: const PeopleScreen()),
      );
      var scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(AppTheme.canvas));

      // AcademicsScreen
      await tester.pumpWidget(
        MaterialApp(theme: ThemeData.light(), home: const AcademicsScreen()),
      );
      scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(AppTheme.canvas));

      // OperationsScreen
      await tester.pumpWidget(
        MaterialApp(theme: ThemeData.light(), home: const OperationsScreen()),
      );
      scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(AppTheme.canvas));

      // RolesDelegationScreen
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const RolesDelegationScreen(),
        ),
      );
      scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(AppTheme.canvas));

      // PersonProfileScreen
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const PersonProfileScreen(personId: '1'),
        ),
      );
      scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(AppTheme.canvas));
    });
  });
}
