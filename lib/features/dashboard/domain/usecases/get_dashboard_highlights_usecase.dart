import 'package:core/features/dashboard/domain/entities/dashboard_highlights_entity.dart';
import 'package:core/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetDashboardHighlightsUseCase {
  const GetDashboardHighlightsUseCase(this._repository);

  final DashboardRepository _repository;

  Future<DashboardHighlightsEntity> call() async {
    return _repository.getHighlights();
  }
}
