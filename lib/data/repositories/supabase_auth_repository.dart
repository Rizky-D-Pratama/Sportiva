import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../constants/app_images.dart';
import '../../models/user.dart';
import '../../models/venue.dart';
import 'auth_repository.dart';

/// Supabase implementation of AuthRepository for Sportiva
class SupabaseAuthRepository implements AuthRepository {
  User? _currentUser;

  @override
  User? get currentUser => _currentUser;

  /// Helper to log debug messages in kDebugMode only
  void _log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  /// Normalizes phone number by stripping spaces and dashes
  String _normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[\s-]'), '');
  }

  /// Checks if an error is a network connection issue without using platform-specific APIs
  bool _isNetworkError(Object error) {
    final str = error.toString().toLowerCase();
    return str.contains('socketexception') ||
        str.contains('clientexception') ||
        str.contains('network') ||
        str.contains('failed to connect') ||
        str.contains('connection refused') ||
        str.contains('connection closed') ||
        str.contains('handshakeexception');
  }

  /// Single private helper to load profile and venue for a user
  Future<User?> _fetchUserProfileAndVenue({
    required String id,
    required String email,
  }) async {
    final profile = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (profile == null) {
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (_) {}
      _currentUser = null;
      return null;
    }

    final roleStr = profile['role'] as String? ?? 'user';
    final role = roleStr == 'admin' ? UserRole.admin : UserRole.user;

    Venue? venue;
    if (role == UserRole.admin) {
      final venueData = await Supabase.instance.client
          .from('venues')
          .select()
          .eq('admin_id', id)
          .maybeSingle();

      if (venueData != null) {
        venue = Venue(
          id: venueData['id'] as String,
          name: venueData['nama'] as String? ?? '',
          location: venueData['alamat'] as String? ?? '',
        );
      }
    }

    final joinedDateStr = profile['created_at'] as String?;
    final joinedDate = joinedDateStr != null
        ? DateTime.tryParse(joinedDateStr) ?? DateTime.now()
        : DateTime.now();

    final user = User(
      id: profile['id'] as String,
      name: profile['nama'] as String? ?? '',
      email: profile['email'] as String? ?? email,
      phoneNumber: profile['nomor_telepon'] as String?,
      profilePhotoUrl: profile['foto'] as String? ?? AppImages.blankProfile,
      joinedDate: joinedDate,
      role: role,
      venue: venue,
    );

    _currentUser = user;
    return user;
  }

  @override
  Future<User?> restoreSession() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        _currentUser = null;
        return null;
      }

      final authUser = session.user;
      return await _fetchUserProfileAndVenue(
        id: authUser.id,
        email: authUser.email ?? '',
      );
    } catch (e) {
      _log('SUPABASE restoreSession error: $e');
      _currentUser = null;
      return null;
    }
  }

  @override
  Future<AuthResult<User>> signIn(String email, String password) async {
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final authUser = response.user;
      if (authUser == null) {
        return const AuthResult.failure(AuthFailureType.invalidCredentials);
      }

      try {
        final user = await _fetchUserProfileAndVenue(
          id: authUser.id,
          email: authUser.email ?? '',
        );

        if (user == null) {
          return const AuthResult.failure(AuthFailureType.profileNotFound);
        }

        return AuthResult.success(user);
      } catch (profileError) {
        _log('SUPABASE signIn profile fetch error: $profileError');
        try {
          await Supabase.instance.client.auth.signOut();
        } catch (_) {}
        _currentUser = null;

        if (_isNetworkError(profileError) || profileError is AuthRetryableFetchException) {
          return const AuthResult.failure(AuthFailureType.networkError);
        }
        return const AuthResult.failure(AuthFailureType.serverError);
      }
    } on AuthException catch (e) {
      _log('SUPABASE AuthException in signIn: message=${e.message}, code=${e.code}, statusCode=${e.statusCode}');
      final code = e.code?.toLowerCase();
      if (code == 'invalid_credentials' ||
          code == 'invalid_grant' ||
          e.message.toLowerCase().contains('invalid login credentials')) {
        return const AuthResult.failure(AuthFailureType.invalidCredentials);
      }
      if (e is AuthRetryableFetchException) {
        return const AuthResult.failure(AuthFailureType.networkError);
      }
      return const AuthResult.failure(AuthFailureType.serverError);
    } on PostgrestException catch (e) {
      _log('SUPABASE PostgrestException in signIn: message=${e.message}, code=${e.code}, details=${e.details}, hint=${e.hint}');
      return const AuthResult.failure(AuthFailureType.serverError);
    } catch (e, st) {
      _log('SUPABASE Unknown Exception in signIn: $e\n$st');
      if (_isNetworkError(e)) {
        return const AuthResult.failure(AuthFailureType.networkError);
      }
      return const AuthResult.failure(AuthFailureType.serverError);
    }
  }

  @override
  Future<AuthResult<void>> signUp(
    String name,
    String email,
    String phoneNumber,
    String password,
  ) async {
    try {
      final cleanPhone = _normalizePhone(phoneNumber);
      final response = await Supabase.instance.client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'nama': name.trim(),
          'nomor_telepon': cleanPhone,
        },
      );

      if (response.user == null) {
        return const AuthResult.failure(AuthFailureType.serverError);
      }

      try {
        await Supabase.instance.client.auth.signOut();
      } catch (_) {}
      _currentUser = null;
      return const AuthResult.success(null);
    } on AuthException catch (e) {
      _log('SUPABASE AuthException in signUp: message=${e.message}, code=${e.code}');
      final code = e.code?.toLowerCase();
      if (code == 'user_already_exists' ||
          code == 'email_exists' ||
          code == 'email_already_in_use' ||
          e.message.toLowerCase().contains('already registered') ||
          e.message.toLowerCase().contains('user already exists')) {
        return const AuthResult.failure(AuthFailureType.emailAlreadyRegistered);
      }
      if (e is AuthRetryableFetchException) {
        return const AuthResult.failure(AuthFailureType.networkError);
      }
      return const AuthResult.failure(AuthFailureType.serverError);
    } on PostgrestException catch (e) {
      _log('SUPABASE PostgrestException in signUp: message=${e.message}, code=${e.code}');
      return const AuthResult.failure(AuthFailureType.serverError);
    } catch (e, st) {
      _log('SUPABASE Unknown Exception in signUp: $e\n$st');
      if (_isNetworkError(e)) {
        return const AuthResult.failure(AuthFailureType.networkError);
      }
      return const AuthResult.failure(AuthFailureType.serverError);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {}
    _currentUser = null;
  }

  @override
  Future<AuthResult<User>> updateProfile({
    required String name,
    required String phoneNumber,
  }) async {
    if (_currentUser == null) {
      return const AuthResult.failure(AuthFailureType.serverError);
    }

    try {
      final cleanPhone = _normalizePhone(phoneNumber);
      final userId = _currentUser!.id;

      final response = await Supabase.instance.client
          .from('profiles')
          .update({
            'nama': name.trim(),
            'nomor_telepon': cleanPhone,
          })
          .eq('id', userId)
          .select()
          .single();

      _currentUser = _currentUser!.copyWith(
        name: response['nama'] as String? ?? name.trim(),
        phoneNumber: response['nomor_telepon'] as String? ?? cleanPhone,
      );

      return AuthResult.success(_currentUser!);
    } on PostgrestException catch (e) {
      _log('SUPABASE PostgrestException in updateProfile: message=${e.message}, code=${e.code}');
      return const AuthResult.failure(AuthFailureType.serverError);
    } on AuthException catch (e) {
      _log('SUPABASE AuthException in updateProfile: message=${e.message}, code=${e.code}');
      if (e is AuthRetryableFetchException) {
        return const AuthResult.failure(AuthFailureType.networkError);
      }
      return const AuthResult.failure(AuthFailureType.serverError);
    } catch (e, st) {
      _log('SUPABASE Unknown Exception in updateProfile: $e\n$st');
      if (_isNetworkError(e)) {
        return const AuthResult.failure(AuthFailureType.networkError);
      }
      return const AuthResult.failure(AuthFailureType.serverError);
    }
  }
}
