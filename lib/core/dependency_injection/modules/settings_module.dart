import 'package:core/core/network/api_service.dart';
import 'package:core/features/settings/data/repositories/user_tag_repository_impl.dart';
import 'package:core/features/settings/domain/repositories/user_tag_repository.dart';
import 'package:core/features/settings/presentation/bloc/user_tag_bloc.dart';
import 'package:get_it/get_it.dart';

void registerSettingsModule(GetIt sl) {
  // Repository
  sl.registerLazySingleton<UserTagRepository>(
    () => UserTagRepositoryImpl(sl<ApiService>()),
  );

  // BLoC
  sl.registerFactory(() => UserTagBloc(sl<UserTagRepository>()));
}
