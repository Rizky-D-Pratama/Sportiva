import 'venue.dart';

enum UserRole {
  user,
  admin,
}

/// Model representing a Sportiva app user
class User {
  final String id;
  final String name;
  final String email;
  final String? profilePhotoUrl;
  final String? phoneNumber;
  final DateTime joinedDate;
  final UserRole role;
  final Venue? venue;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.profilePhotoUrl,
    this.phoneNumber,
    required this.joinedDate,
    this.role = UserRole.user,
    this.venue,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? profilePhotoUrl,
    String? phoneNumber,
    DateTime? joinedDate,
    UserRole? role,
    Venue? venue,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      joinedDate: joinedDate ?? this.joinedDate,
      role: role ?? this.role,
      venue: venue ?? this.venue,
    );
  }
}
