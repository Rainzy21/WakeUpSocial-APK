import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'core/themes/app_theme.dart';
import 'core/providers/cart_provider.dart';
import 'core/providers/session_provider.dart';
import 'core/services/local_storage_service.dart';
import 'core/observability/app_logger.dart';
import 'core/observability/app_metrics.dart';
import 'core/observability/crash_reporter.dart';
import 'routes/app_routes.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  await runGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
    const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw StateError(
        'SUPABASE_URL and SUPABASE_ANON_KEY must be provided via '
        '--dart-define or --dart-define-from-file=.env',
      );
    }

    await CrashReporter.init();

    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseAnonKey,
    );

    AppMetrics.recordEvent('app.start');
    AppLogger.info('app.bootstrap_complete');

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
  });
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
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
