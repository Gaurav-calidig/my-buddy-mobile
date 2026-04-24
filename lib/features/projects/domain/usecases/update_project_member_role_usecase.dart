import 'package:core/features/projects/domain/repositories/project_repository.dart';

class UpdateProjectMemberRoleUseCase {
  final ProjectRepository repository;
  UpdateProjectMemberRoleUseCase(this.repository);
  Future<void> call({
    required int projectId,
    required String userId,
    required String role,
  }) =>
      repository.updateProjectMemberRole(
        projectId: projectId,
        userId: userId,
        role: role,
      );
}
