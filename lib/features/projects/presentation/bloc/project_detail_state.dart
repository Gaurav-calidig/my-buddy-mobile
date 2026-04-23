import 'package:equatable/equatable.dart';
import 'package:core/features/projects/domain/entities/project_asset_entity.dart';
import 'package:core/features/projects/domain/entities/project_member_entity.dart';
import 'package:core/features/projects/domain/entities/tech_stack_entity.dart';
import 'package:core/features/auth/domain/entities/user_entity.dart';

abstract class ProjectDetailState extends Equatable {
  const ProjectDetailState();
  @override
  List<Object?> get props => [];
}

class ProjectDetailInitial extends ProjectDetailState {}

class ProjectDetailLoading extends ProjectDetailState {}

class ProjectDetailLoaded extends ProjectDetailState {
  final List<ProjectAssetEntity> assets;
  final List<ProjectAssetEntity> deletedAssets;
  final List<ProjectMemberEntity> members;
  final List<ProjectTechStackEntity> techStacks;
  final List<UserEntity> users;
  final List<TechStackEntity> allTechStacks;
  final String? currentUserId;

  const ProjectDetailLoaded({
    required this.assets,
    required this.deletedAssets,
    required this.members,
    required this.techStacks,
    this.users = const [],
    this.allTechStacks = const [],
    this.currentUserId,
  });

  ProjectDetailLoaded copyWith({
    List<ProjectAssetEntity>? assets,
    List<ProjectAssetEntity>? deletedAssets,
    List<ProjectMemberEntity>? members,
    List<ProjectTechStackEntity>? techStacks,
    List<UserEntity>? users,
    List<TechStackEntity>? allTechStacks,
    String? currentUserId,
  }) {
    return ProjectDetailLoaded(
      assets: assets ?? this.assets,
      deletedAssets: deletedAssets ?? this.deletedAssets,
      members: members ?? this.members,
      techStacks: techStacks ?? this.techStacks,
      users: users ?? this.users,
      allTechStacks: allTechStacks ?? this.allTechStacks,
      currentUserId: currentUserId ?? this.currentUserId,
    );
  }

  @override
  List<Object?> get props =>
      [assets, deletedAssets, members, techStacks, users, allTechStacks, currentUserId];
}

class ProjectDetailError extends ProjectDetailState {
  final String message;
  const ProjectDetailError(this.message);
  @override
  List<Object?> get props => [message];
}
