import 'package:core/features/auth/domain/entities/user_entity.dart';
import 'package:core/features/auth/domain/repositories/auth_repository.dart';

/// Handles user registration by delegating to the auth repository.
class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  /// Executes signup with required credentials and returns the created user.
  Future<UserEntity> call({
    required String email,
    required String password,
    required String name,
  }) {
    return repository.signUp(email: email, password: password, name: name);
  }
}

