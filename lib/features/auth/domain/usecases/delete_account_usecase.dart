import 'package:core/features/auth/domain/repositories/auth_repository.dart';

/// Deletes the currently authenticated account.
class DeleteAccountUseCase {
  final AuthRepository repository;

  DeleteAccountUseCase(this.repository);

  Future<void> call() {
    return repository.deleteAccount();
  }
}
