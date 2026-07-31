import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/env.dart';
import 'core/error/error_reporter.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';

Future<void> main() async {
  // Config must be in memory before any provider reads Env.
  WidgetsFlutterBinding.ensureInitialized();

  // Catch framework and platform errors that never reach a repository's
  // guard(). Swap ErrorReporter.instance for a Crashlytics/Sentry
  // implementation here and every report follows.
  ErrorReporter.installGlobalHandlers();

  await Env.load();

  runApp(
    const ProviderScope(
      child: CleanArchApp(),
    ),
  );
}

class CleanArchApp extends ConsumerWidget {
  const CleanArchApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    // Resolving this here (rather than only in app_router's redirect)
    // lets us show a splash screen instead of a blank frame while the
    // stored session is being checked on cold start.
    final authState = ref.watch(authControllerProvider);

    return MaterialApp.router(
      title: 'Flutter Clean Architecture Starter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
      builder: (context, child) {
        if (authState.isLoading) {
          return const _SplashScreen();
        }
        return child ?? const SizedBox.shrink();
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
