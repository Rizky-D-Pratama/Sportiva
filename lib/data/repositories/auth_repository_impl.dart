import '../../constants/app_images.dart';
import '../../models/user.dart';
import '../../models/venue.dart';
import 'auth_repository.dart';

/// Fake implementation of AuthRepository (TODO: Later replace with Supabase auth)
class FakeAuthRepository implements AuthRepository {
  static const Venue _sportivaCenter = Venue(
    id: 'venue_1',
    name: 'Sportiva Center',
    location: 'Jl. Ketintang, Surabaya',
  );

  static final User seedAdmin = User(
    id: 'admin_1',
    name: 'Rizky Doni Pratama',
    email: 'admin@sportiva.test',
    profilePhotoUrl: AppImages.blankProfile,
    phoneNumber: '0812 9999 8888',
    joinedDate: DateTime(2026, 1, 1),
    role: UserRole.admin,
    venue: _sportivaCenter,
  );

  static final User seedUser = User(
    id: 'user_1',
    name: 'Arya Ghiffary Habyantara',
    email: 'user@sportiva.test',
    profilePhotoUrl: AppImages.blankProfile,
    phoneNumber: '0812 3456 7890',
    joinedDate: DateTime(2026, 10, 1),
    role: UserRole.user,
    venue: null,
  );

  /// In-memory static storage of registered accounts
  static final List<User> _accounts = [
    seedAdmin,
    seedUser,
  ];

  /// Passwords map for in-memory authentication
  static final Map<String, String> _passwords = {
    'admin@sportiva.test': 'sportiva123',
    'user@sportiva.test': 'sportiva123',
  };

  /// Current logged-in user in memory
  static User? _currentUser;

  @override
  User? get currentUser => _currentUser;

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  @override
  Future<bool> isEmailRegistered(String email) async {
    final normalized = _normalizeEmail(email);
    return _accounts.any((u) => _normalizeEmail(u.email) == normalized);
  }

  @override
  Future<User?> signIn(String email, String password) async {
    // TODO: Replace with Supabase authentication signIn
    await Future.delayed(const Duration(milliseconds: 50));
    final normalized = _normalizeEmail(email);

    final userIndex = _accounts.indexWhere(
      (u) => _normalizeEmail(u.email) == normalized,
    );

    if (userIndex == -1) {
      return null;
    }

    final matchedUser = _accounts[userIndex];
    final expectedPassword = _passwords[_normalizeEmail(matchedUser.email)];

    if (expectedPassword == password) {
      _currentUser = matchedUser;
      return matchedUser;
    }

    return null;
  }

  @override
  Future<User?> signUp(
    String name,
    String email,
    String phoneNumber,
    String password,
  ) async {
    // TODO: Replace with Supabase authentication signUp
    await Future.delayed(const Duration(milliseconds: 50));
    final normalized = _normalizeEmail(email);

    if (await isEmailRegistered(email)) {
      return null;
    }

    final newUser = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      profilePhotoUrl: AppImages.blankProfile,
      joinedDate: DateTime.now(),
      role: UserRole.user,
      venue: null,
    );

    _accounts.add(newUser);
    _passwords[normalized] = password;
    return newUser;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 50));
    _currentUser = null;
  }

  @override
  Future<User?> updateProfile({
    required String name,
    required String phoneNumber,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (_currentUser == null) return null;

    final updated = _currentUser!.copyWith(
      name: name,
      phoneNumber: phoneNumber,
    );

    _currentUser = updated;

    final index = _accounts.indexWhere((u) => u.id == updated.id);
    if (index != -1) {
      _accounts[index] = updated;
    }

    return updated;
  }
}
