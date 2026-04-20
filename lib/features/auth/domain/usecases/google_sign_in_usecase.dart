import 'package:core/features/auth/domain/entities/user_entity.dart';
import 'package:core/features/auth/domain/repositories/auth_repository.dart';

/// Initiates Google sign-in and returns the authenticated user.
class GoogleSignInUseCase {
  final AuthRepository repository;

  GoogleSignInUseCase(this.repository);

  Future<UserEntity> call() {
    return repository.signInWithGoogle();
  }
}
