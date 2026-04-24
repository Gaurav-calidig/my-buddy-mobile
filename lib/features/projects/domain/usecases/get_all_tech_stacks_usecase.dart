import 'package:core/features/projects/domain/entities/tech_stack_entity.dart';
import 'package:core/features/projects/domain/repositories/project_repository.dart';

class GetAllTechStacksUseCase {
  final ProjectRepository repository;
  GetAllTechStacksUseCase(this.repository);
  Future<List<TechStackEntity>> call() => repository.getAllTechStacks();
}
