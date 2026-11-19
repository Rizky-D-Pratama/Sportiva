import 'dart:async';
import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';
import 'admin/admin_shell.dart';
import 'main_shell.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    final startTime = DateTime.now();

    User? restoredUser;
    try {
      restoredUser = await AppConfig.authRepository.restoreSession();
    } catch (_) {
      restoredUser = null;
    }

    final elapsed = DateTime.now().difference(startTime);
    final remaining = const Duration(seconds: 2) - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }

    if (!mounted) return;

    if (restoredUser != null) {
      final targetScreen = restoredUser.role == UserRole.admin
          ? const AdminShell()
          : MainShell(repository: AppConfig.courtRepository);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => targetScreen),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 96.0,
                    height: 96.0,
                    child: Image.asset(
                      'assets/images/logo_sportiva.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    'Sportiva',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Text(
                    'Find Your Game. Book Your Court.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16.0),
                  Container(
                    width: 48.0,
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: colors.brandPrimary,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text(
                  'TEMUKAN LAPANGAN. MULAI PERMAINAN.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                    fontSize: 10.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
