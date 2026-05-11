import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/features/capacity_planner/domain/usecases/get_capacity_plans_usecase.dart';
import 'package:core/features/capacity_planner/presentation/bloc/capacity_planner_event.dart';
import 'package:core/features/capacity_planner/presentation/bloc/capacity_planner_state.dart';

class CapacityPlannerBloc extends Bloc<CapacityPlannerEvent, CapacityPlannerState> {
  final GetCapacityPlansUseCase getCapacityPlansUseCase;

  CapacityPlannerBloc({required this.getCapacityPlansUseCase})
      : super(CapacityPlannerInitial()) {
    on<LoadCapacityPlans>(_onLoadCapacityPlans);
  }

  Future<void> _onLoadCapacityPlans(
    LoadCapacityPlans event,
    Emitter<CapacityPlannerState> emit,
  ) async {
    emit(CapacityPlannerLoading());
    try {
      final plans = await getCapacityPlansUseCase(
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(CapacityPlannerLoaded(
        plans: plans,
        startDate: event.startDate,
        endDate: event.endDate,
      ));
    } catch (e) {
      emit(CapacityPlannerError(e.toString()));
    }
  }
}
