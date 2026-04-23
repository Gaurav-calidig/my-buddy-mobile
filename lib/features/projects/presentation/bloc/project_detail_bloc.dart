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
        add(FetchProjectDetail(event.projectId));
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
        add(FetchProjectDetail(event.projectId));
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
        add(FetchProjectDetail(event.projectId));
      } catch (e) {
        emit(ProjectDetailError(e.toString()));
      }
    });

    on<DeleteProjectAsset>((event, emit) async {
      try {
        await deleteProjectAssetUseCase(event.projectId, event.assetId);
        add(FetchProjectDetail(event.projectId));
      } catch (e) {
        emit(ProjectDetailError(e.toString()));
      }
    });

    on<RestoreProjectAsset>((event, emit) async {
      try {
        await restoreProjectAssetUseCase(event.projectId, event.assetId);
        add(FetchProjectDetail(event.projectId));
      } catch (e) {
        emit(ProjectDetailError(e.toString()));
      }
    });

    on<FetchProjectDetail>((event, emit) async {
      emit(ProjectDetailLoading());
      try {
        final results = await Future.wait([
          getProjectAssetsUseCase(event.projectId),
          getDeletedProjectAssetsUseCase(event.projectId),
          getProjectMembersUseCase(event.projectId),
          getProjectTechStacksUseCase(event.projectId),
          getAllTechStacksUseCase(),
        ]);

        emit(
          ProjectDetailLoaded(
            assets: results[0] as dynamic,
            deletedAssets: results[1] as dynamic,
            members: results[2] as dynamic,
            techStacks: results[3] as dynamic,
            allTechStacks: results[4] as dynamic,
          ),
        );
      } catch (e) {
        emit(ProjectDetailError(e.toString()));
      }
    });

    on<UpdateProjectTechStacks>((event, emit) async {
      try {
        await updateProjectTechStacksUseCase(event.projectId, event.techStackIds);
        add(FetchProjectDetail(event.projectId));
      } catch (e) {
        emit(ProjectDetailError(e.toString()));
      }
    });
  }
}
