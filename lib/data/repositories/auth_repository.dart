import '../../models/user.dart';

/// Abstract repository interface for Authentication (TODO: Replace with Supabase)
abstract class AuthRepository {
  User? get currentUser;
  Future<User?> signIn(String email, String password);
  Future<User?> signUp(String name, String email, String phoneNumber, String password);
  Future<bool> isEmailRegistered(String email);
  Future<void> signOut();
  Future<User?> updateProfile({required String name, required String phoneNumber});
}
