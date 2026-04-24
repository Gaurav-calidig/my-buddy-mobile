import 'package:core/features/projects/domain/entities/project_entity.dart';
import 'package:core/features/projects/domain/repositories/project_repository.dart';

class CreateProjectUseCase {
  final ProjectRepository repository;
  CreateProjectUseCase(this.repository);

  Future<ProjectEntity> call({
    required String name,
    required String description,
    required bool isBillable,
  }) async {
    return await repository.createProject(
      name: name,
      description: description,
      isBillable: isBillable,
    );
  }
}
