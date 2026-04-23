import 'package:equatable/equatable.dart';

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
