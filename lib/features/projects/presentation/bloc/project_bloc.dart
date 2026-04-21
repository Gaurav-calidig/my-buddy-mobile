import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/features/projects/domain/usecases/get_projects_usecase.dart';
import 'project_event.dart';
import 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final GetProjectsUseCase getProjectsUseCase;

  ProjectBloc({required this.getProjectsUseCase}) : super(ProjectInitial()) {
    on<FetchProjects>((event, emit) async {
      emit(ProjectLoading());
      try {
        final projects = await getProjectsUseCase();
        emit(ProjectLoaded(projects));
      } catch (e) {
        emit(ProjectError(e.toString()));
      }
    });
  }
}
