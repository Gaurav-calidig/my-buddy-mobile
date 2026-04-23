import 'package:core/features/dsr/domain/repositories/dsr_repository.dart';

class DeleteDsrUseCase {
  const DeleteDsrUseCase(this.repository);

  final DsrRepository repository;

  Future<void> call(String dsrId) {
    return repository.deleteDsr(dsrId);
  }
}
