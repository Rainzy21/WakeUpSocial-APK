import 'package:flutter/material.dart';
import 'core/themes/app_theme.dart';
import 'routes/app_routes.dart';
import 'routes/app_router.dart';

void main() {
  runApp(const WakeUpSocialApp());
}

class WakeUpSocialApp extends StatelessWidget {
  const WakeUpSocialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WakeUpSocial',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      // Demo flow: Login → Home (MainNavigation)
      // Ganti ke AppRoutes.home jika ingin skip login
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
