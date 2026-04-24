import 'package:core/features/attendance/domain/entities/attendance_entities.dart';
import 'package:core/features/attendance/domain/entities/leave_request_entity.dart';
import 'package:core/core/network/api_routes.dart';
import 'package:core/core/network/api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  AttendanceBloc({required ApiService apiService})
      : _apiService = apiService,
        super(AttendanceState.initial()) {
    on<AttendanceStarted>(_onStarted);
    on<AttendanceMonthChanged>(_onMonthChanged);
    on<AttendanceFilterChanged>(_onFilterChanged);
    on<AttendanceLeavesRequested>(_onLeavesRequested);
    on<AttendanceFiscalYearChanged>(_onFiscalYearChanged);
    on<AttendanceLeaveSubmitted>(_onLeaveSubmitted);
    on<AttendanceCompOffSubmitted>(_onCompOffSubmitted);
    on<AttendanceLeaveCancelRequested>(_onLeaveCancelRequested);
    on<AttendanceLeaveEditRequested>(_onLeaveEditRequested);
    on<AttendanceMessageCleared>(_onMessageCleared);
  }

  final ApiService _apiService;

  Future<void> _onStarted(
    AttendanceStarted event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccessMessage: true));
    final DateTime month = DateTime(2026, 4);
    final List<AmsCalendarDayEntity> days = await _buildMonthDays(month);

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
        days: days,
      ),
    );

    // Preload leaves so "My Leaves" shows instantly.
    add(const AttendanceLeavesRequested());
  }

  Future<void> _onMonthChanged(
    AttendanceMonthChanged event,
    Emitter<AttendanceState> emit,
  ) async {
    final DateTime next = DateTime(state.month.year, state.month.month + event.deltaMonths);
    final List<AmsCalendarDayEntity> days = await _buildMonthDays(next);
    emit(state.copyWith(month: next, days: days, clearError: true));
  }

  void _onFilterChanged(
    AttendanceFilterChanged event,
    Emitter<AttendanceState> emit,
  ) {
    emit(state.copyWith(selectedFilterIndex: event.filterIndex, clearError: true));
    if (event.filterIndex == 0 && state.leaveRequests.isEmpty && !state.leavesLoading) {
      add(const AttendanceLeavesRequested());
    }
  }

  Future<void> _onLeavesRequested(
    AttendanceLeavesRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(leavesLoading: true, clearError: true));
    try {
      final resp = await _apiService.get(ApiRoutes.leaveRequests);
      final data = resp.data;
      final List<dynamic> list = data is List ? data : (data is Map && data['data'] is List ? data['data'] as List : <dynamic>[]);
      final List<LeaveRequestEntity> items = list
          .whereType<Map>()
          .map((m) => LeaveRequestEntity.fromJson(m.cast<String, dynamic>()))
          .toList(growable: false)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final List<String> fiscalYears = _deriveFiscalYears(items);
      final String defaultFy = fiscalYears.isNotEmpty ? fiscalYears.first : _fyLabel(DateTime.now());

      emit(
        state.copyWith(
          leavesLoading: false,
          leaveRequests: items,
          fiscalYears: fiscalYears,
          selectedFiscalYear: state.selectedFiscalYear.isNotEmpty ? state.selectedFiscalYear : defaultFy,
        ),
      );
    } catch (e) {
      emit(state.copyWith(leavesLoading: false, error: e.toString()));
    }
  }

  void _onFiscalYearChanged(
    AttendanceFiscalYearChanged event,
    Emitter<AttendanceState> emit,
  ) {
    emit(state.copyWith(selectedFiscalYear: event.fiscalYear, clearError: true));
  }

  Future<void> _onLeaveSubmitted(
    AttendanceLeaveSubmitted event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(leaveSubmitInProgress: true, clearError: true, clearSuccessMessage: true));
    try {
      final Map<String, dynamic> payload = <String, dynamic>{
        'leaveTypeId': event.leaveTypeId,
        'startDate': event.startDate,
        'startHalf': event.startHalf,
        'endDate': event.endDate,
        'endHalf': event.endHalf,
        'reason': event.reason,
      };

      if (event.leaveId == null) {
        await _apiService.post(ApiRoutes.leaveRequests, payload);
      } else {
        await _apiService.put(ApiRoutes.leaveRequestById(event.leaveId!), payload);
      }

      emit(
        state.copyWith(
          leaveSubmitInProgress: false,
          selectedFilterIndex: 0,
          clearPrefillLeave: true,
          successMessage: event.leaveId == null ? 'Leave request submitted.' : 'Leave request updated.',
        ),
      );
      add(const AttendanceLeavesRequested());
    } catch (e) {
      emit(state.copyWith(leaveSubmitInProgress: false, error: e.toString()));
    }
  }

  Future<void> _onCompOffSubmitted(
    AttendanceCompOffSubmitted event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(compOffSubmitInProgress: true, clearError: true, clearSuccessMessage: true));
    try {
      final Map<String, dynamic> payload = <String, dynamic>{
        'workedDate': event.workedDate,
        'days': event.days,
        'reason': event.reason,
      };
      await _apiService.post(ApiRoutes.compOffRequests, payload);

      final List<Map<String, String>> next = List<Map<String, String>>.from(state.compOffHistory, growable: true)
        ..insert(0, <String, String>{'workedDate': event.workedDate, 'days': event.days, 'reason': event.reason});

      emit(
        state.copyWith(
          compOffSubmitInProgress: false,
          compOffHistory: next,
          successMessage: 'Comp off request submitted.',
        ),
      );
    } catch (e) {
      emit(state.copyWith(compOffSubmitInProgress: false, error: e.toString()));
    }
  }

  Future<void> _onLeaveCancelRequested(
    AttendanceLeaveCancelRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(leaveActionInProgressId: event.leaveId, clearError: true, clearSuccessMessage: true));
    try {
      await _apiService.delete(ApiRoutes.leaveRequestById(event.leaveId));
      final List<LeaveRequestEntity> next = state.leaveRequests.where((e) => e.id != event.leaveId).toList(growable: false);
      emit(
        state.copyWith(
          leaveRequests: next,
          clearLeaveActionInProgressId: true,
          successMessage: 'Leave request cancelled.',
        ),
      );
    } catch (e) {
      emit(state.copyWith(clearLeaveActionInProgressId: true, error: e.toString()));
    }
  }

  void _onLeaveEditRequested(
    AttendanceLeaveEditRequested event,
    Emitter<AttendanceState> emit,
  ) {
    emit(state.copyWith(prefillLeave: event.leave, selectedFilterIndex: 1, clearError: true, clearSuccessMessage: true));
  }

  void _onMessageCleared(
    AttendanceMessageCleared event,
    Emitter<AttendanceState> emit,
  ) {
    emit(state.copyWith(clearError: true, clearSuccessMessage: true));
  }

  List<String> _deriveFiscalYears(List<LeaveRequestEntity> items) {
    final Set<String> years = <String>{};
    for (final LeaveRequestEntity item in items) {
      years.add(_fyLabel(item.startDate));
    }
    final List<String> sorted = years.toList(growable: false)
      ..sort((a, b) => b.compareTo(a));
    return sorted;
  }

  String _fyLabel(DateTime date) {
    // FY assumed April -> March: e.g. April 2026 is "2026-27".
    final int startYear = date.month >= 4 ? date.year : date.year - 1;
    final int endYear2 = (startYear + 1) % 100;
    final String yy = endYear2.toString().padLeft(2, '0');
    return '$startYear-$yy';
  }

  Future<List<AmsCalendarDayEntity>> _buildMonthDays(DateTime month) async {
    final int year = month.year;
    final int m = month.month;
    final DateTime first = DateTime(year, m, 1);
    final int daysInMonth = DateTime(year, m + 1, 0).day;
    final int leading = first.weekday % 7;
    final Map<DateTime, List<AmsLeaveEventEntity>> eventsByDate = await _calendarEventsForMonth(month);

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
          events: eventsByDate[date] ?? const <AmsLeaveEventEntity>[],
        ),
      );
    }

    while (cells.length % 7 != 0) {
      final DateTime next = DateTime(year, m, daysInMonth).add(Duration(days: cells.length % 7));
      cells.add(AmsCalendarDayEntity(date: next, isInCurrentMonth: false));
    }

    return cells;
  }

  Future<Map<DateTime, List<AmsLeaveEventEntity>>> _calendarEventsForMonth(DateTime month) async {
    final DateTime start = DateTime(month.year, month.month, 1);
    final DateTime end = DateTime(month.year, month.month + 1, 0);
    final Map<DateTime, List<AmsLeaveEventEntity>> byDate = <DateTime, List<AmsLeaveEventEntity>>{};

    try {
      final String startDate = _ymd(start);
      final String endDate = _ymd(end);
      final resp = await _apiService.get(
        ApiRoutes.leaveRequestsCalendar(startDate: startDate, endDate: endDate),
      );
      final dynamic data = resp.data;
      final List<dynamic> list = data is List
          ? data
          : (data is Map && data['data'] is List ? data['data'] as List : <dynamic>[]);

      for (final dynamic raw in list) {
        if (raw is! Map) continue;
        final Map<String, dynamic> item = raw.cast<String, dynamic>();
        final DateTime? leaveStart = DateTime.tryParse((item['startDate'] ?? '').toString());
        final DateTime? leaveEnd = DateTime.tryParse((item['endDate'] ?? '').toString());
        if (leaveStart == null || leaveEnd == null) continue;

        final dynamic userRaw = item['user'];
        final Map<String, dynamic> user = userRaw is Map ? userRaw.cast<String, dynamic>() : const <String, dynamic>{};
        final String firstName = (user['firstName'] ?? '').toString().trim();
        final String lastName = (user['lastName'] ?? '').toString().trim();
        final String fullName = '$firstName $lastName'.trim().isEmpty ? 'Unknown' : '$firstName $lastName'.trim();
        final String reason = (item['reason'] ?? '').toString().trim();
        final String status = (item['status'] ?? '').toString().trim().toLowerCase();

        final int color = status == 'pending' ? 0xFFC49C2B : 0xFF2F65C8;
        final DateTime rangeStart = leaveStart.isBefore(start) ? start : leaveStart;
        final DateTime rangeEnd = leaveEnd.isAfter(end) ? end : leaveEnd;
        if (rangeEnd.isBefore(rangeStart)) continue;

        for (DateTime day = rangeStart; !day.isAfter(rangeEnd); day = day.add(const Duration(days: 1))) {
          final DateTime key = DateTime(day.year, day.month, day.day);
          final List<AmsLeaveEventEntity> events = byDate[key] ?? <AmsLeaveEventEntity>[];
          events.add(
            AmsLeaveEventEntity(
              name: fullName,
              reason: reason.isEmpty ? 'No reason provided.' : reason,
              status: status,
              colorHex: color,
            ),
          );
          byDate[key] = events;
        }
      }
    } catch (_) {
      // Keep calendar usable even if API fails.
    }

    return byDate;
  }

  String _ymd(DateTime d) {
    final String mm = d.month.toString().padLeft(2, '0');
    final String dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }
}
