import 'package:core/features/attendance/domain/entities/attendance_entities.dart';
import 'package:core/features/attendance/domain/entities/leave_request_entity.dart';
import 'package:equatable/equatable.dart';

class AttendanceState extends Equatable {
  const AttendanceState({
    required this.isLoading,
    required this.title,
    required this.month,
    required this.selectedFilterIndex,
    required this.stats,
    required this.summary,
    required this.legend,
    required this.days,
    required this.leavesLoading,
    required this.leaveRequests,
    required this.fiscalYears,
    required this.selectedFiscalYear,
    required this.leaveSubmitInProgress,
    required this.compOffSubmitInProgress,
    required this.leaveActionInProgressId,
    required this.compOffHistory,
    required this.prefillLeave,
    required this.successMessage,
    this.error,
  });

  factory AttendanceState.initial() {
    return AttendanceState(
      isLoading: true,
      title: 'Attendance Management',
      month: DateTime(2026, 4),
      selectedFilterIndex: 3,
      stats: const <AmsStatEntity>[],
      summary: const AmsLeaveSummaryEntity(
        allocated: 0,
        used: 0,
        balance: 0,
        casual: '0',
        sick: '0',
      ),
      legend: const <String>['Approved', 'Pending'],
      days: const <AmsCalendarDayEntity>[],
      leavesLoading: false,
      leaveRequests: const <LeaveRequestEntity>[],
      fiscalYears: const <String>[],
      selectedFiscalYear: '',
      leaveSubmitInProgress: false,
      compOffSubmitInProgress: false,
      leaveActionInProgressId: null,
      compOffHistory: const <Map<String, String>>[],
      prefillLeave: null,
      successMessage: null,
    );
  }

  final bool isLoading;
  final String title;
  final DateTime month;
  final int selectedFilterIndex;
  final List<AmsStatEntity> stats;
  final AmsLeaveSummaryEntity summary;
  final List<String> legend;
  final List<AmsCalendarDayEntity> days;
  final bool leavesLoading;
  final List<LeaveRequestEntity> leaveRequests;
  final List<String> fiscalYears;
  final String selectedFiscalYear;
  final bool leaveSubmitInProgress;
  final bool compOffSubmitInProgress;
  final int? leaveActionInProgressId;
  final List<Map<String, String>> compOffHistory;
  final LeaveRequestEntity? prefillLeave;
  final String? successMessage;
  final String? error;

  AttendanceState copyWith({
    bool? isLoading,
    String? title,
    DateTime? month,
    int? selectedFilterIndex,
    List<AmsStatEntity>? stats,
    AmsLeaveSummaryEntity? summary,
    List<String>? legend,
    List<AmsCalendarDayEntity>? days,
    bool? leavesLoading,
    List<LeaveRequestEntity>? leaveRequests,
    List<String>? fiscalYears,
    String? selectedFiscalYear,
    bool? leaveSubmitInProgress,
    bool? compOffSubmitInProgress,
    int? leaveActionInProgressId,
    bool clearLeaveActionInProgressId = false,
    List<Map<String, String>>? compOffHistory,
    LeaveRequestEntity? prefillLeave,
    bool clearPrefillLeave = false,
    String? successMessage,
    bool clearSuccessMessage = false,
    String? error,
    bool clearError = false,
  }) {
    return AttendanceState(
      isLoading: isLoading ?? this.isLoading,
      title: title ?? this.title,
      month: month ?? this.month,
      selectedFilterIndex: selectedFilterIndex ?? this.selectedFilterIndex,
      stats: stats ?? this.stats,
      summary: summary ?? this.summary,
      legend: legend ?? this.legend,
      days: days ?? this.days,
      leavesLoading: leavesLoading ?? this.leavesLoading,
      leaveRequests: leaveRequests ?? this.leaveRequests,
      fiscalYears: fiscalYears ?? this.fiscalYears,
      selectedFiscalYear: selectedFiscalYear ?? this.selectedFiscalYear,
      leaveSubmitInProgress: leaveSubmitInProgress ?? this.leaveSubmitInProgress,
      compOffSubmitInProgress: compOffSubmitInProgress ?? this.compOffSubmitInProgress,
      leaveActionInProgressId: clearLeaveActionInProgressId ? null : (leaveActionInProgressId ?? this.leaveActionInProgressId),
      compOffHistory: compOffHistory ?? this.compOffHistory,
      prefillLeave: clearPrefillLeave ? null : (prefillLeave ?? this.prefillLeave),
      successMessage: clearSuccessMessage ? null : (successMessage ?? this.successMessage),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => <Object?>[
        isLoading,
        title,
        month,
        selectedFilterIndex,
        stats,
        summary,
        legend,
        days,
        leavesLoading,
        leaveRequests,
        fiscalYears,
        selectedFiscalYear,
        leaveSubmitInProgress,
        compOffSubmitInProgress,
        leaveActionInProgressId,
        compOffHistory,
        prefillLeave,
        successMessage,
        error,
      ];
}
