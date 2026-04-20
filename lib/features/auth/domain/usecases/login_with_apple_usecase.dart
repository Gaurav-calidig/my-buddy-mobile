import 'package:core/features/auth/domain/repositories/auth_repository.dart';
import '../entities/user_entity.dart';

/// Use case responsible for handling the login process.
class LoginWithAppleUseCase {
  final AuthRepository repository;

  /// Constructor with required [repository] to perform authentication.
  LoginWithAppleUseCase(this.repository);

  /// Executes the login process using [email] and [password].
  ///
  /// Returns a [UserEntity] on successful login.
  /// Throws an exception if login fails.
  Future<UserEntity?> call() {
    return repository.signInWithApple();
  }
}

