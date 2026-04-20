import 'package:core/features/auth/domain/repositories/auth_repository.dart';

/// Signs the current user out of Google.
class GoogleSignOutUseCase {
  final AuthRepository repository;

  GoogleSignOutUseCase(this.repository);

  Future<bool> call() {
    return repository.signOutGoogle();
  }
}
