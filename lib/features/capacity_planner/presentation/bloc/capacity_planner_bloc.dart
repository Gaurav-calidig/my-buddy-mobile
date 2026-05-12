import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/features/capacity_planner/domain/entities/capacity_plan_entity.dart';
import 'package:core/features/auth/domain/entities/user_entity.dart';
import 'package:core/features/projects/domain/entities/project_entity.dart';
import 'package:core/features/capacity_planner/domain/usecases/get_capacity_plans_usecase.dart';
import 'package:core/features/capacity_planner/domain/usecases/create_capacity_plan_usecase.dart';
import 'package:core/features/projects/domain/usecases/get_all_users_usecase.dart';
import 'package:core/features/projects/domain/usecases/get_projects_usecase.dart';
import 'package:core/features/capacity_planner/presentation/bloc/capacity_planner_event.dart';
import 'package:core/features/capacity_planner/presentation/bloc/capacity_planner_state.dart';

class CapacityPlannerBloc extends Bloc<CapacityPlannerEvent, CapacityPlannerState> {
  final GetCapacityPlansUseCase getCapacityPlansUseCase;
  final CreateCapacityPlanUseCase createCapacityPlanUseCase;
  final GetAllUsersUseCase getAllUsersUseCase;
  final GetProjectsUseCase getProjectsUseCase;

  CapacityPlannerBloc({
    required this.getCapacityPlansUseCase,
    required this.createCapacityPlanUseCase,
    required this.getAllUsersUseCase,
    required this.getProjectsUseCase,
  }) : super(CapacityPlannerInitial()) {
    on<LoadCapacityPlans>(_onLoadCapacityPlans);
    on<CreateCapacityPlan>(_onCreateCapacityPlan);
  }

  Future<void> _onLoadCapacityPlans(
    LoadCapacityPlans event,
    Emitter<CapacityPlannerState> emit,
  ) async {
    final currentState = state;
    List<dynamic>? metadata;
    
    // Only show loading if we don't have existing plans
    if (currentState is! CapacityPlannerLoaded) {
      emit(CapacityPlannerLoading());
    }

    try {
      // Fetch plans and metadata in parallel
      final results = await Future.wait([
        getCapacityPlansUseCase(startDate: event.startDate, endDate: event.endDate),
        getAllUsersUseCase(),
        getProjectsUseCase(),
      ]);

      emit(CapacityPlannerLoaded(
        plans: results[0] as List<CapacityPlanEntity>,
        users: results[1] as List<UserEntity>,
        projects: results[2] as List<ProjectEntity>,
        startDate: event.startDate,
        endDate: event.endDate,
      ));
    } catch (e) {
      emit(CapacityPlannerError(e.toString()));
    }
  }

  Future<void> _onCreateCapacityPlan(
    CreateCapacityPlan event,
    Emitter<CapacityPlannerState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CapacityPlannerLoaded) return;

    try {
      await createCapacityPlanUseCase(
        userId: event.userId,
        projectId: event.projectId,
        startDate: event.startDate,
        endDate: event.endDate,
        isOngoing: event.isOngoing,
        hoursPerDay: event.hoursPerDay,
      );
      
      // Reload plans after successful creation
      add(LoadCapacityPlans(
        startDate: currentState.startDate,
        endDate: currentState.endDate,
      ));
    } catch (e) {
      emit(CapacityPlannerError(e.toString()));
    }
  }
}
