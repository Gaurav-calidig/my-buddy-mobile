import 'package:core/features/projects/domain/repositories/project_repository.dart';

class RemoveProjectMemberUseCase {
  final ProjectRepository repository;
  RemoveProjectMemberUseCase(this.repository);
  Future<void> call(int projectId, String userId) =>
      repository.removeProjectMember(projectId, userId);
}
