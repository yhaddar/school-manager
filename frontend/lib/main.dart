import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'router/app_router.dart';
import 'services/auth_service.dart';
import 'services/api_client.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();
  
  runApp(SchoolManagerApp(sharedPreferences: sharedPreferences));
}

// Design System Tokens from DESIGN.md
class AppTheme {
  // Semantic Color Tokens
  static const Color canvas = Color(0xFFF8FAFC);        // App background
  static const Color surface = Color(0xFFFFFFFF);     // Cards, dialogs
  static const Color surfaceRaised = Color(0xFFF1F5F9); // Raised cards
  static const Color onSurface = Color(0xFF0F172A);     // Primary text
  static const Color muted = Color(0xFF475569);         // Secondary text
  
  // Primary colors
  static const Color primary = Color(0xFF0F766E);       // Primary action
  static const Color onPrimary = Color(0xFFFFFFFF);     // On primary
  
  // Status colors
  static const Color info = Color(0xFF1D4ED8);
  static const Color success = Color(0xFF15803D);
  static const Color warning = Color(0xFF92400E);
  static const Color danger = Color(0xFFB91C1C);
  
  // Dark theme colors
  static const Color darkCanvas = Color(0xFF020617);
  static const Color darkSurface = Color(0xFF0F172A);
  static const Color darkOnSurface = Color(0xFFF8FAFC);
  static const Color darkPrimary = Color(0xFF5EEAD4);
  static const Color darkOnPrimary = Color(0xFF042F2E);
  
  // Spacing scale
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space48 = 48;
  
  // Border radius
  static const double radius8 = 8;
  static const double radius12 = 12;
  static const double radius16 = 16;
  static const double radiusPill = 100;
}

// Typography from DESIGN.md
class AppTextTheme {
  static const TextStyle display = TextStyle(
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w700,
  );
  
  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    height: 36 / 28,
    fontWeight: FontWeight.w700,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle title = TextStyle(
    fontSize: 18,
    height: 26 / 18,
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
  );
  
  static const TextStyle small = TextStyle(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
  );
  
  static const TextStyle label = TextStyle(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
  );
}

class SchoolManagerApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;

  const SchoolManagerApp({
    super.key,
    required this.sharedPreferences,
  });

  @override
  Widget build(BuildContext context) {
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
      child: MaterialApp.router(
        title: 'School Manager',
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
        theme: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
            surface: AppTheme.surface,
            onSurface: AppTheme.onSurface,
            primary: AppTheme.primary,
            onPrimary: AppTheme.onPrimary,
          ),
          scaffoldBackgroundColor: AppTheme.canvas,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppTheme.surface,
            foregroundColor: AppTheme.onSurface,
            elevation: 1,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: AppTheme.surface,
            selectedItemColor: AppTheme.primary,
            unselectedItemColor: AppTheme.muted,
          ),
          cardTheme: CardThemeData(
            color: AppTheme.surface,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radius8),
            ),
          ),
          textTheme: const TextTheme(
            displayLarge: AppTextTheme.display,
            bodyLarge: AppTextTheme.body,
            bodyMedium: AppTextTheme.small,
            labelLarge: AppTextTheme.label,
            labelSmall: AppTextTheme.caption,
          ),
        ),
        darkTheme: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            surface: AppTheme.darkSurface,
            onSurface: AppTheme.darkOnSurface,
            primary: AppTheme.darkPrimary,
            onPrimary: AppTheme.darkOnPrimary,
          ),
          scaffoldBackgroundColor: AppTheme.darkCanvas,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppTheme.darkSurface,
            foregroundColor: AppTheme.darkOnSurface,
            elevation: 1,
          ),
        ),
        themeMode: ThemeMode.system,
        locale: const Locale('en'),
        supportedLocales: const [
          Locale('en'),
          Locale('fr'),
          Locale('ar'),
        ],
      ),
    );
  }
}
