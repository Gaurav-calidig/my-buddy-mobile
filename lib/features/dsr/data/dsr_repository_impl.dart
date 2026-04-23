import 'package:core/features/dsr/data/datasources/dsr_remote_datasource.dart';
import 'package:core/features/dsr/domain/entities/dsr_create_request_entity.dart';
import 'package:core/features/dsr/domain/entities/dsr_entry_entity.dart';
import 'package:core/features/dsr/domain/entities/dsr_project_entity.dart';
import 'package:core/features/dsr/domain/repositories/dsr_repository.dart';

class DsrRepositoryImpl implements DsrRepository {
  const DsrRepositoryImpl({required this.datasource});

  final DsrRemoteDatasource datasource;

  @override
  Future<List<DsrProjectEntity>> getProjects() {
    return datasource.getProjects();
  }

  @override
  Future<List<DsrEntryEntity>> getDsrByDate(DateTime date) {
    return datasource.getDsrByDate(date);
  }

  @override
  Future<List<DsrEntryEntity>> getMyDsr() {
    return datasource.getMyDsr();
  }

  @override
  Future<DsrEntryEntity> createDsr(DsrCreateRequestEntity request) {
    return datasource.createDsr(request);
  }
}
