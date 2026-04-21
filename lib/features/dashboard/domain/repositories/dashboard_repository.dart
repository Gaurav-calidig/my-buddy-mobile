import 'package:core/features/dashboard/domain/entities/dashboard_ams_leave_overview_entity.dart';
import 'package:core/features/dashboard/domain/entities/dashboard_highlights_entity.dart';

abstract class DashboardRepository {
  Future<DashboardHighlightsEntity> getHighlights();

  Future<DashboardAmsLeaveOverviewEntity> getAmsLeaveOverview();
}
