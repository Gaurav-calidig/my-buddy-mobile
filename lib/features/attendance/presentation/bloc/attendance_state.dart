import 'package:core/features/attendance/domain/entities/attendance_entities.dart';
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
    String? error,
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
      error: error,
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
        error,
      ];
}
