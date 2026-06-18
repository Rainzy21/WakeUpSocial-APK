import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'core/themes/app_theme.dart';
import 'core/providers/cart_provider.dart';
import 'core/providers/session_provider.dart';
import 'core/services/local_storage_service.dart';
import 'routes/app_routes.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://cnndakhlbpewqmsxmqsi.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNubmRha2hsYnBld3Ftc3htcXNpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODExNzY0NTAsImV4cCI6MjA5Njc1MjQ1MH0.ow8P4bS2K5wH3lryt8eN1IaP0-IeEn6PZF6es9QpKJo',
  );

  final storage = LocalStorageService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessionProvider(storage)),
        ChangeNotifierProvider(create: (_) => CartProvider(storage)),
      ],
      child: const WakeUpSocialApp(),
    ),
  );
}

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
      // Guest browse: always start at home; login deferred to checkout.
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
