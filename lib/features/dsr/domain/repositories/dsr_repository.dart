import 'package:core/features/dsr/domain/entities/dsr_entry_entity.dart';
import 'package:core/features/dsr/domain/entities/dsr_project_entity.dart';
import 'package:core/features/dsr/domain/entities/dsr_create_request_entity.dart';

abstract class DsrRepository {
  Future<List<DsrProjectEntity>> getProjects();

  Future<List<DsrEntryEntity>> getDsrByDate(DateTime date);

  Future<List<DsrEntryEntity>> getMyDsr();

  Future<DsrEntryEntity> createDsr(DsrCreateRequestEntity request);
}
