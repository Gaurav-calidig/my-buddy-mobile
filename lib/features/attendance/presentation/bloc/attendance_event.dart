import 'package:core/features/attendance/presentation/bloc/attendance_state.dart';
import 'package:equatable/equatable.dart';
import 'package:core/features/attendance/domain/entities/leave_request_entity.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

class AttendanceStarted extends AttendanceEvent {
  const AttendanceStarted();
}

class AttendanceMonthChanged extends AttendanceEvent {
  const AttendanceMonthChanged(this.deltaMonths);

  final int deltaMonths;

  @override
  List<Object?> get props => <Object?>[deltaMonths];
}

class AttendanceFilterChanged extends AttendanceEvent {
  const AttendanceFilterChanged(this.filterIndex);

  final int filterIndex;

  @override
  List<Object?> get props => <Object?>[filterIndex];
}

class AttendanceLeavesRequested extends AttendanceEvent {
  const AttendanceLeavesRequested();
}

class AttendanceLeaveTypesRequested extends AttendanceEvent {
  const AttendanceLeaveTypesRequested();
}

class AttendanceFiscalYearChanged extends AttendanceEvent {
  const AttendanceFiscalYearChanged(this.fiscalYear);

  final String fiscalYear;

  @override
  List<Object?> get props => <Object?>[fiscalYear];
}

class AttendanceLeaveSubmitted extends AttendanceEvent {
  const AttendanceLeaveSubmitted({
    this.leaveId,
    required this.leaveTypeId,
    required this.startDate,
    required this.startHalf,
    required this.endDate,
    required this.endHalf,
    required this.reason,
  });

  final int? leaveId;
  final int leaveTypeId;
  final String startDate;
  final String startHalf;
  final String endDate;
  final String endHalf;
  final String reason;

  @override
  List<Object?> get props => <Object?>[leaveId, leaveTypeId, startDate, startHalf, endDate, endHalf, reason];
}

class AttendanceCompOffSubmitted extends AttendanceEvent {
  const AttendanceCompOffSubmitted({
    required this.workedDate,
    required this.leaveDays,
    required this.reason,
  });

  final String workedDate;
  final String leaveDays;
  final String reason;

  @override
  List<Object?> get props => <Object?>[workedDate, leaveDays, reason];
}

class AttendanceLeaveDaysCalculationRequested extends AttendanceEvent {
  const AttendanceLeaveDaysCalculationRequested({
    required this.startDate,
    required this.startHalf,
    required this.endDate,
    required this.endHalf,
  });

  final String startDate;
  final String startHalf;
  final String endDate;
  final String endHalf;

  @override
  List<Object?> get props => <Object?>[startDate, startHalf, endDate, endHalf];
}

class AttendanceLeaveDaysCalculationCleared extends AttendanceEvent {
  const AttendanceLeaveDaysCalculationCleared();
}

class AttendanceCompOffHistoryRequested extends AttendanceEvent {
  const AttendanceCompOffHistoryRequested();
}

class AttendanceLeaveCancelRequested extends AttendanceEvent {
  const AttendanceLeaveCancelRequested(this.leaveId);

  final int leaveId;

  @override
  List<Object?> get props => <Object?>[leaveId];
}

class AttendanceLeaveEditRequested extends AttendanceEvent {
  const AttendanceLeaveEditRequested(this.leave);

  final LeaveRequestEntity leave;

  @override
  List<Object?> get props => <Object?>[leave];
}

class AttendanceMessageCleared extends AttendanceEvent {
  const AttendanceMessageCleared();
}

class AttendanceCalendarViewModeChanged extends AttendanceEvent {
  const AttendanceCalendarViewModeChanged(this.viewMode);

  final AmsCalendarViewMode viewMode;

  @override
  List<Object?> get props => <Object?>[viewMode];
}

class AttendanceTodayRequested extends AttendanceEvent {
  const AttendanceTodayRequested();
}
