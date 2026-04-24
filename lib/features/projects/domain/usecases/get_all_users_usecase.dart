import 'package:core/features/auth/domain/entities/user_entity.dart';
import 'package:core/features/projects/domain/repositories/project_repository.dart';

class GetAllUsersUseCase {
  final ProjectRepository repository;
  GetAllUsersUseCase(this.repository);
  Future<List<UserEntity>> call() => repository.getAllUsers();
}
