import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/chat_room_entity.dart';
import '../../domain/entities/chat_room_state_entity.dart';
import '../../domain/usecases/clear_chat_room_for_me_usecase.dart';
import '../../domain/usecases/create_chat_room_usecase.dart';
import '../../domain/usecases/ensure_chat_user_usecase.dart';
import '../../domain/usecases/resolve_chat_user_identifier_usecase.dart';
import '../../domain/usecases/update_chat_display_name_usecase.dart';
import '../../domain/usecases/watch_chat_room_states_usecase.dart';
import '../../domain/usecases/watch_chat_rooms_usecase.dart';
import 'chat_rooms_state.dart';

class ChatRoomsCubit extends Cubit<ChatRoomsState> {
  final WatchChatRoomsUseCase watchChatRoomsUseCase;
  final WatchChatRoomStatesUseCase watchChatRoomStatesUseCase;
  final CreateChatRoomUseCase createChatRoomUseCase;
  final ClearChatRoomForMeUseCase clearChatRoomForMeUseCase;
  final EnsureChatUserUseCase ensureChatUserUseCase;
  final ResolveChatUserIdentifierUseCase resolveChatUserIdentifierUseCase;
  final UpdateChatDisplayNameUseCase updateChatDisplayNameUseCase;

  StreamSubscription<List<ChatRoomEntity>>? _roomsSub;
  StreamSubscription<List<ChatRoomStateEntity>>? _roomStatesSub;
  List<ChatRoomEntity> _roomsCache = [];
  Map<String, DateTime?> _clearedAtByRoom = {};
  String _currentUserId = '';

  ChatRoomsCubit({
    required this.watchChatRoomsUseCase,
    required this.watchChatRoomStatesUseCase,
    required this.createChatRoomUseCase,
    required this.clearChatRoomForMeUseCase,
    required this.ensureChatUserUseCase,
    required this.resolveChatUserIdentifierUseCase,
    required this.updateChatDisplayNameUseCase,
  }) : super(ChatRoomsState.initial());

  Future<void> start() async {
    emit(state.copyWith(status: ChatRoomsStatus.loading, error: null));
    try {
      await ensureChatUserUseCase.call();
    } catch (e) {
      emit(state.copyWith(status: ChatRoomsStatus.error, error: e.toString()));
      return;
    }

    await _roomsSub?.cancel();
    _roomsSub = watchChatRoomsUseCase.call().listen(
      (rooms) {
        _roomsCache = rooms;
        _emitFilteredRooms();
      },
      onError: (error) {
        emit(
          state.copyWith(
            status: ChatRoomsStatus.error,
            error: error.toString(),
          ),
        );
      },
    );

    await _roomStatesSub?.cancel();
    _roomStatesSub = watchChatRoomStatesUseCase.call().listen(
      (roomStates) {
        _clearedAtByRoom = {
          for (final state in roomStates) state.roomId: state.clearedAt,
        };
        _emitFilteredRooms();
      },
      onError: (error) {
        emit(state.copyWith(error: error.toString()));
      },
    );
  }

  void _emitFilteredRooms() {
    final filteredRooms = _roomsCache.where((room) {
      if (!_isVisibleToCurrentUser(room)) {
        return false;
      }
      final clearedAt = _clearedAtByRoom[room.id];
      if (clearedAt == null || clearedAt.millisecondsSinceEpoch == 0) {
        return true;
      }
      if (room.updatedAt.millisecondsSinceEpoch == 0) {
        return true;
      }
      return room.updatedAt.isAfter(clearedAt);
    }).toList();

    emit(
      state.copyWith(
        status: ChatRoomsStatus.loaded,
        rooms: filteredRooms,
        error: null,
      ),
    );
  }

  bool _isVisibleToCurrentUser(ChatRoomEntity room) {
    if (_currentUserId.isEmpty) return true;
    if (room.memberIds.isEmpty && room.adminIds.isEmpty) return true;
    return room.isMember(_currentUserId);
  }

  Future<String?> createGroupRoom({
    required String name,
    required List<String> memberIds,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    try {
      final resolvedMembers = await _resolveMemberIdentifiers(memberIds);
      return await createChatRoomUseCase.execute(
        name: trimmed,
        type: ChatRoomType.group,
        memberIds: resolvedMembers,
        adminIds: [_currentUserId],
      );
    } catch (e) {
      emit(state.copyWith(status: ChatRoomsStatus.error, error: e.toString()));
      return null;
    }
  }

  Future<String?> createDirectRoom(String participantId) async {
    final trimmed = participantId.trim();
    if (trimmed.isEmpty || _currentUserId.isEmpty) {
      return null;
    }
    try {
      final resolvedParticipantId = await resolveChatUserIdentifierUseCase
          .execute(trimmed);
      if (resolvedParticipantId == _currentUserId) {
        throw Exception('Choose another user to start a direct chat.');
      }
      final roomKey = _directRoomKey(_currentUserId, resolvedParticipantId);
      return await createChatRoomUseCase.execute(
        name: 'Chat with $trimmed',
        type: ChatRoomType.direct,
        memberIds: [_currentUserId, resolvedParticipantId],
        adminIds: [_currentUserId],
        roomKey: roomKey,
      );
    } catch (e) {
      emit(state.copyWith(status: ChatRoomsStatus.error, error: e.toString()));
      return null;
    }
  }

  String _directRoomKey(String first, String second) {
    final ids = [first, second]..sort();
    return ids.join('__');
  }

  Future<List<String>> _resolveMemberIdentifiers(
    List<String> identifiers,
  ) async {
    final resolved = <String>{};
    for (final identifier in identifiers) {
      final trimmed = identifier.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      final resolvedId = await resolveChatUserIdentifierUseCase.execute(
        trimmed,
      );
      resolved.add(resolvedId);
    }
    return resolved.toList(growable: false);
  }

  Future<void> updateDisplayName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return;
    }
    try {
      await updateChatDisplayNameUseCase.call(trimmed);
    } catch (e) {
      emit(state.copyWith(status: ChatRoomsStatus.error, error: e.toString()));
    }
  }

  Future<void> clearRoomForMe(String roomId) async {
    try {
      await clearChatRoomForMeUseCase.call(roomId: roomId);
      _clearedAtByRoom[roomId] = DateTime.now();
      _emitFilteredRooms();
    } catch (e) {
      emit(state.copyWith(status: ChatRoomsStatus.error, error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _roomsSub?.cancel();
    _roomStatesSub?.cancel();
    return super.close();
  }
}

