import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:school_manager/screens/search/search_screen.dart';
import 'package:school_manager/main.dart';

void main() {
  group('SearchScreen Widget Tests', () {
    testWidgets('renders app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const SearchScreen(),
        ),
      );

      expect(find.text('Search'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('displays search text field', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const SearchScreen(),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search notifications, messages, events...'), findsOneWidget);
    });

    testWidgets('shows initial empty state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const SearchScreen(),
        ),
      );

      expect(find.text('Start typing to search'), findsOneWidget);
    });

    testWidgets('uses correct theme colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const SearchScreen(),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(AppTheme.canvas));
    });

    testWidgets('clears search when clear button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const SearchScreen(),
        ),
      );

      // Enter text to trigger search
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      // Tap clear button
      await tester.tap(find.byIcon(Iconsax.close_circle));
      await tester.pump();

      // Should show empty state again
      expect(find.text('Start typing to search'), findsOneWidget);
    });
  });
}
