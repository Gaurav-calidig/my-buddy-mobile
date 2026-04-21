import 'package:core/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:core/features/dashboard/data/dashboard_repository_impl.dart';
import 'package:core/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:core/features/dashboard/domain/usecases/get_dashboard_ams_leave_overview_usecase.dart';
import 'package:core/features/dashboard/domain/usecases/get_dashboard_highlights_usecase.dart';
import 'package:core/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:get_it/get_it.dart';

void registerDashboardModule(GetIt sl) {
  if (!sl.isRegistered<DashboardRemoteDatasource>()) {
    sl.registerLazySingleton<DashboardRemoteDatasource>(
      () => DashboardRemoteDatasource(apiService: sl()),
    );
  }

  if (!sl.isRegistered<DashboardRepository>()) {
    sl.registerLazySingleton<DashboardRepository>(
      () => DashboardRepositoryImpl(datasource: sl()),
    );
  }

  if (!sl.isRegistered<GetDashboardHighlightsUseCase>()) {
    sl.registerLazySingleton(
      () => GetDashboardHighlightsUseCase(sl<DashboardRepository>()),
    );
  }

  if (!sl.isRegistered<GetDashboardAmsLeaveOverviewUseCase>()) {
    sl.registerLazySingleton(
      () => GetDashboardAmsLeaveOverviewUseCase(sl<DashboardRepository>()),
    );
  }

  if (!sl.isRegistered<DashboardCubit>()) {
    sl.registerFactory(
      () => DashboardCubit(
        getDashboardHighlightsUseCase: sl(),
        getDashboardAmsLeaveOverviewUseCase: sl(),
      ),
    );
  }
}
