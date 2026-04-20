import 'package:get_it/get_it.dart';

import 'package:core/features/chat/chat_backend.dart';
import 'package:core/features/chat/data/chat_repository_impl.dart';
import 'package:core/features/chat/data/chat_repository_switcher.dart';
import 'package:core/features/chat/data/chat_websocket_repository_impl.dart';
import 'package:core/features/chat/data/chat_media_repository_impl.dart';
import 'package:core/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:core/features/chat/data/datasources/chat_websocket_client.dart';
import 'package:core/features/chat/data/datasources/chat_websocket_remote_datasource.dart';
import 'package:core/features/chat/domain/repositories/chat_media_repository.dart';
import 'package:core/features/chat/domain/repositories/chat_repository.dart';
import 'package:core/features/chat/domain/usecases/create_chat_room_usecase.dart';
import 'package:core/features/chat/domain/usecases/clear_chat_room_for_me_usecase.dart';
import 'package:core/features/chat/domain/usecases/delete_chat_message_for_everyone_usecase.dart';
import 'package:core/features/chat/domain/usecases/delete_chat_message_for_me_usecase.dart';
import 'package:core/features/chat/domain/usecases/edit_chat_message_usecase.dart';
import 'package:core/features/chat/domain/usecases/ensure_chat_user_usecase.dart';
import 'package:core/features/chat/domain/usecases/get_chat_current_user_usecase.dart';
import 'package:core/features/chat/domain/usecases/load_older_chat_messages_usecase.dart';
import 'package:core/features/chat/domain/usecases/send_chat_message_usecase.dart';
import 'package:core/features/chat/domain/usecases/mark_chat_message_delivered_usecase.dart';
import 'package:core/features/chat/domain/usecases/mark_chat_message_read_usecase.dart';
import 'package:core/features/chat/domain/usecases/resolve_chat_user_identifier_usecase.dart';
import 'package:core/features/chat/domain/usecases/set_chat_presence_usecase.dart';
import 'package:core/features/chat/domain/usecases/set_chat_typing_usecase.dart';
import 'package:core/features/chat/domain/usecases/update_chat_room_members_usecase.dart';
import 'package:core/features/chat/domain/usecases/update_chat_display_name_usecase.dart';
import 'package:core/features/chat/domain/usecases/watch_chat_messages_usecase.dart';
import 'package:core/features/chat/domain/usecases/watch_chat_presence_usecase.dart';
import 'package:core/features/chat/domain/usecases/watch_chat_room_states_usecase.dart';
import 'package:core/features/chat/domain/usecases/watch_chat_rooms_usecase.dart';
import 'package:core/features/chat/domain/usecases/watch_chat_typing_usecase.dart';
import 'package:core/features/chat/domain/usecases/toggle_chat_reaction_usecase.dart';
import 'package:core/features/chat/domain/usecases/set_chat_message_pinned_usecase.dart';
import 'package:core/features/chat/domain/usecases/upload_chat_attachment_usecase.dart';
import 'package:core/features/chat/presentation/bloc/chat_room_cubit.dart';
import 'package:core/features/chat/presentation/bloc/chat_rooms_cubit.dart';

