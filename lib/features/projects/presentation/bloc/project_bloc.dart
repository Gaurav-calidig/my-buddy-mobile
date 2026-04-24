import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/features/projects/domain/usecases/get_projects_usecase.dart';
import 'package:core/features/projects/domain/usecases/create_project_usecase.dart';
import 'package:core/features/projects/domain/usecases/update_project_usecase.dart';
import 'project_event.dart';
import 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final GetProjectsUseCase getProjectsUseCase;
  final CreateProjectUseCase createProjectUseCase;
  final UpdateProjectUseCase updateProjectUseCase;

  ProjectBloc({
    required this.getProjectsUseCase,
    required this.createProjectUseCase,
    required this.updateProjectUseCase,
  }) : super(ProjectInitial()) {
    on<FetchProjects>(_onFetchProjects);
    on<CreateProject>(_onCreateProject);
    on<UpdateProject>(_onUpdateProject);
  }

  Future<void> _onFetchProjects(
    FetchProjects event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectLoading());
    try {
      final projects = await getProjectsUseCase();
      emit(ProjectLoaded(projects));
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  Future<void> _onCreateProject(
    CreateProject event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      await createProjectUseCase(
        name: event.name,
        description: event.description,
        isBillable: event.isBillable,
      );
      add(FetchProjects());
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  Future<void> _onUpdateProject(
    UpdateProject event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      await updateProjectUseCase(
        projectId: event.projectId,
        name: event.name,
        description: event.description,
        isBillable: event.isBillable,
      );
      add(FetchProjects());
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }
}
