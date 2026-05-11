import 'package:equatable/equatable.dart';

class CapacityPlanEntity extends Equatable {
  final int id;
  final String userId;
  final int projectId;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isOngoing;
  final double hoursPerDay;
  final String createdById;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CapacityUserEntity user;
  final CapacityProjectEntity project;

  const CapacityPlanEntity({
    required this.id,
    required this.userId,
    required this.projectId,
    required this.startDate,
    this.endDate,
    required this.isOngoing,
    required this.hoursPerDay,
    required this.createdById,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.project,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        projectId,
        startDate,
        endDate,
        isOngoing,
        hoursPerDay,
        createdById,
        createdAt,
        updatedAt,
        user,
        project,
      ];
}

class CapacityUserEntity extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? profileImageUrl;

  const CapacityUserEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profileImageUrl,
  });

  @override
  List<Object?> get props => [id, email, firstName, lastName, profileImageUrl];
}

class CapacityProjectEntity extends Equatable {
  final int id;
  final String name;
  final bool isBillable;

  const CapacityProjectEntity({
    required this.id,
    required this.name,
    required this.isBillable,
  });

  @override
  List<Object?> get props => [id, name, isBillable];
}
