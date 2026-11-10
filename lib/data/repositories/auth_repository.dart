import '../../models/user.dart';

/// Abstract repository interface for Authentication (TODO: Replace with Supabase)
abstract class AuthRepository {
  Future<User> signIn(String email, String password);
  Future<User> signUp(String name, String email, String phoneNumber, String password);
}
