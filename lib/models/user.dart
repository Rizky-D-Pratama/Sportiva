/// Model representing a Sportiva app user
class User {
  final String id;
  final String name;
  final String email;
  final String? profilePhotoUrl;
  final String? phoneNumber;
  final DateTime joinedDate;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.profilePhotoUrl,
    this.phoneNumber,
    required this.joinedDate,
  });
}
