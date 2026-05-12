import 'package:core/features/capacity_planner/data/datasources/capacity_planner_remote_data_source.dart';
import 'package:core/features/capacity_planner/data/repositories/capacity_planner_repository_impl.dart';
import 'package:core/features/capacity_planner/domain/repositories/capacity_planner_repository.dart';
import 'package:core/features/capacity_planner/domain/usecases/get_capacity_plans_usecase.dart';
import 'package:core/features/capacity_planner/domain/usecases/create_capacity_plan_usecase.dart';
import 'package:core/features/capacity_planner/presentation/bloc/capacity_planner_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

void registerCapacityPlannerModule(GetIt sl) {
  // Data Sources
  sl.registerLazySingleton<CapacityPlannerRemoteDataSource>(
    () => CapacityPlannerRemoteDataSourceImpl(apiService: sl(), logger: Logger()),
  );

  // Repositories
  sl.registerLazySingleton<CapacityPlannerRepository>(
    () => CapacityPlannerRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetCapacityPlansUseCase(sl()));
  sl.registerLazySingleton(() => CreateCapacityPlanUseCase(sl()));

  // Blocs
  sl.registerFactory(
    () => CapacityPlannerBloc(
      getCapacityPlansUseCase: sl(),
      createCapacityPlanUseCase: sl(),
      getAllUsersUseCase: sl(),
      getProjectsUseCase: sl(),
    ),
  );
}
