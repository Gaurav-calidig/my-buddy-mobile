import 'package:core/features/auth/domain/entities/user_entity.dart';
import 'package:core/features/auth/domain/repositories/auth_repository.dart';

/// Signs in with email & password.
class EmailPasswordLoginUseCase {
  final AuthRepository repository;

  EmailPasswordLoginUseCase(this.repository);

  Future<UserEntity> call({
    required String email,
    required String password,
  }) {
    return repository.login(email, password);
  }
}
