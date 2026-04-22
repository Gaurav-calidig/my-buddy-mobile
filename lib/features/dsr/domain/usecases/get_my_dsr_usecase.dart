import 'package:core/features/dsr/domain/entities/dsr_entry_entity.dart';
import 'package:core/features/dsr/domain/repositories/dsr_repository.dart';

class GetMyDsrUseCase {
  const GetMyDsrUseCase(this.repository);

  final DsrRepository repository;

  Future<List<DsrEntryEntity>> call() {
    return repository.getMyDsr();
  }
}

