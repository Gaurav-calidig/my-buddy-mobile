import 'package:core/features/attendance/data/attendance_repository_impl.dart';
import 'package:core/features/attendance/data/datasources/attendance_remote_datasource.dart';
import 'package:core/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:core/features/attendance/domain/usecases/get_attendance_leave_stats_usecase.dart';
import 'package:core/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:get_it/get_it.dart';

void registerAttendanceModule(GetIt sl) {
  if (!sl.isRegistered<AttendanceRemoteDatasource>()) {
    sl.registerLazySingleton<AttendanceRemoteDatasource>(
      () => AttendanceRemoteDatasource(apiService: sl()),
    );
  }

  if (!sl.isRegistered<AttendanceRepository>()) {
    sl.registerLazySingleton<AttendanceRepository>(
      () => AttendanceRepositoryImpl(datasource: sl()),
    );
  }

  if (!sl.isRegistered<GetAttendanceLeaveStatsUseCase>()) {
    sl.registerLazySingleton(
      () => GetAttendanceLeaveStatsUseCase(sl<AttendanceRepository>()),
    );
  }

  if (!sl.isRegistered<AttendanceBloc>()) {
    sl.registerFactory(
      () => AttendanceBloc(
        apiService: sl(),
        getAttendanceLeaveStatsUseCase: sl(),
      ),
    );
  }
}
