import 'package:core/features/projects/domain/repositories/project_repository.dart';

class AddProjectMemberUseCase {
  final ProjectRepository repository;
  AddProjectMemberUseCase(this.repository);
  Future<void> call({
    required int projectId,
    required String username,
    required String role,
  }) =>
      repository.addProjectMember(
        projectId: projectId,
        username: username,
        role: role,
      );
}
