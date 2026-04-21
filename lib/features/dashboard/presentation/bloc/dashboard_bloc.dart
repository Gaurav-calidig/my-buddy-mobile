import 'package:core/core/errors/error_handler.dart';
import 'package:core/features/dashboard/domain/entities/dashboard_ams_leave_overview_entity.dart';
import 'package:core/features/dashboard/domain/entities/dashboard_highlights_entity.dart';
import 'package:core/features/dashboard/domain/usecases/get_dashboard_ams_leave_overview_usecase.dart';
import 'package:core/features/dashboard/domain/usecases/get_dashboard_highlights_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc({
    required GetDashboardHighlightsUseCase getDashboardHighlightsUseCase,
    required GetDashboardAmsLeaveOverviewUseCase getDashboardAmsLeaveOverviewUseCase,
  }) : _getDashboardHighlightsUseCase = getDashboardHighlightsUseCase,
       _getDashboardAmsLeaveOverviewUseCase = getDashboardAmsLeaveOverviewUseCase,
       super(const DashboardState()) {
    on<DashboardLoadRequested>(_onDashboardLoadRequested);
  }

  final GetDashboardHighlightsUseCase _getDashboardHighlightsUseCase;
  final GetDashboardAmsLeaveOverviewUseCase _getDashboardAmsLeaveOverviewUseCase;

  Future<void> _onDashboardLoadRequested(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearErrorMessage: true));

    try {
      final results = await Future.wait<Object>([
        _getDashboardHighlightsUseCase(),
        _getDashboardAmsLeaveOverviewUseCase(),
      ]);
      final highlights = results[0] as DashboardHighlightsEntity;
      final amsLeaveOverview = results[1] as DashboardAmsLeaveOverviewEntity;

      emit(
        state.copyWith(
          isLoading: false,
          highlights: highlights,
          amsLeaveOverview: amsLeaveOverview,
          clearErrorMessage: true,
        ),
      );
    } catch (error, stack) {
      ErrorHandler.handleError(error, stackTrace: stack);
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Unable to load dashboard data.',
        ),
      );
    }
  }
}
