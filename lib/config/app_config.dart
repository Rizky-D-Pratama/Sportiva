import '../data/repositories/auth_repository.dart';

/// Application configuration reading --dart-define parameters
class AppConfig {
  static late final AuthRepository authRepository;

  static String get supabaseUrl =>
      const String.fromEnvironment('SUPABASE_URL');
  static String get supabasePublishableKey =>
      const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static bool get isConfigValid =>
      supabaseUrl.trim().isNotEmpty && supabasePublishableKey.trim().isNotEmpty;
}
