import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/app_config.dart';
import 'data/repositories/supabase_admin_report_repository.dart';
import 'data/repositories/supabase_auth_repository.dart';
import 'data/repositories/supabase_booking_repository.dart';
import 'data/repositories/supabase_court_repository.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool isConfigValid = false;

  if (AppConfig.isConfigValid) {
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        publishableKey: AppConfig.supabasePublishableKey,
      );
      AppConfig.authRepository = SupabaseAuthRepository();
      AppConfig.courtRepository = SupabaseCourtRepository();
      AppConfig.bookingRepository = SupabaseBookingRepository();
      AppConfig.adminReportRepository = SupabaseAdminReportRepository();
      isConfigValid = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Supabase initialize error: $e');
      }
      isConfigValid = false;
    }
  } else {
    if (kDebugMode) {
      debugPrint('Supabase configuration missing in AppConfig');
    }
    isConfigValid = false;
  }

  final themeController = ThemeController();
  await themeController.load();

  runApp(
    SportivaApp(
      isConfigValid: isConfigValid,
      themeController: themeController,
    ),
  );
}

class SportivaApp extends StatelessWidget {
  final bool isConfigValid;
  final ThemeController themeController;

  const SportivaApp({
    super.key,
    this.isConfigValid = true,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    return ThemeControllerScope(
      controller: themeController,
      child: AnimatedBuilder(
        animation: themeController,
        builder: (context, child) {
          return MaterialApp(
            title: 'Sportiva',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeController.themeMode,
            home: isConfigValid
                ? const SplashScreen()
                : const AppConfigErrorScreen(),
          );
        },
      ),
    );
  }
}

class AppConfigErrorScreen extends StatelessWidget {
  const AppConfigErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingXLarge),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Konfigurasi Aplikasi Belum Lengkap',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: colors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12.0),
                Text(
                  'URL atau Kunci Supabase tidak ditemukan atau tidak valid. Silakan jalankan aplikasi dengan parameter --dart-define yang sesuai.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
