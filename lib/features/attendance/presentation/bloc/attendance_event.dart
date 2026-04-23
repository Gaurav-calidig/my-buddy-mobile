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
    required this.days,
    required this.reason,
  });

  final String workedDate;
  final String days;
  final String reason;

  @override
  List<Object?> get props => <Object?>[workedDate, days, reason];
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
