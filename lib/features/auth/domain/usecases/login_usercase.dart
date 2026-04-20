import 'package:core/features/auth/domain/entities/user_entity.dart';
import 'package:core/features/auth/domain/repositories/auth_repository.dart';

/// Deprecated: prefer dedicated use-cases (email/password, google, delete).
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserEntity> call(String email, String password) {
    return repository.login(email, password);
  }
}