void registerChatModule(GetIt sl) {
  if (!sl.isRegistered<ChatRemoteDatasource>()) {
    sl.registerLazySingleton<ChatRemoteDatasource>(
      () => ChatRemoteDatasource(firestore: sl(), firebaseAuth: sl()),
    );
  }
  if (!sl.isRegistered<ChatRepositoryImpl>()) {
    sl.registerLazySingleton<ChatRepositoryImpl>(
      () => ChatRepositoryImpl(datasource: sl()),
    );
  }
  if (!sl.isRegistered<ChatWebSocketClient>()) {
    sl.registerLazySingleton<ChatWebSocketClient>(
      () => ChatWebSocketClient(url: ChatBackendConfig.websocketUrl),
    );
  }
  if (!sl.isRegistered<ChatWebSocketRemoteDatasource>()) {
    sl.registerLazySingleton<ChatWebSocketRemoteDatasource>(
      () => ChatWebSocketRemoteDatasource(
        client: sl(),
        firebaseAuth: sl(),
        firestore: sl(),
      ),
    );
  }
  if (!sl.isRegistered<ChatWebSocketRepositoryImpl>()) {
    sl.registerLazySingleton<ChatWebSocketRepositoryImpl>(
      () => ChatWebSocketRepositoryImpl(datasource: sl()),
    );
  }
  if (!sl.isRegistered<ChatRepository>()) {
    sl.registerLazySingleton<ChatRepository>(
      () => ChatRepositorySwitcher(
        firebase: sl<ChatRepositoryImpl>(),
        websocket: sl<ChatWebSocketRepositoryImpl>(),
        backendListenable: ChatBackendConfig.backend,
      ),
    );
  }
  if (!sl.isRegistered<ChatMediaRepository>()) {
    sl.registerLazySingleton<ChatMediaRepository>(
      () => ChatMediaRepositoryImpl(storage: sl()),
    );
  }
  if (!sl.isRegistered<WatchChatRoomsUseCase>()) {
    sl.registerLazySingleton(() => WatchChatRoomsUseCase(sl()));
  }
  if (!sl.isRegistered<WatchChatMessagesUseCase>()) {
    sl.registerLazySingleton(() => WatchChatMessagesUseCase(sl()));
  }
  if (!sl.isRegistered<WatchChatRoomStatesUseCase>()) {
    sl.registerLazySingleton(() => WatchChatRoomStatesUseCase(sl()));
  }
  if (!sl.isRegistered<WatchChatPresenceUseCase>()) {
    sl.registerLazySingleton(() => WatchChatPresenceUseCase(sl()));
  }
  if (!sl.isRegistered<WatchChatTypingUseCase>()) {
    sl.registerLazySingleton(() => WatchChatTypingUseCase(sl()));
  }
  if (!sl.isRegistered<SendChatMessageUseCase>()) {
    sl.registerLazySingleton(() => SendChatMessageUseCase(sl()));
  }
  if (!sl.isRegistered<CreateChatRoomUseCase>()) {
    sl.registerLazySingleton(() => CreateChatRoomUseCase(sl()));
  }
  if (!sl.isRegistered<ClearChatRoomForMeUseCase>()) {
    sl.registerLazySingleton(() => ClearChatRoomForMeUseCase(sl()));
  }
  if (!sl.isRegistered<EnsureChatUserUseCase>()) {
    sl.registerLazySingleton(() => EnsureChatUserUseCase(sl()));
  }
  if (!sl.isRegistered<GetChatCurrentUserUseCase>()) {
    sl.registerLazySingleton(() => GetChatCurrentUserUseCase(sl()));
  }
  if (!sl.isRegistered<ResolveChatUserIdentifierUseCase>()) {
    sl.registerLazySingleton(() => ResolveChatUserIdentifierUseCase(sl()));
  }
  if (!sl.isRegistered<UpdateChatDisplayNameUseCase>()) {
    sl.registerLazySingleton(() => UpdateChatDisplayNameUseCase(sl()));
  }
  if (!sl.isRegistered<SetChatPresenceUseCase>()) {
    sl.registerLazySingleton(() => SetChatPresenceUseCase(sl()));
  }
  if (!sl.isRegistered<SetChatTypingUseCase>()) {
    sl.registerLazySingleton(() => SetChatTypingUseCase(sl()));
  }
  if (!sl.isRegistered<EditChatMessageUseCase>()) {
    sl.registerLazySingleton(() => EditChatMessageUseCase(sl()));
  }
  if (!sl.isRegistered<DeleteChatMessageForEveryoneUseCase>()) {
    sl.registerLazySingleton(() => DeleteChatMessageForEveryoneUseCase(sl()));
  }
  if (!sl.isRegistered<DeleteChatMessageForMeUseCase>()) {
    sl.registerLazySingleton(() => DeleteChatMessageForMeUseCase(sl()));
  }
  if (!sl.isRegistered<UploadChatAttachmentUseCase>()) {
    sl.registerLazySingleton(() => UploadChatAttachmentUseCase(sl()));
  }
  if (!sl.isRegistered<LoadOlderChatMessagesUseCase>()) {
    sl.registerLazySingleton(() => LoadOlderChatMessagesUseCase(sl()));
  }
  if (!sl.isRegistered<UpdateChatRoomMembersUseCase>()) {
    sl.registerLazySingleton(() => UpdateChatRoomMembersUseCase(sl()));
  }
  if (!sl.isRegistered<MarkChatMessageDeliveredUseCase>()) {
    sl.registerLazySingleton(() => MarkChatMessageDeliveredUseCase(sl()));
  }
  if (!sl.isRegistered<MarkChatMessageReadUseCase>()) {
    sl.registerLazySingleton(() => MarkChatMessageReadUseCase(sl()));
  }
  if (!sl.isRegistered<ToggleChatReactionUseCase>()) {
    sl.registerLazySingleton(() => ToggleChatReactionUseCase(sl()));
  }
  if (!sl.isRegistered<SetChatMessagePinnedUseCase>()) {
    sl.registerLazySingleton(() => SetChatMessagePinnedUseCase(sl()));
  }
  if (!sl.isRegistered<ChatRoomsCubit>()) {
    sl.registerFactory(
      () => ChatRoomsCubit(
        watchChatRoomsUseCase: sl(),
        watchChatRoomStatesUseCase: sl(),
        createChatRoomUseCase: sl(),
        clearChatRoomForMeUseCase: sl(),
        ensureChatUserUseCase: sl(),
        resolveChatUserIdentifierUseCase: sl(),
        updateChatDisplayNameUseCase: sl(),
      ),
    );
  }
  if (!sl.isRegistered<ChatRoomCubit>()) {
    sl.registerFactoryParam<ChatRoomCubit, String, void>(
      (roomId, _) => ChatRoomCubit(
        roomId: roomId,
        watchChatMessagesUseCase: sl(),
        watchChatRoomStatesUseCase: sl(),
        sendChatMessageUseCase: sl(),
        ensureChatUserUseCase: sl(),
        watchChatPresenceUseCase: sl(),
        watchChatTypingUseCase: sl(),
        setChatPresenceUseCase: sl(),
        setChatTypingUseCase: sl(),
        uploadChatAttachmentUseCase: sl(),
        editChatMessageUseCase: sl(),
        deleteChatMessageForEveryoneUseCase: sl(),
        deleteChatMessageForMeUseCase: sl(),
        getChatCurrentUserUseCase: sl(),
        loadOlderChatMessagesUseCase: sl(),
        markChatMessageDeliveredUseCase: sl(),
        markChatMessageReadUseCase: sl(),
        updateChatRoomMembersUseCase: sl(),
        toggleChatReactionUseCase: sl(),
        setChatMessagePinnedUseCase: sl(),
        watchChatRoomsUseCase: sl(),
      ),
    );
  }
}
