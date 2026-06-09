import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/themes/app_theme.dart';
import 'routes/app_routes.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://pxwcyhfvqodnawbaawcr.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB4d2N5aGZ2cW9kbmF3YmFhd2NyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA5OTM5OTAsImV4cCI6MjA5NjU2OTk5MH0.X_Bs5YKHn_taG0zLDMeNKvBY9CtDAdpCNRbYg8dlpNg',
  );

  runApp(const WakeUpSocialApp());
}

// Global instance untuk mempermudah akses ke Supabase client
final supabase = Supabase.instance.client;

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
      // Cek apakah user sudah login atau belum
      initialRoute: supabase.auth.currentUser != null
          ? AppRoutes.home
          : AppRoutes.login,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
