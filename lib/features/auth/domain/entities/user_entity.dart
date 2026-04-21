/// Entity representing a user in the application.
/// Independent of data/model layer (clean architecture).
class UserEntity {
  /// Unique identifier of the user
  final String id;

  /// Firebase UID (used for auth mapping)
  final String firebaseUid;

  /// Email address
  final String email;

  /// First name
  final String firstName;

  /// Last name
  final String lastName;

  /// Profile image URL
  final String profileImageUrl;

  /// Role in the system (guest, admin, etc.)
  final String portalRole;

  /// Whether user is active
  final bool isActive;

  /// Date of birth (optional)
  final DateTime? dateOfBirth;

  /// Created timestamp
  final DateTime createdAt;

  /// Updated timestamp
  final DateTime updatedAt;

  /// Auth token (kept separate from backend response)
  final String token;

  UserEntity({
    required this.id,
    required this.firebaseUid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.profileImageUrl,
    required this.portalRole,
    required this.isActive,
    this.dateOfBirth,
    required this.createdAt,
    required this.updatedAt,
    required this.token,
  });

  /// Convenience getter
  String get fullName => '$firstName $lastName';
}