import 'package:core/features/projects/data/datasources/project_remote_data_source.dart';
import 'package:core/features/projects/data/repositories/project_repository_impl.dart';
import 'package:core/features/projects/domain/repositories/project_repository.dart';
import 'package:core/features/projects/domain/usecases/get_projects_usecase.dart';
import 'package:core/features/projects/domain/usecases/project_detail_usecases.dart';
import 'package:core/features/projects/presentation/bloc/project_bloc.dart';
import 'package:core/features/projects/presentation/bloc/project_detail_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:logger/logger.dart';

void registerProjectModule(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<ProjectRemoteDataSource>(
    () => ProjectRemoteDataSourceImpl(apiService: sl(), logger: Logger()),
  );

  // Repositories
  sl.registerLazySingleton<ProjectRepository>(
    () => ProjectRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetProjectsUseCase(sl()));
  sl.registerLazySingleton(() => CreateProjectUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProjectUseCase(sl()));
  sl.registerLazySingleton(() => GetProjectAssetsUseCase(sl()));
  sl.registerLazySingleton(() => GetDeletedProjectAssetsUseCase(sl()));
  sl.registerLazySingleton(() => GetProjectMembersUseCase(sl()));
  sl.registerLazySingleton(() => GetProjectTechStacksUseCase(sl()));
  sl.registerLazySingleton(() => CreateProjectAssetUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProjectAssetUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProjectAssetUseCase(sl()));
  sl.registerLazySingleton(() => RestoreProjectAssetUseCase(sl()));
  sl.registerLazySingleton(() => AddProjectMemberUseCase(sl()));
  sl.registerLazySingleton(() => GetAllUsersUseCase(sl()));
  sl.registerLazySingleton(() => GetAllTechStacksUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProjectTechStacksUseCase(sl()));

  // Blocs
  sl.registerFactory(
    () => ProjectBloc(
      getProjectsUseCase: sl(),
      createProjectUseCase: sl(),
      updateProjectUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => ProjectDetailBloc(
      getProjectAssetsUseCase: sl(),
      getDeletedProjectAssetsUseCase: sl(),
      getProjectMembersUseCase: sl(),
      getProjectTechStacksUseCase: sl(),
      createProjectAssetUseCase: sl(),
      updateProjectAssetUseCase: sl(),
      deleteProjectAssetUseCase: sl(),
      restoreProjectAssetUseCase: sl(),
      addProjectMemberUseCase: sl(),
      getAllUsersUseCase: sl(),
      getAllTechStacksUseCase: sl(),
      updateProjectTechStacksUseCase: sl(),
    ),
  );
}

