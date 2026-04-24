import 'package:core/core/theme/app_colors.dart';
import 'package:core/core/widgets/custom_app_bar.dart';
import 'package:core/core/widgets/template_feature_drawer.dart';
import 'package:core/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:core/features/attendance/presentation/bloc/attendance_event.dart';
import 'package:core/features/attendance/presentation/bloc/attendance_state.dart';
import 'package:core/features/attendance/domain/entities/leave_request_entity.dart';
import 'package:core/features/attendance/presentation/widgets/ams_calendar.dart';
import 'package:core/features/attendance/presentation/widgets/ams_comp_off_tab.dart';
import 'package:core/features/attendance/presentation/widgets/ams_filter_tabs.dart';
import 'package:core/features/attendance/presentation/widgets/ams_apply_leave_tab.dart';
import 'package:core/features/attendance/presentation/widgets/ams_my_leaves_tab.dart';
import 'package:core/features/attendance/presentation/widgets/ams_stat_card.dart';
import 'package:core/features/attendance/presentation/widgets/ams_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  Future<void> _openEditLeaveDialog(
    BuildContext context,
    LeaveRequestEntity leave,
  ) async {
    final AttendanceBloc bloc = context.read<AttendanceBloc>();
    final Map<String, dynamic> prefill = <String, dynamic>{
      'leaveId': leave.id,
      'leaveTypeId': leave.leaveTypeId,
      'startDate': _ymd(leave.startDate),
      'startHalf': leave.startHalf,
      'endDate': _ymd(leave.endDate),
      'endHalf': leave.endHalf,
      'reason': leave.reason,
    };

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return BlocProvider<AttendanceBloc>.value(
          value: bloc,
          child: BlocListener<AttendanceBloc, AttendanceState>(
            listenWhen: (AttendanceState previous, AttendanceState current) =>
                previous.leaveSubmitInProgress && !current.leaveSubmitInProgress,
            listener: (BuildContext context, AttendanceState state) {
              if (state.error == null && Navigator.of(dialogContext).canPop()) {
                Navigator.of(dialogContext).pop();
              }
            },
            child: Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
              backgroundColor: Colors.transparent,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: BlocBuilder<AttendanceBloc, AttendanceState>(
                  builder: (BuildContext context, AttendanceState dialogState) {
                    return AmsApplyLeaveTab(
                      leaveTypes: _leaveTypes(dialogState),
                      isSubmitting: dialogState.leaveSubmitInProgress,
                      isCalculatingDays: dialogState.leaveDaysCalculationInProgress,
                      calculatedTotalDays: dialogState.calculatedTotalDays,
                      calculatedHolidayCount: dialogState.calculatedHolidayCount,
                      calculatedWeekendCount: dialogState.calculatedWeekendCount,
                      prefill: prefill,
                      onCalculateDays: ({
                        required String startDate,
                        required String startHalf,
                        required String endDate,
                        required String endHalf,
                      }) {
                        bloc.add(
                          AttendanceLeaveDaysCalculationRequested(
                            startDate: startDate,
                            startHalf: startHalf,
                            endDate: endDate,
                            endHalf: endHalf,
                          ),
                        );
                      },
                      onClearCalculatedDays: () => bloc.add(const AttendanceLeaveDaysCalculationCleared()),
                      onClose: () {
                        if (Navigator.of(dialogContext).canPop()) {
                          Navigator.of(dialogContext).pop();
                        }
                      },
                      onSubmit: ({
                        int? leaveId,
                        required int leaveTypeId,
                        required String startDate,
                        required String startHalf,
                        required String endDate,
                        required String endHalf,
                        required String reason,
                      }) {
                        bloc.add(
                          AttendanceLeaveSubmitted(
                            leaveId: leaveId,
                            leaveTypeId: leaveTypeId,
                            startDate: startDate,
                            startHalf: startHalf,
                            endDate: endDate,
                            endHalf: endHalf,
                            reason: reason,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const TemplateFeatureDrawer(),
      appBar: const CustomAppBar(title: 'Attendance Management'),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[AppColors.kcDarkGradientTop, AppColors.kcDarkGradientBottom],
          ),
        ),
        child: BlocBuilder<AttendanceBloc, AttendanceState>(
          builder: (BuildContext context, AttendanceState state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(state.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 24, letterSpacing: -0.5)),
                  const SizedBox(height: 16),
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: state.stats.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.8,
                    ),
                    itemBuilder: (BuildContext context, int index) => AmsStatCard(item: state.stats[index]),
                  ),
                  const SizedBox(height: 12),
                  AmsSummaryCard(summary: state.summary),
                  const SizedBox(height: 16),
                  AmsFilterTabs(
                    items: const <String>['My Leaves', 'Apply Leave', 'Comp Off', 'Calendar'],
                    selectedIndex: state.selectedFilterIndex,
                    onTap: (int index) => context.read<AttendanceBloc>().add(AttendanceFilterChanged(index)),
                  ),
                  const SizedBox(height: 10),
                  if (state.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(state.error!, style: const TextStyle(color: AppColors.kcDarkErrorText, fontWeight: FontWeight.w600, fontSize: 12)),
                    ),
                  if (state.successMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(state.successMessage!, style: const TextStyle(color: Color(0xFF30D48A), fontWeight: FontWeight.w600, fontSize: 12)),
                    ),
                  if (state.selectedFilterIndex == 0)
                    AmsMyLeavesTab(
                      isLoading: state.leavesLoading,
                      items: state.leaveRequests,
                      fiscalYears: state.fiscalYears,
                      selectedFiscalYear: state.selectedFiscalYear,
                      onFiscalYearChanged: (String fy) => context.read<AttendanceBloc>().add(AttendanceFiscalYearChanged(fy)),
                      actionInProgressId: state.leaveActionInProgressId,
                      onEdit: (LeaveRequestEntity leave) => _openEditLeaveDialog(context, leave),
                      onCancel: (id) => context.read<AttendanceBloc>().add(AttendanceLeaveCancelRequested(id)),
                    )
                  else if (state.selectedFilterIndex == 1)
                        AmsApplyLeaveTab(
                          leaveTypes: _leaveTypes(state),
                          isSubmitting: state.leaveSubmitInProgress,
                          isCalculatingDays: state.leaveDaysCalculationInProgress,
                          calculatedTotalDays: state.calculatedTotalDays,
                          calculatedHolidayCount: state.calculatedHolidayCount,
                          calculatedWeekendCount: state.calculatedWeekendCount,
                          prefill: _leavePrefill(state),
                          onCalculateDays: ({
                            required String startDate,
                            required String startHalf,
                            required String endDate,
                            required String endHalf,
                          }) {
                            context.read<AttendanceBloc>().add(
                                  AttendanceLeaveDaysCalculationRequested(
                                    startDate: startDate,
                                    startHalf: startHalf,
                                    endDate: endDate,
                                    endHalf: endHalf,
                                  ),
                                );
                          },
                          onClearCalculatedDays: () =>
                              context.read<AttendanceBloc>().add(const AttendanceLeaveDaysCalculationCleared()),
                          onSubmit: ({
                            int? leaveId,
                            required int leaveTypeId,
                        required String startDate,
                        required String startHalf,
                        required String endDate,
                        required String endHalf,
                        required String reason,
                      }) {
                        context.read<AttendanceBloc>().add(
                              AttendanceLeaveSubmitted(
                                leaveId: leaveId,
                                leaveTypeId: leaveTypeId,
                                startDate: startDate,
                                startHalf: startHalf,
                                endDate: endDate,
                                endHalf: endHalf,
                                reason: reason,
                              ),
                            );
                      },
                    )
                  else if (state.selectedFilterIndex == 2)
                    AmsCompOffTab(
                      isSubmitting: state.compOffSubmitInProgress,
                      history: state.compOffHistory,
                          onSubmit: ({
                            required String workedDate,
                            required String leaveDays,
                            required String reason,
                          }) {
                            context.read<AttendanceBloc>().add(
                                  AttendanceCompOffSubmitted(
                                    workedDate: workedDate,
                                    leaveDays: leaveDays,
                                    reason: reason,
                                  ),
                                );
                      },
                    )
                  else if (state.selectedFilterIndex == 3)
                    AmsCalendar(
                      month: state.month,
                      days: state.days,
                      legend: state.legend,
                      onPrev: () => context.read<AttendanceBloc>().add(const AttendanceMonthChanged(-1)),
                      onNext: () => context.read<AttendanceBloc>().add(const AttendanceMonthChanged(1)),
                    )
                  else
                    const SizedBox.shrink(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _leaveTypes(AttendanceState state) {
    final Map<int, String> byId = <int, String>{};
    for (final leave in state.leaveRequests) {
      final leaveType = leave.leaveType;
      if (leaveType == null) continue;
      byId[leaveType.id] = leaveType.name;
    }
    final List<Map<String, dynamic>> list = byId.entries
        .map((e) => <String, dynamic>{'id': e.key, 'name': e.value})
        .toList(growable: false)
      ..sort((a, b) => a['name'].toString().compareTo(b['name'].toString()));
    return list;
  }

  Map<String, dynamic>? _leavePrefill(AttendanceState state) {
    final leave = state.prefillLeave;
    if (leave == null) return null;
    return <String, dynamic>{
      'leaveId': leave.id,
      'leaveTypeId': leave.leaveTypeId,
      'startDate': _ymd(leave.startDate),
      'startHalf': leave.startHalf,
      'endDate': _ymd(leave.endDate),
      'endHalf': leave.endHalf,
      'reason': leave.reason,
    };
  }

  static String _ymd(DateTime d) {
    final String mm = d.month.toString().padLeft(2, '0');
    final String dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }
}
