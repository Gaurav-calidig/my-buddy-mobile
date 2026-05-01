import 'package:core/features/settings/domain/entities/user_tag_entity.dart';

class UserTagModel extends UserTagEntity {
  const UserTagModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.color,
    required super.createdAt,
  });

  factory UserTagModel.fromJson(Map<String, dynamic> json) {
    return UserTagModel(
      id: json['id'] as int,
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      color: json['color'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
