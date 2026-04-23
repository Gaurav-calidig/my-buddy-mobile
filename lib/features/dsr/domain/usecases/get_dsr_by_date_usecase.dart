import 'package:core/features/dsr/domain/entities/dsr_entry_entity.dart';
import 'package:core/features/dsr/domain/repositories/dsr_repository.dart';

class GetDsrByDateUseCase {
  const GetDsrByDateUseCase(this.repository);

  final DsrRepository repository;

  Future<List<DsrEntryEntity>> call(DateTime date) {
    return repository.getDsrByDate(date);
  }
}

