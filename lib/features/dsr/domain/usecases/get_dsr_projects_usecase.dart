import 'package:core/features/dsr/domain/entities/dsr_project_entity.dart';
import 'package:core/features/dsr/domain/repositories/dsr_repository.dart';

class GetDsrProjectsUseCase {
  const GetDsrProjectsUseCase(this.repository);

  final DsrRepository repository;

  Future<List<DsrProjectEntity>> call() {
    return repository.getProjects();
  }
}

