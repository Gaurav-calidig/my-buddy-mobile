import 'package:core/features/auth/domain/repositories/auth_repository.dart';

/// Handles password reset requests via the repository.
class ForgotPasswordUseCase {
  final AuthRepository repository;

  ForgotPasswordUseCase(this.repository);

  /// Triggers a password reset email for [email].
  Future<void> call(String email) {
    return repository.forgotPassword(email);
  }
}

