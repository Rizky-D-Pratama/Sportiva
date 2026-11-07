import 'package:flutter/material.dart';
import 'data/court_repository.dart';
import 'screens/main_shell.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const SportivaApp());
}

class SportivaApp extends StatelessWidget {
  const SportivaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final courtRepository = FakeCourtRepository();

    return MaterialApp(
      title: 'Sportiva',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: MainShell(repository: courtRepository),
    );
  }
}
