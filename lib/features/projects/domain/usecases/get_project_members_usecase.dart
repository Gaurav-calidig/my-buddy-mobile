import 'package:core/features/projects/domain/entities/project_member_entity.dart';
import 'package:core/features/projects/domain/repositories/project_repository.dart';

class GetProjectMembersUseCase {
  final ProjectRepository repository;
  GetProjectMembersUseCase(this.repository);
  Future<List<ProjectMemberEntity>> call(int projectId) =>
      repository.getProjectMembers(projectId);
}
