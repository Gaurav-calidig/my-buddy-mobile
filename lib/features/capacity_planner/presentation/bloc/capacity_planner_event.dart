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
