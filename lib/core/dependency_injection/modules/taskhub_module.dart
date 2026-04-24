import 'package:core/features/taskhub/data/datasources/task_hub_remote_data_source.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

void registerTaskHubModule(GetIt sl) {
  if (!sl.isRegistered<TaskHubRemoteDataSource>()) {
    sl.registerLazySingleton<TaskHubRemoteDataSource>(
      () => TaskHubRemoteDataSourceImpl(apiService: sl(), logger: Logger()),
    );
  }
}

