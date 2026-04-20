/// Entity representing a user in the application.
/// Contains basic user information and authentication token.
class UserEntity {
  /// Unique identifier of the user
  final String id;

  /// Full name of the user
  final String name;

  /// Email address of the user
  final String email;

  /// Authentication token (JWT or similar)
  final String token;

  /// Constructor for creating a [UserEntity]
  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
  });
}
