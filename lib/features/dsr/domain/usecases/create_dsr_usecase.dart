import 'package:core/features/dsr/domain/entities/dsr_create_request_entity.dart';
import 'package:core/features/dsr/domain/entities/dsr_entry_entity.dart';
import 'package:core/features/dsr/domain/repositories/dsr_repository.dart';

class CreateDsrUseCase {
  const CreateDsrUseCase(this.repository);

  final DsrRepository repository;

  Future<DsrEntryEntity> call(DsrCreateRequestEntity request) {
    return repository.createDsr(request);
  }
}

