import 'package:core/features/projects/domain/entities/project_asset_entity.dart';
import 'package:core/features/projects/domain/entities/tech_stack_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/features/projects/domain/usecases/project_detail_usecases.dart';
import 'project_detail_event.dart';
import 'project_detail_state.dart';

class ProjectDetailBloc
    extends Bloc<ProjectDetailEvent, ProjectDetailState> {
  final GetProjectAssetsUseCase getProjectAssetsUseCase;
  final GetDeletedProjectAssetsUseCase getDeletedProjectAssetsUseCase;
  final GetProjectMembersUseCase getProjectMembersUseCase;
  final GetProjectTechStacksUseCase getProjectTechStacksUseCase;
  final CreateProjectAssetUseCase createProjectAssetUseCase;
  final UpdateProjectAssetUseCase updateProjectAssetUseCase;
  final DeleteProjectAssetUseCase deleteProjectAssetUseCase;
  final RestoreProjectAssetUseCase restoreProjectAssetUseCase;
  final GetAllUsersUseCase getAllUsersUseCase;
  final AddProjectMemberUseCase addProjectMemberUseCase;
  final GetAllTechStacksUseCase getAllTechStacksUseCase;
  final UpdateProjectTechStacksUseCase updateProjectTechStacksUseCase;
  final UpdateProjectMemberRoleUseCase updateProjectMemberRoleUseCase;
  final RemoveProjectMemberUseCase removeProjectMemberUseCase;

  ProjectDetailBloc({
    required this.getProjectAssetsUseCase,
    required this.getDeletedProjectAssetsUseCase,
    required this.getProjectMembersUseCase,
    required this.getProjectTechStacksUseCase,
    required this.createProjectAssetUseCase,
    required this.updateProjectAssetUseCase,
    required this.deleteProjectAssetUseCase,
    required this.restoreProjectAssetUseCase,
    required this.getAllUsersUseCase,
    required this.addProjectMemberUseCase,
    required this.getAllTechStacksUseCase,
    required this.updateProjectTechStacksUseCase,
    required this.updateProjectMemberRoleUseCase,
    required this.removeProjectMemberUseCase,
  }) : super(ProjectDetailInitial()) {
    on<FetchUsers>((event, emit) async {
      if (state is ProjectDetailLoaded) {
        try {
          final users = await getAllUsersUseCase();
          emit((state as ProjectDetailLoaded).copyWith(users: users));
        } catch (e) {
          // Non-fatal error for fetching users
        }
      }
    });

    on<AddProjectMember>((event, emit) async {
      try {
        await addProjectMemberUseCase(
          projectId: event.projectId,
          username: event.username,
          role: event.role,
        );
        final currentUserId = state is ProjectDetailLoaded
            ? (state as ProjectDetailLoaded).currentUserId
            : null;
        add(FetchProjectDetail(event.projectId, currentUserId: currentUserId));
      } catch (e) {
        emit(ProjectDetailError(e.toString()));
      }
    });

    on<UpdateProjectMemberRole>((event, emit) async {
      try {
        await updateProjectMemberRoleUseCase(
          projectId: event.projectId,
          userId: event.userId,
          role: event.role,
        );
        final currentUserId = state is ProjectDetailLoaded
            ? (state as ProjectDetailLoaded).currentUserId
            : null;
        add(FetchProjectDetail(event.projectId, currentUserId: currentUserId));
      } catch (e) {
        emit(ProjectDetailError(e.toString()));
      }
    });

    on<RemoveProjectMember>((event, emit) async {
      try {
        await removeProjectMemberUseCase(event.projectId, event.userId);
        final currentUserId = state is ProjectDetailLoaded
            ? (state as ProjectDetailLoaded).currentUserId
            : null;
        add(FetchProjectDetail(event.projectId, currentUserId: currentUserId));
      } catch (e) {
        emit(ProjectDetailError(e.toString()));
      }
    });

    on<AddProjectAsset>((event, emit) async {
      try {
        await createProjectAssetUseCase(
          projectId: event.projectId,
          name: event.name,
          type: event.type,
          environment: event.environment,
          value: event.value,
          allowedRoles: event.allowedRoles,
          allowedUserIds: event.allowedUserIds,
        );
        final currentUserId = state is ProjectDetailLoaded
            ? (state as ProjectDetailLoaded).currentUserId
            : null;
        add(FetchProjectDetail(event.projectId, currentUserId: currentUserId));
      } catch (e) {
        emit(ProjectDetailError(e.toString()));
      }
    });

    on<UpdateProjectAsset>((event, emit) async {
      try {
        await updateProjectAssetUseCase(
          projectId: event.projectId,
          assetId: event.assetId,
          name: event.name,
          type: event.type,
          environment: event.environment,
          value: event.value,
          allowedRoles: event.allowedRoles,
          allowedUserIds: event.allowedUserIds,
        );
        final currentUserId = state is ProjectDetailLoaded
            ? (state as ProjectDetailLoaded).currentUserId
            : null;
        add(FetchProjectDetail(event.projectId, currentUserId: currentUserId));
      } catch (e) {
        emit(ProjectDetailError(e.toString()));
      }
    });

    on<DeleteProjectAsset>((event, emit) async {
      try {
        await deleteProjectAssetUseCase(event.projectId, event.assetId);
        final currentUserId = state is ProjectDetailLoaded
            ? (state as ProjectDetailLoaded).currentUserId
            : null;
        add(FetchProjectDetail(event.projectId, currentUserId: currentUserId));
      } catch (e) {
        emit(ProjectDetailError(e.toString()));
      }
    });

    on<RestoreProjectAsset>((event, emit) async {
      try {
        await restoreProjectAssetUseCase(event.projectId, event.assetId);
        final currentUserId = state is ProjectDetailLoaded
            ? (state as ProjectDetailLoaded).currentUserId
            : null;
        add(FetchProjectDetail(event.projectId, currentUserId: currentUserId));
      } catch (e) {
        emit(ProjectDetailError(e.toString()));
      }
    });

    on<FetchProjectDetail>((event, emit) async {
      emit(ProjectDetailLoading());
      try {
        final members = await getProjectMembersUseCase(event.projectId);

        bool canSeeDeleted = false;
        if (event.currentUserId != null) {
          final currentUser = members
              .where((m) => m.userId == event.currentUserId)
              .firstOrNull;
          if (currentUser != null) {
            canSeeDeleted =
                currentUser.role == 'admin' ||
                currentUser.role == 'project_lead';
          }
        }

        final results = await Future.wait([
          getProjectAssetsUseCase(event.projectId),
          canSeeDeleted
              ? getDeletedProjectAssetsUseCase(event.projectId)
              : Future.value(<ProjectAssetEntity>[]),
          getProjectTechStacksUseCase(event.projectId),
          getAllTechStacksUseCase(),
        ]);

        emit(
          ProjectDetailLoaded(
            assets: results[0] as List<ProjectAssetEntity>,
            deletedAssets: results[1] as List<ProjectAssetEntity>,
            members: members,
            techStacks: results[2] as List<ProjectTechStackEntity>,
            allTechStacks: results[3] as List<TechStackEntity>,
            currentUserId: event.currentUserId,
          ),
        );
      } catch (e) {
        emit(ProjectDetailError(e.toString()));
      }
    });

    on<UpdateProjectTechStacks>((event, emit) async {
      try {
        await updateProjectTechStacksUseCase(event.projectId, event.techStackIds);
        final currentUserId = state is ProjectDetailLoaded
            ? (state as ProjectDetailLoaded).currentUserId
            : null;
        add(FetchProjectDetail(event.projectId, currentUserId: currentUserId));
      } catch (e) {
        emit(ProjectDetailError(e.toString()));
      }
    });
  }
}
