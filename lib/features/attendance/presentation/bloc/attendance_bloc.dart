import 'package:core/features/attendance/domain/entities/attendance_entities.dart';
import 'package:core/features/attendance/domain/entities/attendance_leave_stats_entity.dart';
import 'package:core/features/attendance/domain/entities/leave_request_entity.dart';
import 'package:core/features/attendance/domain/usecases/get_attendance_leave_stats_usecase.dart';
import 'package:core/core/network/api_routes.dart';
import 'package:core/core/network/api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  AttendanceBloc({
    required ApiService apiService,
    required GetAttendanceLeaveStatsUseCase getAttendanceLeaveStatsUseCase,
  })
      : _apiService = apiService,
        _getAttendanceLeaveStatsUseCase = getAttendanceLeaveStatsUseCase,
        super(AttendanceState.initial()) {
    on<AttendanceStarted>(_onStarted);
    on<AttendanceMonthChanged>(_onMonthChanged);
    on<AttendanceFilterChanged>(_onFilterChanged);
    on<AttendanceLeavesRequested>(_onLeavesRequested);
    on<AttendanceLeaveTypesRequested>(_onLeaveTypesRequested);
    on<AttendanceFiscalYearChanged>(_onFiscalYearChanged);
    on<AttendanceLeaveSubmitted>(_onLeaveSubmitted);
    on<AttendanceCompOffSubmitted>(_onCompOffSubmitted);
    on<AttendanceCompOffHistoryRequested>(_onCompOffHistoryRequested);
    on<AttendanceLeaveCancelRequested>(_onLeaveCancelRequested);
    on<AttendanceLeaveDaysCalculationRequested>(_onLeaveDaysCalculationRequested);
    on<AttendanceLeaveDaysCalculationCleared>(_onLeaveDaysCalculationCleared);
    on<AttendanceLeaveEditRequested>(_onLeaveEditRequested);
    on<AttendanceMessageCleared>(_onMessageCleared);
  }

  final ApiService _apiService;
  final GetAttendanceLeaveStatsUseCase _getAttendanceLeaveStatsUseCase;

  Future<void> _onStarted(
    AttendanceStarted event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccessMessage: true));
    final DateTime month = DateTime(2026, 4);
    final List<AmsCalendarDayEntity> days = await _buildMonthDays(month);
    final AttendanceLeaveStatsEntity? leaveStats = await _safeFetchLeaveStats();

    emit(
      state.copyWith(
        isLoading: false,
        month: month,
        stats: _buildStats(leaveStats),
        summary: _buildSummary(leaveStats),
        days: days,
      ),
    );

    // Preload leaves so "My Leaves" shows instantly.
    add(const AttendanceLeavesRequested());
    add(const AttendanceLeaveTypesRequested());
    add(const AttendanceCompOffHistoryRequested());
  }

  Future<AttendanceLeaveStatsEntity?> _safeFetchLeaveStats() async {
    try {
      return await _getAttendanceLeaveStatsUseCase();
    } catch (_) {
      return null;
    }
  }

  List<AmsStatEntity> _buildStats(AttendanceLeaveStatsEntity? stats) {
    if (stats == null) {
      return const <AmsStatEntity>[
        AmsStatEntity(label: 'Total Used', value: '0', caption: 'days this FY'),
        AmsStatEntity(label: 'Pending Approval', value: '0', caption: 'requests'),
        AmsStatEntity(label: 'On Leave Today', value: '0', caption: 'members'),
        AmsStatEntity(label: 'On Leave This Month', value: '0', caption: 'members'),
      ];
    }
    return <AmsStatEntity>[
      AmsStatEntity(label: 'Total Used', value: stats.totalUsed.toString(), caption: 'days this FY'),
      AmsStatEntity(label: 'Pending Approval', value: stats.pendingCount.toString(), caption: 'requests'),
      AmsStatEntity(label: 'On Leave Today', value: stats.todayCount.toString(), caption: 'members'),
      AmsStatEntity(label: 'On Leave This Month', value: stats.thisMonthCount.toString(), caption: 'members'),
    ];
  }

  AmsLeaveSummaryEntity _buildSummary(AttendanceLeaveStatsEntity? stats) {
    if (stats == null) {
      return const AmsLeaveSummaryEntity(
        allocated: 0,
        used: 0,
        balance: 0,
        casual: '0',
        sick: '0',
      );
    }

    final AttendanceLeaveTypeStatsEntity? casual = _findLeaveTypeStats(stats.leaveTypeBreakdown, 'casual');
    final AttendanceLeaveTypeStatsEntity? sick = _findLeaveTypeStats(stats.leaveTypeBreakdown, 'sick');
    final int rawBalance = stats.allocated - stats.totalUsed;
    final int balance = rawBalance < 0 ? 0 : rawBalance;

    return AmsLeaveSummaryEntity(
      allocated: stats.allocated,
      used: stats.totalUsed,
      balance: balance,
      casual: _formatBreakdown(casual),
      sick: _formatBreakdown(sick),
    );
  }

  AttendanceLeaveTypeStatsEntity? _findLeaveTypeStats(
    List<AttendanceLeaveTypeStatsEntity> breakdown,
    String keyword,
  ) {
    for (final AttendanceLeaveTypeStatsEntity item in breakdown) {
      if (item.name.toLowerCase().contains(keyword)) {
        return item;
      }
    }
    return null;
  }

  String _formatBreakdown(AttendanceLeaveTypeStatsEntity? item) {
    if (item == null) return '0';
    final String usedText = item.used == item.used.toInt() ? item.used.toInt().toString() : item.used.toString();
    if (item.pending > 0) {
      return '$usedText (${item.pending} pending)';
    }
    return usedText;
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
    if (event.filterIndex == 2 && state.compOffHistory.isEmpty) {
      add(const AttendanceCompOffHistoryRequested());
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

  Future<void> _onLeaveTypesRequested(
    AttendanceLeaveTypesRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    try {
      final resp = await _apiService.get(ApiRoutes.leaveTypes);
      final dynamic data = resp.data;
      final List<dynamic> list = data is List
          ? data
          : (data is Map && data['data'] is List ? data['data'] as List : <dynamic>[]);

      final List<Map<String, dynamic>> leaveTypes = list.whereType<Map>().map((Map item) {
        final Map<String, dynamic> map = item.cast<String, dynamic>();
        return <String, dynamic>{
          'id': _asInt(map['id']),
          'name': (map['name'] ?? '').toString(),
          'isPaid': map['isPaid'] == true,
          'isActive': map['isActive'] == true,
        };
      }).where((Map<String, dynamic> item) => item['isActive'] == true).toList(growable: false)
        ..sort((a, b) => a['name'].toString().compareTo(b['name'].toString()));

      emit(state.copyWith(leaveTypes: leaveTypes));
    } catch (_) {
      // Keep leave form usable via fallback list generation.
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
        await _apiService.patch(ApiRoutes.leaveRequestById(event.leaveId!), payload);
      }

      emit(
        state.copyWith(
          leaveSubmitInProgress: false,
          selectedFilterIndex: 0,
          clearLeaveDaysCalculation: true,
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
        'leaveDays': event.leaveDays,
        'reason': event.reason,
      };
      await _apiService.post(ApiRoutes.compOffRequests, payload);

      emit(
        state.copyWith(
          compOffSubmitInProgress: false,
          successMessage: 'Comp off request submitted.',
        ),
      );
      add(const AttendanceCompOffHistoryRequested());
    } catch (e) {
      emit(state.copyWith(compOffSubmitInProgress: false, error: e.toString()));
    }
  }

  Future<void> _onCompOffHistoryRequested(
    AttendanceCompOffHistoryRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    try {
      final resp = await _apiService.get(ApiRoutes.compOffRequests);
      final dynamic data = resp.data;
      final List<dynamic> list = data is List
          ? data
          : (data is Map && data['data'] is List ? data['data'] as List : <dynamic>[]);

      final List<Map<String, String>> history = list.whereType<Map>().map((Map item) {
        final Map<String, dynamic> map = item.cast<String, dynamic>();
        return <String, String>{
          'workedDate': (map['workedDate'] ?? '').toString(),
          'leaveDays': (map['leaveDays'] ?? '').toString(),
          'reason': (map['reason'] ?? '').toString(),
          'status': (map['status'] ?? '').toString(),
        };
      }).toList(growable: false);

      emit(state.copyWith(compOffHistory: history));
    } catch (_) {
      // Keep tab usable even when history fetch fails.
    }
  }

  Future<void> _onLeaveCancelRequested(
    AttendanceLeaveCancelRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(leaveActionInProgressId: event.leaveId, clearError: true, clearSuccessMessage: true));
    try {
      await _apiService.post(ApiRoutes.leaveRequestCancelById(event.leaveId), <String, dynamic>{});
      final List<LeaveRequestEntity> next = state.leaveRequests.map((LeaveRequestEntity e) {
        if (e.id != event.leaveId) return e;
        return LeaveRequestEntity(
          id: e.id,
          userId: e.userId,
          leaveTypeId: e.leaveTypeId,
          startDate: e.startDate,
          startHalf: e.startHalf,
          endDate: e.endDate,
          endHalf: e.endHalf,
          totalDays: e.totalDays,
          reason: e.reason,
          status: 'cancelled',
          isUnpaid: e.isUnpaid,
          reviewedById: e.reviewedById,
          reviewerNote: e.reviewerNote,
          createdAt: e.createdAt,
          updatedAt: DateTime.now(),
          leaveType: e.leaveType,
          reviewedBy: e.reviewedBy,
        );
      }).toList(growable: false);
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

  Future<void> _onLeaveDaysCalculationRequested(
    AttendanceLeaveDaysCalculationRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(
      state.copyWith(
        leaveDaysCalculationInProgress: true,
        clearError: true,
      ),
    );
    try {
      final Map<String, dynamic> payload = <String, dynamic>{
        'startDate': event.startDate,
        'startHalf': event.startHalf,
        'endDate': event.endDate,
        'endHalf': event.endHalf,
      };
      final resp = await _apiService.post(ApiRoutes.leaveRequestsCalculateDays, payload);
      final dynamic data = resp.data;
      final Map<String, dynamic> map = data is Map<String, dynamic>
          ? (data['data'] is Map<String, dynamic> ? Map<String, dynamic>.from(data['data'] as Map<String, dynamic>) : data)
          : (data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{});

      emit(
        state.copyWith(
          leaveDaysCalculationInProgress: false,
          calculatedTotalDays: _asNum(map['totalDays']),
          calculatedHolidayCount: _asInt(map['holidayCount']),
          calculatedWeekendCount: _asInt(map['weekendCount']),
        ),
      );
    } catch (_) {
      emit(state.copyWith(leaveDaysCalculationInProgress: false));
    }
  }

  void _onLeaveDaysCalculationCleared(
    AttendanceLeaveDaysCalculationCleared event,
    Emitter<AttendanceState> emit,
  ) {
    emit(state.copyWith(clearLeaveDaysCalculation: true));
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

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  num _asNum(dynamic value) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '') ?? 0;
  }
}
