import 'package:core/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.firebaseUid,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.profileImageUrl,
    required super.portalRole,
    required super.isActive,
    super.dateOfBirth,
    required super.createdAt,
    required super.updatedAt,
    required super.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? json['uid'] as String? ?? '',
      firebaseUid: json['firebaseUid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String? ?? json['name'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String? ?? '',
      portalRole: json['portalRole'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      token: (json['token'] ?? json['firebaseIdToken'] ?? '') as String,
    );
  }

  factory UserModel.fromBasicInfo({
    required String id,
    required String email,
    required String name,
    required String token,
    String? profileImageUrl,
  }) {
    final names = name.trim().split(' ');
    final firstName = names.isNotEmpty ? names.first : '';
    final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';
    return UserModel(
      id: id,
      firebaseUid: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      profileImageUrl: profileImageUrl ?? '',
      portalRole: '',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      token: token,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebaseUid': firebaseUid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'profileImageUrl': profileImageUrl,
      'portalRole': portalRole,
      'isActive': isActive,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'token': token,
    };
  }
}