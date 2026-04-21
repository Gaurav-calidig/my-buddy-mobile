import 'package:core/features/dashboard/domain/entities/dashboard_ams_leave_overview_entity.dart';
import 'package:core/features/dashboard/domain/entities/dashboard_highlights_entity.dart';
import 'package:equatable/equatable.dart';

class DashboardState extends Equatable {
  const DashboardState({
    this.isLoading = false,
    this.highlights,
    this.amsLeaveOverview,
    this.errorMessage,
  });

  final bool isLoading;
  final DashboardHighlightsEntity? highlights;
  final DashboardAmsLeaveOverviewEntity? amsLeaveOverview;
  final String? errorMessage;

  DashboardState copyWith({
    bool? isLoading,
    DashboardHighlightsEntity? highlights,
    DashboardAmsLeaveOverviewEntity? amsLeaveOverview,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      highlights: highlights ?? this.highlights,
      amsLeaveOverview: amsLeaveOverview ?? this.amsLeaveOverview,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, highlights, amsLeaveOverview, errorMessage];
}
