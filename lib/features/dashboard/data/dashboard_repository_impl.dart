import 'package:core/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:core/features/dashboard/domain/entities/dashboard_ams_leave_overview_entity.dart';
import 'package:core/features/dashboard/domain/entities/dashboard_highlights_entity.dart';
import 'package:core/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl({required this.datasource});

  final DashboardRemoteDatasource datasource;

  @override
  Future<DashboardHighlightsEntity> getHighlights() async {
    return datasource.getHighlights();
  }

  @override
  Future<DashboardAmsLeaveOverviewEntity> getAmsLeaveOverview() async {
    return datasource.getAmsLeaveOverview();
  }
}
