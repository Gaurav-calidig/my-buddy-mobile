import 'package:core/features/dsr/domain/entities/dsr_entry_entity.dart';
import 'package:core/features/dsr/domain/repositories/dsr_repository.dart';

class UpdateDsrUseCase {
  const UpdateDsrUseCase(this.repository);

  final DsrRepository repository;

  Future<DsrEntryEntity> call({
    required String dsrId,
    required String description,
    required String hours,
    required String status,
  }) {
    return repository.updateDsr(
      dsrId: dsrId,
      description: description,
      hours: hours,
      status: status,
    );
  }
}
