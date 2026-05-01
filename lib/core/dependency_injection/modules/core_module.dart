import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/core/config/local_db_method.dart';
import 'package:core/core/local_db/local_db_memory_datasource.dart';
import 'package:core/core/local_db/local_db_repository.dart';
import 'package:core/core/local_db/local_db_repository_impl.dart';
import 'package:core/core/network/api_service.dart';
import 'package:core/core/offline_sync/offline_api_sync_service.dart';
import 'package:core/core/network/network_checker.dart';
import 'package:core/core/services/share_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:core/core/theme/theme_cubit.dart';
import 'package:core/features/workmanager/service/workmanager_service.dart';

void registerCoreModule(GetIt sl) {
  if (!sl.isRegistered<ThemeCubit>()) {
    sl.registerLazySingleton(() => ThemeCubit());
  }
  if (!sl.isRegistered<Placeholder>()) {
    sl.registerLazySingleton<Placeholder>(() => const Placeholder());
  }
  if (!sl.isRegistered<ShareService>()) {
    sl.registerLazySingleton(() => ShareService());
  }
  if (!sl.isRegistered<WorkmanagerService>()) {
    sl.registerLazySingleton(() => WorkmanagerService());
  }
  if (!sl.isRegistered<Connectivity>()) {
    sl.registerLazySingleton(() => Connectivity());
  }
  if (!sl.isRegistered<OfflineApiSyncService>()) {
    sl.registerLazySingleton(() => OfflineApiSyncService(sl<Connectivity>()));
    sl<OfflineApiSyncService>().init();
  }
  if (!sl.isRegistered<NetworkChecker>()) {
    sl.registerLazySingleton(() => NetworkChecker(sl<Connectivity>()));
    sl<NetworkChecker>().startListening();
  }
  if (!sl.isRegistered<ApiService>()) {
    sl.registerLazySingleton(() => ApiService(sl<OfflineApiSyncService>()));
  }
  if (!sl.isRegistered<LocalDbMemoryDatasource>()) {
    sl.registerLazySingleton(() => LocalDbMemoryDatasource());
  }
  if (!sl.isRegistered<LocalDbRepository>()) {
    sl.registerLazySingleton<LocalDbRepository>(
      () => LocalDbRepositoryImpl(
        datasource: sl<LocalDbMemoryDatasource>(),
        localDbMethod: kLocalDbMethod,
      ),
    );
  }
}

