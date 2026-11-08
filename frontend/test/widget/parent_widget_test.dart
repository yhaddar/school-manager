import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:school_manager/screens/parent/home_screen.dart';
import 'package:school_manager/main.dart';

void main() {
  group('ParentHomeScreen Widget Tests', () {
    testWidgets('renders app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const ParentHomeScreen(),
        ),
      );

      expect(find.text('School Manager'), findsOneWidget);
    });

    testWidgets('renders tab bar with correct labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const ParentHomeScreen(),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Children'), findsOneWidget);
      expect(find.text('Payments'), findsOneWidget);
      expect(find.text('Messages'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('displays welcome message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const ParentHomeScreen(),
        ),
      );

      expect(find.text('Good afternoon, Sarah'), findsOneWidget);
      expect(find.text('Your Children'), findsOneWidget);
    });

    testWidgets('displays children list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const ParentHomeScreen(),
        ),
      );

      expect(find.text('Alex Johnson'), findsOneWidget);
      expect(find.text('Emma Johnson'), findsOneWidget);
    });

    testWidgets('uses correct theme colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const ParentHomeScreen(),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(AppTheme.canvas));
    });
  });
}
