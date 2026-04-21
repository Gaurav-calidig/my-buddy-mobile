import 'package:equatable/equatable.dart';
import 'package:core/features/projects/domain/entities/project_asset_entity.dart';
import 'package:core/features/projects/domain/entities/project_member_entity.dart';
import 'package:core/features/projects/domain/entities/tech_stack_entity.dart';

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

  const ProjectDetailLoaded({
    required this.assets,
    required this.deletedAssets,
    required this.members,
    required this.techStacks,
  });

  @override
  List<Object?> get props => [assets, deletedAssets, members, techStacks];
}

class ProjectDetailError extends ProjectDetailState {
  final String message;
  const ProjectDetailError(this.message);
  @override
  List<Object?> get props => [message];
}
