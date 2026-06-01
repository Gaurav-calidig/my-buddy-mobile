import 'package:equatable/equatable.dart';

abstract class CapacityPlannerEvent extends Equatable {
  const CapacityPlannerEvent();

  @override
  List<Object?> get props => [];
}

class LoadCapacityPlans extends CapacityPlannerEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadCapacityPlans({required this.startDate, required this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

class CreateCapacityPlan extends CapacityPlannerEvent {
  final String userId;
  final int projectId;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isOngoing;
  final String hoursPerDay;

  const CreateCapacityPlan({
    required this.userId,
    required this.projectId,
    required this.startDate,
    this.endDate,
    required this.isOngoing,
    required this.hoursPerDay,
  });

  @override
  List<Object?> get props => [userId, projectId, startDate, endDate, isOngoing, hoursPerDay];
}

class UpdateCapacityPlan extends CapacityPlannerEvent {
  final int planId;
  final String userId;
  final int projectId;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isOngoing;
  final String hoursPerDay;

  const UpdateCapacityPlan({
    required this.planId,
    required this.userId,
    required this.projectId,
    required this.startDate,
    this.endDate,
    required this.isOngoing,
    required this.hoursPerDay,
  });

  @override
  List<Object?> get props => [planId, userId, projectId, startDate, endDate, isOngoing, hoursPerDay];
}

class DeleteCapacityPlan extends CapacityPlannerEvent {
  final int planId;

  const DeleteCapacityPlan(this.planId);

  @override
  List<Object?> get props => [planId];
}

