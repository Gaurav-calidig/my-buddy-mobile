import 'package:core/core/theme/app_colors.dart';
import 'package:core/core/widgets/custom_app_bar.dart';
import 'package:core/core/widgets/template_feature_drawer.dart';
import 'package:core/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:core/features/attendance/presentation/bloc/attendance_event.dart';
import 'package:core/features/attendance/presentation/bloc/attendance_state.dart';
import 'package:core/features/attendance/presentation/widgets/ams_calendar.dart';
import 'package:core/features/attendance/presentation/widgets/ams_filter_tabs.dart';
import 'package:core/features/attendance/presentation/widgets/ams_stat_card.dart';
import 'package:core/features/attendance/presentation/widgets/ams_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

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
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(state.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 30)),
                  const SizedBox(height: 10),
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: state.stats.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                      childAspectRatio: 0.67,
                    ),
                    itemBuilder: (BuildContext context, int index) => AmsStatCard(item: state.stats[index]),
                  ),
                  const SizedBox(height: 8),
                  AmsSummaryCard(summary: state.summary),
                  const SizedBox(height: 10),
                  AmsFilterTabs(
                    items: const <String>['My Leaves', 'Apply Leave', 'Comp Off', 'Calendar'],
                    selectedIndex: state.selectedFilterIndex,
                    onTap: (int index) => context.read<AttendanceBloc>().add(AttendanceFilterChanged(index)),
                  ),
                  const SizedBox(height: 10),
                  AmsCalendar(
                    month: state.month,
                    days: state.days,
                    legend: state.legend,
                    onPrev: () => context.read<AttendanceBloc>().add(const AttendanceMonthChanged(-1)),
                    onNext: () => context.read<AttendanceBloc>().add(const AttendanceMonthChanged(1)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
