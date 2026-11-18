import '../../models/user.dart';

enum AuthFailureType {
  none,
  invalidCredentials,
  emailAlreadyRegistered,
  networkError,
  serverError,
  profileNotFound,
}

class AuthResult<T> {
  final T? data;
  final AuthFailureType failureType;

  const AuthResult.success(this.data) : failureType = AuthFailureType.none;
  const AuthResult.failure(this.failureType) : data = null;

  bool get isSuccess => failureType == AuthFailureType.none;
}

/// Abstract repository interface for Authentication
abstract class AuthRepository {
  User? get currentUser;
  Future<AuthResult<User>> signIn(String email, String password);
  Future<AuthResult<void>> signUp(
    String name,
    String email,
    String phoneNumber,
    String password,
  );
  Future<void> signOut();
  Future<AuthResult<User>> updateProfile({
    required String name,
    required String phoneNumber,
  });
  Future<User?> restoreSession();
}
