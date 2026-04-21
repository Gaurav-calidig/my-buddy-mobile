import 'package:core/features/dashboard/domain/entities/dashboard_ams_leave_overview_entity.dart';
import 'package:core/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetDashboardAmsLeaveOverviewUseCase {
  const GetDashboardAmsLeaveOverviewUseCase(this._repository);

  final DashboardRepository _repository;

  Future<DashboardAmsLeaveOverviewEntity> call() async {
    return _repository.getAmsLeaveOverview();
  }
}
