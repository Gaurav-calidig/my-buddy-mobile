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
    required this.leaveTypes,
    required this.fiscalYears,
    required this.selectedFiscalYear,
    required this.leaveSubmitInProgress,
    required this.compOffSubmitInProgress,
    required this.leaveDaysCalculationInProgress,
    required this.leaveActionInProgressId,
    required this.compOffHistory,
    required this.calculatedTotalDays,
    required this.calculatedHolidayCount,
    required this.calculatedWeekendCount,
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
      leaveTypes: const <Map<String, dynamic>>[],
      fiscalYears: const <String>[],
      selectedFiscalYear: '',
      leaveSubmitInProgress: false,
      compOffSubmitInProgress: false,
      leaveDaysCalculationInProgress: false,
      leaveActionInProgressId: null,
      compOffHistory: const <Map<String, String>>[],
      calculatedTotalDays: null,
      calculatedHolidayCount: null,
      calculatedWeekendCount: null,
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
  final List<Map<String, dynamic>> leaveTypes;
  final List<String> fiscalYears;
  final String selectedFiscalYear;
  final bool leaveSubmitInProgress;
  final bool compOffSubmitInProgress;
  final bool leaveDaysCalculationInProgress;
  final int? leaveActionInProgressId;
  final List<Map<String, String>> compOffHistory;
  final num? calculatedTotalDays;
  final int? calculatedHolidayCount;
  final int? calculatedWeekendCount;
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
    List<Map<String, dynamic>>? leaveTypes,
    List<String>? fiscalYears,
    String? selectedFiscalYear,
    bool? leaveSubmitInProgress,
    bool? compOffSubmitInProgress,
    bool? leaveDaysCalculationInProgress,
    int? leaveActionInProgressId,
    bool clearLeaveActionInProgressId = false,
    List<Map<String, String>>? compOffHistory,
    num? calculatedTotalDays,
    int? calculatedHolidayCount,
    int? calculatedWeekendCount,
    bool clearLeaveDaysCalculation = false,
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
      leaveTypes: leaveTypes ?? this.leaveTypes,
      fiscalYears: fiscalYears ?? this.fiscalYears,
      selectedFiscalYear: selectedFiscalYear ?? this.selectedFiscalYear,
      leaveSubmitInProgress: leaveSubmitInProgress ?? this.leaveSubmitInProgress,
      compOffSubmitInProgress: compOffSubmitInProgress ?? this.compOffSubmitInProgress,
      leaveDaysCalculationInProgress: leaveDaysCalculationInProgress ?? this.leaveDaysCalculationInProgress,
      leaveActionInProgressId: clearLeaveActionInProgressId ? null : (leaveActionInProgressId ?? this.leaveActionInProgressId),
      compOffHistory: compOffHistory ?? this.compOffHistory,
      calculatedTotalDays: clearLeaveDaysCalculation ? null : (calculatedTotalDays ?? this.calculatedTotalDays),
      calculatedHolidayCount: clearLeaveDaysCalculation ? null : (calculatedHolidayCount ?? this.calculatedHolidayCount),
      calculatedWeekendCount: clearLeaveDaysCalculation ? null : (calculatedWeekendCount ?? this.calculatedWeekendCount),
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
        leaveTypes,
        fiscalYears,
        selectedFiscalYear,
        leaveSubmitInProgress,
        compOffSubmitInProgress,
        leaveDaysCalculationInProgress,
        leaveActionInProgressId,
        compOffHistory,
        calculatedTotalDays,
        calculatedHolidayCount,
        calculatedWeekendCount,
        prefillLeave,
        successMessage,
        error,
      ];
}
