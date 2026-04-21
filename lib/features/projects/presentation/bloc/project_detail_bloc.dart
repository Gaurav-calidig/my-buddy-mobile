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

  ProjectDetailBloc({
    required this.getProjectAssetsUseCase,
    required this.getDeletedProjectAssetsUseCase,
    required this.getProjectMembersUseCase,
    required this.getProjectTechStacksUseCase,
    required this.createProjectAssetUseCase,
    required this.updateProjectAssetUseCase,
    required this.deleteProjectAssetUseCase,
    required this.restoreProjectAssetUseCase,
  }) : super(ProjectDetailInitial()) {
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
        ]);

        emit(
          ProjectDetailLoaded(
            assets: results[0] as dynamic,
            deletedAssets: results[1] as dynamic,
            members: results[2] as dynamic,
            techStacks: results[3] as dynamic,
          ),
        );
      } catch (e) {
        emit(ProjectDetailError(e.toString()));
      }
    });
  }
}
