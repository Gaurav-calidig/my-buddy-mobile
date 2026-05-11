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
  final DateTime startDate;
  final DateTime endDate;

  const CapacityPlannerLoaded({
    required this.plans,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [plans, startDate, endDate];
}

class CapacityPlannerError extends CapacityPlannerState {
  final String message;

  const CapacityPlannerError(this.message);

  @override
  List<Object?> get props => [message];
}
