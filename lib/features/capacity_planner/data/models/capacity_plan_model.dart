import 'package:core/features/capacity_planner/domain/entities/capacity_plan_entity.dart';

class CapacityPlanModel extends CapacityPlanEntity {
  const CapacityPlanModel({
    required super.id,
    required super.userId,
    required super.projectId,
    required super.startDate,
    super.endDate,
    required super.isOngoing,
    required super.hoursPerDay,
    required super.createdById,
    required super.createdAt,
    required super.updatedAt,
    required super.user,
    required super.project,
  });

  factory CapacityPlanModel.fromJson(Map<String, dynamic> json) {
    return CapacityPlanModel(
      id: json['id'] as int,
      userId: json['userId'] as String,
      projectId: json['projectId'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      isOngoing: json['isOngoing'] as bool? ?? false,
      hoursPerDay: double.tryParse(json['hoursPerDay']?.toString() ?? '0') ?? 0.0,
      createdById: json['createdById'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      user: CapacityUserModel.fromJson(json['user'] as Map<String, dynamic>),
      project: CapacityProjectModel.fromJson(json['project'] as Map<String, dynamic>),
    );
  }
}

class CapacityUserModel extends CapacityUserEntity {
  const CapacityUserModel({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    super.profileImageUrl,
  });

  factory CapacityUserModel.fromJson(Map<String, dynamic> json) {
    return CapacityUserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }
}

class CapacityProjectModel extends CapacityProjectEntity {
  const CapacityProjectModel({
    required super.id,
    required super.name,
    required super.isBillable,
  });

  factory CapacityProjectModel.fromJson(Map<String, dynamic> json) {
    return CapacityProjectModel(
      id: json['id'] as int,
      name: json['name'] as String,
      isBillable: json['isBillable'] as bool? ?? false,
    );
  }
}
