import 'package:core/core/network/api_routes.dart';
import 'package:core/core/network/api_service.dart';
import 'package:core/features/dsr/data/models/dsr_entry_model.dart';
import 'package:core/features/dsr/data/models/dsr_project_model.dart';
import 'package:core/features/dsr/domain/entities/dsr_create_request_entity.dart';

abstract class DsrRemoteDatasource {
  Future<List<DsrProjectModel>> getProjects();

  Future<List<DsrEntryModel>> getDsrByDate(DateTime date);

  Future<List<DsrEntryModel>> getMyDsr();

  Future<DsrEntryModel> createDsr(DsrCreateRequestEntity request);

  Future<DsrEntryModel> updateDsr({
    required String dsrId,
    required String description,
    required String hours,
    required String status,
  });

  Future<void> deleteDsr(String dsrId);
}

class DsrRemoteDatasourceImpl implements DsrRemoteDatasource {
  const DsrRemoteDatasourceImpl({required this.apiService});

  final ApiService apiService;

  @override
  Future<List<DsrProjectModel>> getProjects() async {
    final response = await apiService.get(ApiRoutes.projects);
    if (response.data is! List) return <DsrProjectModel>[];
    return (response.data as List<dynamic>)
        .whereType<Map>()
        .map((e) => DsrProjectModel.fromJson(Map<String, dynamic>.from(e)))
        .where((p) => p.name.isNotEmpty)
        .toList(growable: false);
  }

  @override
  Future<List<DsrEntryModel>> getDsrByDate(DateTime date) async {
    final response = await apiService.get(ApiRoutes.dsrByDate(_toApiDate(date)));
    if (response.data is! List) return <DsrEntryModel>[];
    return (response.data as List<dynamic>)
        .whereType<Map>()
        .map((e) => DsrEntryModel.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: true);
  }

  @override
  Future<List<DsrEntryModel>> getMyDsr() async {
    final response = await apiService.get(ApiRoutes.myDsr);
    if (response.data is! List) return <DsrEntryModel>[];
    return (response.data as List<dynamic>)
        .whereType<Map>()
        .map((e) => DsrEntryModel.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: true);
  }

  @override
  Future<DsrEntryModel> createDsr(DsrCreateRequestEntity request) async {
    final response = await apiService.post(
      ApiRoutes.dsr,
      <String, dynamic>{
        'projectId': request.projectId,
        'date': _toApiDate(request.date),
        'description': request.description,
        'hours': request.hours,
        'status': request.status,
      },
    );

    final dynamic data = response.data;
    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      if (map['data'] is Map) {
        return DsrEntryModel.fromJson(Map<String, dynamic>.from(map['data'] as Map));
      }
      return DsrEntryModel.fromJson(map);
    }
    throw Exception('Failed to create DSR entry');
  }

  @override
  Future<DsrEntryModel> updateDsr({
    required String dsrId,
    required String description,
    required String hours,
    required String status,
  }) async {
    final response = await apiService.patch(
      ApiRoutes.dsrById(dsrId),
      <String, dynamic>{
        'description': description,
        'hours': hours,
        'status': status,
      },
    );

    final dynamic data = response.data;
    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      if (map['data'] is Map) {
        return DsrEntryModel.fromJson(Map<String, dynamic>.from(map['data'] as Map));
      }
      return DsrEntryModel.fromJson(map);
    }
    throw Exception('Failed to update DSR entry');
  }

  @override
  Future<void> deleteDsr(String dsrId) async {
    await apiService.delete(ApiRoutes.dsrById(dsrId));
  }

  String _toApiDate(DateTime date) {
    final DateTime day = DateTime(date.year, date.month, date.day);
    final String month = day.month.toString().padLeft(2, '0');
    final String d = day.day.toString().padLeft(2, '0');
    return '${day.year}-$month-$d';
  }
}
