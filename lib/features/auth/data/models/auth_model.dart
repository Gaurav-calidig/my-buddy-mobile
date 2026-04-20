import '../../domain/entities/user_entity.dart';

/// Model representing the authenticated user.
/// Extends [UserEntity] to bridge between API data and domain layer.
class AuthModel extends UserEntity {
  AuthModel({
    required super.id,
    required super.name,
    required super.email,
    required super.token,
  });

  /// Factory constructor to create [AuthModel] from JSON.
  /// Safely maps JSON keys, providing default empty strings if keys are missing.
  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      id: json['user_id'] ?? '', // map API field 'user_id' to entity id
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      token: json['token'] ?? '',
    );
  }

  /// Converts [AuthModel] to JSON format.
  Map<String, dynamic> toJson() {
    return {'user_id': id, 'name': name, 'email': email, 'token': token};
  }
}
