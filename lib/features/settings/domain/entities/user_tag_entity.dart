import 'package:equatable/equatable.dart';

class UserTagEntity extends Equatable {
  final int id;
  final String userId;
  final String name;
  final String color;
  final DateTime createdAt;

  const UserTagEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.color,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, name, color, createdAt];
}
