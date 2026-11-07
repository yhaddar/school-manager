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
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
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
