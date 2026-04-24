import 'package:core/features/taskhub/data/datasources/task_hub_remote_data_source.dart';
import 'package:core/features/taskhub/data/task_hub_repository_impl.dart';
import 'package:core/features/taskhub/domain/repositories/task_hub_repository.dart';
import 'package:core/features/taskhub/domain/usecases/create_attachment_metadata_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/create_attachment_upload_url_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/create_comment_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/create_link_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/create_task_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/delete_attachment_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/delete_task_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/get_attachments_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/get_board_columns_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/get_comments_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/get_links_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/get_project_assignees_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/get_tasks_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/update_task_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/upload_to_presigned_url_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/reorder_board_columns_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/create_board_column_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/delete_board_column_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/move_task_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/delete_link_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/sprint_usecases.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

void registerTaskHubModule(GetIt sl) {
  // Data sources
  if (!sl.isRegistered<TaskHubRemoteDataSource>()) {
    sl.registerLazySingleton<TaskHubRemoteDataSource>(
      () => TaskHubRemoteDataSourceImpl(apiService: sl(), logger: Logger()),
    );
  }

  // Repositories
  if (!sl.isRegistered<TaskHubRepository>()) {
    sl.registerLazySingleton<TaskHubRepository>(
      () => TaskHubRepositoryImpl(remoteDataSource: sl()),
    );
  }

  // Use cases
  sl.registerLazySingleton(() => GetBoardColumnsUseCase(sl()));
  sl.registerLazySingleton(() => GetTasksUseCase(sl()));
  sl.registerLazySingleton(() => GetProjectAssigneesUseCase(sl()));
  sl.registerLazySingleton(() => CreateTaskUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTaskUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTaskUseCase(sl()));
  sl.registerLazySingleton(() => GetCommentsUseCase(sl()));
  sl.registerLazySingleton(() => CreateCommentUseCase(sl()));
  sl.registerLazySingleton(() => GetAttachmentsUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAttachmentUseCase(sl()));
  sl.registerLazySingleton(() => CreateAttachmentUploadUrlUseCase(sl()));
  sl.registerLazySingleton(() => UploadToPresignedUrlUseCase(sl()));
  sl.registerLazySingleton(() => CreateAttachmentMetadataUseCase(sl()));
  sl.registerLazySingleton(() => GetLinksUseCase(sl()));
  sl.registerLazySingleton(() => CreateLinkUseCase(sl()));
  sl.registerLazySingleton(() => ReorderBoardColumnsUseCase(sl()));
  sl.registerLazySingleton(() => CreateBoardColumnUseCase(sl()));
  sl.registerLazySingleton(() => DeleteBoardColumnUseCase(sl()));
  sl.registerLazySingleton(() => MoveTaskUseCase(sl()));
  sl.registerLazySingleton(() => DeleteLinkUseCase(sl()));
  sl.registerLazySingleton(() => GetSprintsUseCase(sl()));
  sl.registerLazySingleton(() => CreateSprintUseCase(sl()));
  sl.registerLazySingleton(() => UpdateSprintUseCase(sl()));
  sl.registerLazySingleton(() => DeleteSprintUseCase(sl()));
}

