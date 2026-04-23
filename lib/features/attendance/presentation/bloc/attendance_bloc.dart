import 'package:core/features/attendance/domain/entities/attendance_entities.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  AttendanceBloc() : super(AttendanceState.initial()) {
    on<AttendanceStarted>(_onStarted);
    on<AttendanceMonthChanged>(_onMonthChanged);
    on<AttendanceFilterChanged>(_onFilterChanged);
  }

  Future<void> _onStarted(
    AttendanceStarted event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    final DateTime month = DateTime(2026, 4);
    emit(
      state.copyWith(
        isLoading: false,
        month: month,
        stats: const <AmsStatEntity>[
          AmsStatEntity(label: 'Total Used', value: '1', caption: 'days this FY'),
          AmsStatEntity(label: 'Pending Approval', value: '1', caption: 'requests'),
          AmsStatEntity(label: 'On Leave Today', value: '0', caption: 'members'),
          AmsStatEntity(label: 'On Leave This Month', value: '1', caption: 'members'),
        ],
        summary: const AmsLeaveSummaryEntity(
          allocated: 7,
          used: 1,
          balance: 6,
          casual: '0.5 (2 pending)',
          sick: '1',
        ),
        days: _buildMonthDays(month),
      ),
    );
  }

  void _onMonthChanged(
    AttendanceMonthChanged event,
    Emitter<AttendanceState> emit,
  ) {
    final DateTime next = DateTime(state.month.year, state.month.month + event.deltaMonths);
    emit(state.copyWith(month: next, days: _buildMonthDays(next), error: null));
  }

  void _onFilterChanged(
    AttendanceFilterChanged event,
    Emitter<AttendanceState> emit,
  ) {
    emit(state.copyWith(selectedFilterIndex: event.filterIndex, error: null));
  }

  List<AmsCalendarDayEntity> _buildMonthDays(DateTime month) {
    final int year = month.year;
    final int m = month.month;
    final DateTime first = DateTime(year, m, 1);
    final int daysInMonth = DateTime(year, m + 1, 0).day;
    final int leading = first.weekday % 7;

    final List<AmsCalendarDayEntity> cells = <AmsCalendarDayEntity>[];

    for (int i = 0; i < leading; i++) {
      final DateTime prev = first.subtract(Duration(days: leading - i));
      cells.add(AmsCalendarDayEntity(date: prev, isInCurrentMonth: false));
    }

    for (int d = 1; d <= daysInMonth; d++) {
      final DateTime date = DateTime(year, m, d);
      cells.add(
        AmsCalendarDayEntity(
          date: date,
          isInCurrentMonth: true,
          events: _eventsForDate(date),
        ),
      );
    }

    while (cells.length % 7 != 0) {
      final DateTime next = DateTime(year, m, daysInMonth).add(Duration(days: cells.length % 7));
      cells.add(AmsCalendarDayEntity(date: next, isInCurrentMonth: false));
    }

    return cells;
  }

  List<AmsLeaveEventEntity> _eventsForDate(DateTime date) {
    final Map<int, List<AmsLeaveEventEntity>> april = <int, List<AmsLeaveEventEntity>>{
      3: const <AmsLeaveEventEntity>[AmsLeaveEventEntity(title: 'Shivam', colorHex: 0xFF2F65C8)],
      7: const <AmsLeaveEventEntity>[AmsLeaveEventEntity(title: 'Vicky', colorHex: 0xFF2F65C8)],
      8: const <AmsLeaveEventEntity>[AmsLeaveEventEntity(title: 'Sandeep', colorHex: 0xFF2F65C8)],
      9: const <AmsLeaveEventEntity>[AmsLeaveEventEntity(title: 'Kumar', colorHex: 0xFF2F65C8)],
      10: const <AmsLeaveEventEntity>[AmsLeaveEventEntity(title: 'Harsh', colorHex: 0xFF2F65C8)],
      14: const <AmsLeaveEventEntity>[AmsLeaveEventEntity(title: 'Ganesh', colorHex: 0xFF2F65C8)],
      19: const <AmsLeaveEventEntity>[AmsLeaveEventEntity(title: 'Rajat', colorHex: 0xFF2F65C8)],
      20: const <AmsLeaveEventEntity>[AmsLeaveEventEntity(title: 'Adarsh', colorHex: 0xFF2F65C8)],
      21: const <AmsLeaveEventEntity>[AmsLeaveEventEntity(title: 'Vicky', colorHex: 0xFF2F65C8)],
      27: const <AmsLeaveEventEntity>[AmsLeaveEventEntity(title: 'Harsh', colorHex: 0xFFC49C2B)],
    };

    if (date.year == 2026 && date.month == 4) {
      return april[date.day] ?? const <AmsLeaveEventEntity>[];
    }
    return const <AmsLeaveEventEntity>[];
  }
}
