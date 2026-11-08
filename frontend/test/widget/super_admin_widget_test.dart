import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:school_manager/screens/super_admin/home_screen.dart';
import 'package:school_manager/main.dart';

void main() {
  group('SuperAdminHomeScreen Widget Tests', () {
    testWidgets('renders app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const SuperAdminHomeScreen(),
        ),
      );

      expect(find.text('Super Admin'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renders bottom navigation bar with correct tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const SuperAdminHomeScreen(),
        ),
      );

      expect(find.text('Institutions'), findsOneWidget);
      expect(find.text('Analytics'), findsOneWidget);
      expect(find.text('Settings'), findsWidgets); // Appears in both tab bar and settings list
    });

    testWidgets('displays institutions tab by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const SuperAdminHomeScreen(),
        ),
      );

      expect(find.text('Total Institutions'), findsOneWidget);
      expect(find.text('Recent Institutions'), findsOneWidget);
    });

    testWidgets('switches tabs correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const SuperAdminHomeScreen(),
        ),
      );

      // Initially on Institutions tab
      expect(find.text('Total Institutions'), findsOneWidget);

      // Tap Analytics tab
      await tester.tap(find.byIcon(Iconsax.barcode));
      await tester.pump();

      expect(find.text('Platform Analytics'), findsOneWidget);

      // Tap Settings tab
      await tester.tap(find.byIcon(Iconsax.settings));
      await tester.pump();

      // Settings tab shows profile list item
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('renders profile and notification icons in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const SuperAdminHomeScreen(),
        ),
      );

      expect(find.byIcon(Iconsax.user), findsOneWidget);
      expect(find.byIcon(Iconsax.direct_notification), findsOneWidget);
    });
  });
}
