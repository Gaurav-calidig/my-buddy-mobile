import 'package:core/core/network/result.dart';
import 'package:core/features/projects/domain/entities/project_entity.dart';
import 'package:core/features/settings/domain/entities/user_project_tag_entity.dart';
import 'package:core/features/settings/domain/entities/user_tag_entity.dart';
import 'package:core/features/settings/domain/repositories/user_tag_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class UserTagEvent extends Equatable {
  const UserTagEvent();
  @override
  List<Object?> get props => [];
}

class UserTagLoadRequested extends UserTagEvent {}

class UserTagCreateRequested extends UserTagEvent {
  final String name;
  final String color;
  const UserTagCreateRequested({required this.name, required this.color});
  @override
  List<Object?> get props => [name, color];
}

class UserTagUpdateProjectsRequested extends UserTagEvent {
  final int tagId;
  final List<int> projectIds;
  const UserTagUpdateProjectsRequested({required this.tagId, required this.projectIds});
  @override
  List<Object?> get props => [tagId, projectIds];
}

class UserTagUpdateRequested extends UserTagEvent {
  final int id;
  final String name;
  final String color;
  const UserTagUpdateRequested({required this.id, required this.name, required this.color});
  @override
  List<Object?> get props => [id, name, color];
}

class UserTagDeleteRequested extends UserTagEvent {
  final int id;
  const UserTagDeleteRequested(this.id);
  @override
  List<Object?> get props => [id];
}

// State
class UserTagState extends Equatable {
  final bool isTagsLoading;
  final bool isCreatingTag;
  final bool isUpdatingTag;
  final int? updatingTagId;
  final List<UserTagEntity> tags;
  final List<UserProjectTagEntity> projectTags;
  final String? errorMessage;

  const UserTagState({
    this.isTagsLoading = false,
    this.isCreatingTag = false,
    this.isUpdatingTag = false,
    this.updatingTagId,
    this.tags = const [],
    this.projectTags = const [],
    this.errorMessage,
  });

  UserTagState copyWith({
    bool? isTagsLoading,
    bool? isCreatingTag,
    bool? isUpdatingTag,
    int? updatingTagId,
    bool clearUpdatingTagId = false,
    List<UserTagEntity>? tags,
    List<UserProjectTagEntity>? projectTags,
    String? errorMessage,
  }) {
    return UserTagState(
      isTagsLoading: isTagsLoading ?? this.isTagsLoading,
      isCreatingTag: isCreatingTag ?? this.isCreatingTag,
      isUpdatingTag: isUpdatingTag ?? this.isUpdatingTag,
      updatingTagId: clearUpdatingTagId ? null : (updatingTagId ?? this.updatingTagId),
      tags: tags ?? this.tags,
      projectTags: projectTags ?? this.projectTags,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isTagsLoading, isCreatingTag, isUpdatingTag, updatingTagId, tags, projectTags, errorMessage];
}

// BLoC
class UserTagBloc extends Bloc<UserTagEvent, UserTagState> {
  final UserTagRepository _repository;

  UserTagBloc(this._repository) : super(const UserTagState()) {
    on<UserTagLoadRequested>(_onLoadRequested);
    on<UserTagCreateRequested>(_onCreateRequested);
    on<UserTagUpdateRequested>(_onUpdateRequested);
    on<UserTagDeleteRequested>(_onDeleteRequested);
    on<UserTagUpdateProjectsRequested>(_onUpdateProjectsRequested);
  }

  Future<void> _onLoadRequested(UserTagLoadRequested event, Emitter<UserTagState> emit) async {
    emit(state.copyWith(isTagsLoading: true));
    
    final results = await Future.wait([
      _repository.getUserTags(),
      _repository.getUserProjectTags(),
    ]);

    final tagsRes = results[0] as Result<List<UserTagEntity>>;
    final projectTagsRes = results[1] as Result<List<UserProjectTagEntity>>;

    tagsRes.fold(
      (tags) {
        projectTagsRes.fold(
          (projectTags) => emit(state.copyWith(
            isTagsLoading: false,
            tags: tags,
            projectTags: projectTags,
            clearUpdatingTagId: true,
          )),
          (error) => emit(state.copyWith(isTagsLoading: false, errorMessage: error, clearUpdatingTagId: true)),
        );
      },
      (error) => emit(state.copyWith(isTagsLoading: false, errorMessage: error, clearUpdatingTagId: true)),
    );
  }

  Future<void> _onCreateRequested(UserTagCreateRequested event, Emitter<UserTagState> emit) async {
    emit(state.copyWith(isCreatingTag: true));
    final result = await _repository.createUserTag(name: event.name, color: event.color);
    await result.fold(
      (data) async {
        emit(state.copyWith(isCreatingTag: false));
        add(UserTagLoadRequested());
      },
      (error) async {
        emit(state.copyWith(isCreatingTag: false, errorMessage: error));
      },
    );
  }

  Future<void> _onUpdateRequested(UserTagUpdateRequested event, Emitter<UserTagState> emit) async {
    emit(state.copyWith(isUpdatingTag: true));
    final result = await _repository.updateUserTag(id: event.id, name: event.name, color: event.color);
    result.fold(
      (data) {
        emit(state.copyWith(isUpdatingTag: false));
        add(UserTagLoadRequested());
      },
      (error) => emit(state.copyWith(isUpdatingTag: false, errorMessage: error)),
    );
  }

  Future<void> _onDeleteRequested(UserTagDeleteRequested event, Emitter<UserTagState> emit) async {
    emit(state.copyWith(isTagsLoading: true));
    final result = await _repository.deleteUserTag(event.id);
    result.fold(
      (_) => add(UserTagLoadRequested()),
      (error) => emit(state.copyWith(isTagsLoading: false, errorMessage: error)),
    );
  }

  Future<void> _onUpdateProjectsRequested(UserTagUpdateProjectsRequested event, Emitter<UserTagState> emit) async {
    emit(state.copyWith(updatingTagId: event.tagId));
    final result = await _repository.updateTagProjects(tagId: event.tagId, projectIds: event.projectIds);
    result.fold(
      (_) => add(UserTagLoadRequested()),
      (error) => emit(state.copyWith(errorMessage: error, clearUpdatingTagId: true)),
    );
  }
}
