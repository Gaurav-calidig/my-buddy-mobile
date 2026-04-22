import 'package:core/features/dsr/data/datasources/dsr_remote_datasource.dart';
import 'package:core/features/dsr/data/dsr_repository_impl.dart';
import 'package:core/features/dsr/domain/repositories/dsr_repository.dart';
import 'package:core/features/dsr/domain/usecases/create_dsr_usecase.dart';
import 'package:core/features/dsr/domain/usecases/get_dsr_by_date_usecase.dart';
import 'package:core/features/dsr/domain/usecases/get_dsr_projects_usecase.dart';
import 'package:core/features/dsr/domain/usecases/get_my_dsr_usecase.dart';
import 'package:core/features/dsr/presentation/bloc/dsr_bloc.dart';
import 'package:get_it/get_it.dart';

void registerDsrModule(GetIt sl) {
  if (!sl.isRegistered<DsrRemoteDatasource>()) {
    sl.registerLazySingleton<DsrRemoteDatasource>(
      () => DsrRemoteDatasourceImpl(apiService: sl()),
    );
  }

  if (!sl.isRegistered<DsrRepository>()) {
    sl.registerLazySingleton<DsrRepository>(
      () => DsrRepositoryImpl(datasource: sl()),
    );
  }

  if (!sl.isRegistered<GetDsrProjectsUseCase>()) {
    sl.registerLazySingleton(() => GetDsrProjectsUseCase(sl()));
  }

  if (!sl.isRegistered<GetDsrByDateUseCase>()) {
    sl.registerLazySingleton(() => GetDsrByDateUseCase(sl()));
  }

  if (!sl.isRegistered<GetMyDsrUseCase>()) {
    sl.registerLazySingleton(() => GetMyDsrUseCase(sl()));
  }

   if (!sl.isRegistered<CreateDsrUseCase>()) {
    sl.registerLazySingleton(() => CreateDsrUseCase(sl()));
  }

  if (!sl.isRegistered<DsrBloc>()) {
    sl.registerFactory(
      () => DsrBloc(
        getDsrProjectsUseCase: sl(),
        getDsrByDateUseCase: sl(),
        getMyDsrUseCase: sl(), 
        createDsrUseCase: sl(),
      ),
    );
  }
}

