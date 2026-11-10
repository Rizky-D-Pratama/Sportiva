import '../../models/user.dart';
import 'auth_repository.dart';

/// Fake implementation of AuthRepository (TODO: Later replace with Supabase auth)
class FakeAuthRepository implements AuthRepository {
  @override
  Future<User> signIn(String email, String password) async {
    // TODO: Replace with Supabase authentication signIn
    return User(
      id: 'user_1',
      name: 'Raka Pratama',
      email: email,
      phoneNumber: '081234567890',
      joinedDate: DateTime.now(),
    );
  }

  @override
  Future<User> signUp(String name, String email, String phoneNumber, String password) async {
    // TODO: Replace with Supabase authentication signUp
    return User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      joinedDate: DateTime.now(),
    );
  }
}
