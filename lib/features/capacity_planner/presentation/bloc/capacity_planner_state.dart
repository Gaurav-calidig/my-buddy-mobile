import 'package:core/features/auth/domain/entities/user_entity.dart';
import 'package:core/features/projects/domain/entities/project_entity.dart';
import 'package:core/features/capacity_planner/domain/entities/capacity_plan_entity.dart';
import 'package:equatable/equatable.dart';

abstract class CapacityPlannerState extends Equatable {
  const CapacityPlannerState();

  @override
  List<Object?> get props => [];
}

class CapacityPlannerInitial extends CapacityPlannerState {}

class CapacityPlannerLoading extends CapacityPlannerState {}

class CapacityPlannerLoaded extends CapacityPlannerState {
  final List<CapacityPlanEntity> plans;
  final List<UserEntity> users;
  final List<ProjectEntity> projects;
  final DateTime startDate;
  final DateTime endDate;

  const CapacityPlannerLoaded({
    required this.plans,
    this.users = const [],
    this.projects = const [],
    required this.startDate,
    required this.endDate,
  });

  CapacityPlannerLoaded copyWith({
    List<CapacityPlanEntity>? plans,
    List<UserEntity>? users,
    List<ProjectEntity>? projects,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return CapacityPlannerLoaded(
      plans: plans ?? this.plans,
      users: users ?? this.users,
      projects: projects ?? this.projects,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object?> get props => [plans, users, projects, startDate, endDate];
}

class CapacityPlannerError extends CapacityPlannerState {
  final String message;

  const CapacityPlannerError(this.message);

  @override
  List<Object?> get props => [message];
}
