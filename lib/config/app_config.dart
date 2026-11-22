import '../data/booking_repository.dart';
import '../data/court_repository.dart';
import '../data/repositories/auth_repository.dart';

/// Application configuration reading --dart-define parameters
class AppConfig {
  static late final AuthRepository authRepository;
  static late final CourtRepository courtRepository;
  static late final BookingRepository bookingRepository;

  static String get supabaseUrl =>
      const String.fromEnvironment('SUPABASE_URL');
  static String get supabasePublishableKey =>
      const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static bool get isConfigValid =>
      supabaseUrl.trim().isNotEmpty && supabasePublishableKey.trim().isNotEmpty;
}
