import 'package:core/core/theme/app_colors.dart';
import 'package:core/features/auth/domain/entities/user_entity.dart';
import 'package:core/features/projects/domain/entities/project_entity.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/features/capacity_planner/presentation/bloc/capacity_planner_bloc.dart';
import 'package:core/features/capacity_planner/presentation/bloc/capacity_planner_event.dart';
import 'package:core/features/capacity_planner/presentation/bloc/capacity_planner_state.dart';
import 'package:core/features/capacity_planner/domain/entities/capacity_plan_entity.dart';
import 'package:core/core/widgets/custom_app_bar.dart';
import 'package:core/core/widgets/template_feature_drawer.dart';
import 'package:core/features/capacity_planner/presentation/widgets/add_allocation_dialog.dart';

class CapacityPlannerScreen extends StatefulWidget {
  const CapacityPlannerScreen({super.key});

  @override
  State<CapacityPlannerScreen> createState() => _CapacityPlannerScreenState();
}

enum CapacityViewType { quarterly, monthly, weekly, custom }

class _CapacityPlannerScreenState extends State<CapacityPlannerScreen> {
  DateTime _startDate = DateTime(2026, 4, 1);
  DateTime _endDate = DateTime(2026, 6, 30);

  CapacityViewType _viewType = CapacityViewType.quarterly;
  bool _isQuarterlyMonthlyView = true;
  bool _showNumbers = true;
  bool _isMonthlyWeeklyView = true;
  String? _selectedMemberId;
  DateTime? _detailedViewStartDate;
  DateTime? _detailedViewEndDate;

  @override
  void initState() {
    super.initState();
    context.read<CapacityPlannerBloc>().add(
      LoadCapacityPlans(startDate: _startDate, endDate: _endDate),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.kcDarkPage
        : AppColors.kcLightPage;

    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: const TemplateFeatureDrawer(),
      appBar: const CustomAppBar(title: 'Capacity Planner'),
      floatingActionButton:
          BlocBuilder<CapacityPlannerBloc, CapacityPlannerState>(
            builder: (context, state) {
              if (state is CapacityPlannerLoaded) {
                return FloatingActionButton.extended(
                  onPressed: () => _showAddAllocationDialog(
                    context,
                    state.users,
                    state.projects,
                  ),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Add Allocation',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: AppColors.kcPrimaryColor,
                );
              }
              return const SizedBox.shrink();
            },
          ),
      body: BlocBuilder<CapacityPlannerBloc, CapacityPlannerState>(
        builder: (context, state) {
          if (state is CapacityPlannerLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CapacityPlannerError) {
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: TextStyle(color: Colors.red),
              ),
            );
          } else if (state is CapacityPlannerLoaded) {
            return _buildContent(context, state, isDark);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _changeWeek(int delta) {
    setState(() {
      if (_detailedViewStartDate != null) {
        _detailedViewStartDate = _detailedViewStartDate!.add(Duration(days: delta * 7));
        _detailedViewEndDate = _detailedViewStartDate!.add(const Duration(days: 6));
      } else {
        _startDate = _startDate.add(Duration(days: delta * 7));
        _endDate = _startDate.add(const Duration(days: 6));
        // Optionally switch to weekly view if not already
        if (_viewType != CapacityViewType.weekly && _viewType != CapacityViewType.custom) {
          _viewType = CapacityViewType.weekly;
        }
      }
    });
    _fetchData();
  }

  void _showAddAllocationDialog(
    BuildContext context,
    List<UserEntity> users,
    List<ProjectEntity> projects,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AddAllocationDialog(
        members: users,
        projects: projects,
        onAdd: (userId, projectId, startDate, endDate, isOngoing, hoursPerDay) {
          context.read<CapacityPlannerBloc>().add(
            CreateCapacityPlan(
              userId: userId,
              projectId: projectId,
              startDate: startDate,
              endDate: endDate,
              isOngoing: isOngoing,
              hoursPerDay: hoursPerDay,
            ),
          );
        },
      ),
    );
  }

  void _showEditAllocationDialog(
    BuildContext context,
    List<UserEntity> users,
    List<ProjectEntity> projects,
    CapacityPlanEntity allocation,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AddAllocationDialog(
        members: users,
        projects: projects,
        initialAllocation: allocation,
        onAdd: (_, __, ___, ____, _____, ______) {},
        onUpdate: (planId, userId, projectId, startDate, endDate, isOngoing, hoursPerDay) {
          context.read<CapacityPlannerBloc>().add(
            UpdateCapacityPlan(
              planId: planId,
              userId: userId,
              projectId: projectId,
              startDate: startDate,
              endDate: endDate,
              isOngoing: isOngoing,
              hoursPerDay: hoursPerDay,
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int planId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Allocation'),
        content: const Text('Are you sure you want to delete this allocation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<CapacityPlannerBloc>().add(
                DeleteCapacityPlan(planId),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    CapacityPlannerLoaded state,
    bool isDark,
  ) {
    if (_selectedMemberId != null) {
      return _buildDetailedView(state, isDark);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderControls(isDark),
          const SizedBox(height: 16),
          _buildSummaryCards(state, isDark),
          const SizedBox(height: 24),
          _buildTableControls(isDark),
          const SizedBox(height: 12),
          _buildDataTable(state, isDark),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildDetailedView(CapacityPlannerLoaded state, bool isDark) {
    final user = state.users.firstWhere((u) => u.id == _selectedMemberId);
    final userPlans = state.plans.where((p) => p.user.id == user.id).toList();

    final textColor = isDark
        ? AppColors.kcDarkTextPrimary
        : AppColors.kcLightTextPrimary;
    final mutedColor = isDark
        ? AppColors.kcDarkTextMuted
        : AppColors.kcLightTextMuted;
    final cardColor = isDark ? AppColors.kcDarkCard : AppColors.kcLightCard;
    final borderColor = isDark
        ? AppColors.kcDarkBorderSoft
        : AppColors.kcLightBorder;

    // Calculate stats for the period
    double totalBillable = 0;
    double totalInternal = 0;
    int periodWorkDays = 0;
    DateTime current = _startDate;
    while (current.isBefore(_endDate) || current.isAtSameMomentAs(_endDate)) {
      if (current.weekday >= DateTime.monday &&
          current.weekday <= DateTime.friday) {
        periodWorkDays++;
      }
      current = current.add(const Duration(days: 1));
    }
    final double periodCapacity = periodWorkDays * 8.0;

    for (var plan in userPlans) {
      final hours = _getPlanHoursForPeriod(plan, _startDate, _endDate);
      if (plan.project.isBillable) {
        totalBillable += hours;
      } else {
        totalInternal += hours;
      }
    }

    final totalAllocated = totalBillable + totalInternal;
    final double utilizationPct = periodCapacity > 0
        ? (totalAllocated / periodCapacity * 100)
        : 0;
    final double availableHours = (periodCapacity - totalAllocated).clamp(
      0,
      periodCapacity,
    );
    // Calculate weekly stats for the independent section
    final weekStart = _detailedViewStartDate ?? _startDate;
    final weekEnd = _detailedViewEndDate ?? _endDate;
    double weekBillable = 0;
    double weekInternal = 0;
    int weekWorkDays = 0;
    DateTime weekCurr = weekStart;
    while (weekCurr.isBefore(weekEnd) || weekCurr.isAtSameMomentAs(weekEnd)) {
      if (weekCurr.weekday >= DateTime.monday && weekCurr.weekday <= DateTime.friday) {
        weekWorkDays++;
      }
      weekCurr = weekCurr.add(const Duration(days: 1));
    }
    final double weekCapacity = weekWorkDays * 8.0;
    for (var plan in userPlans) {
      final h = _getPlanHoursForPeriod(plan, weekStart, weekEnd);
      if (plan.project.isBillable) weekBillable += h; else weekInternal += h;
    }
    final weekTotal = weekBillable + weekInternal;
    final double weekUtilizationPct = weekCapacity > 0 ? (weekTotal / weekCapacity * 100) : 0;

    final uniqueProjects = userPlans.map((p) => p.project.id).toSet().length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderControls(isDark),
          const SizedBox(height: 16),
          _buildSummaryCards(state, isDark),
          const SizedBox(height: 24),

          // Back Button & Legend
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedMemberId = null;
                  });
                },
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Back to Overview'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: textColor,
                  side: BorderSide(color: borderColor),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _buildDetailLegendItem(
                    'Billable',
                    const Color(0xFF10B981),
                    '',
                    isDark,
                  ),
                  _buildDetailLegendItem(
                    'Internal',
                    const Color(0xFFF59E0B),
                    '',
                    isDark,
                  ),
                  _buildDetailLegendItem(
                    'Unallocated',
                    const Color(0xFFEF4444),
                    '',
                    isDark,
                  ),
                  _buildDetailLegendItem(
                    'Weekend',
                    isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    '',
                    isDark,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Member Profile & Stats Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 24,
              runSpacing: 20,
              children: [
                SizedBox(
                  width: 250,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user.firstName} ${user.lastName}',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(color: mutedColor, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatBox(
                        'ALLOCATED',
                        '${totalAllocated.toInt()}h / ${periodCapacity.toInt()}h',
                        isDark,
                      ),
                      const SizedBox(width: 12),
                      _buildStatBox(
                        'UTILIZATION',
                        '${utilizationPct.toInt()}%',
                        isDark,
                        valueColor: utilizationPct > 90
                            ? Colors.red
                            : Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      _buildStatBox(
                        'BILLABLE',
                        '${totalBillable.toInt()}h',
                        isDark,
                        valueColor: const Color(0xFF10B981),
                      ),
                      const SizedBox(width: 12),
                      _buildStatBox(
                        'INTERNAL',
                        '${totalInternal.toInt()}h',
                        isDark,
                        valueColor: const Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 12),
                      _buildStatBox(
                        'AVAILABLE',
                        '${availableHours.toInt()}h',
                        isDark,
                        valueColor: Colors.redAccent,
                      ),
                      const SizedBox(width: 12),
                      _buildStatBox('PROJECTS', '$uniqueProjects', isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Capacity Health Header
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              Text(
                'Weekly Capacity Health',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildDetailLegendItem(
                    'Billable',
                    const Color(0xFF10B981),
                    '${weekBillable.toInt()}h',
                    isDark,
                  ),
                  _buildDetailLegendItem(
                    'Internal',
                    const Color(0xFFF59E0B),
                    '${weekInternal.toInt()}h',
                    isDark,
                  ),
                  _buildDetailLegendItem('Over', Colors.red, '0h', isDark),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (weekUtilizationPct / 100).clamp(0, 1),
                  minHeight: 12,
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    weekUtilizationPct > 100 ? Colors.red : const Color(0xFF10B981),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LOW LOAD',
                    style: TextStyle(color: mutedColor, fontSize: 10),
                  ),
                  Text(
                    'TARGET RANGE (30-40H)',
                    style: TextStyle(color: mutedColor, fontSize: 10),
                  ),
                  Text(
                    'OVERLOAD',
                    style: TextStyle(color: mutedColor, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Active Projects Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.folder_open, size: 16, color: mutedColor),
                    const SizedBox(width: 8),
                    Text(
                      'ACTIVE PROJECTS',
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: userPlans
                      .map((p) => p.project.name)
                      .toSet()
                      .map(
                        (name) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: borderColor.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                name,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Daily Cards Section Header
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  Text(
                    'Daily Allocations',
                    style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  // Week Switcher inside detailed view
                  IconButton(
                    onPressed: () => _changeWeek(-1),
                    icon: Icon(Icons.chevron_left, color: mutedColor, size: 20),
                    tooltip: 'Previous Week',
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                  Text(
                    '${DateFormat('MMM d').format(_detailedViewStartDate ?? _startDate)} - ${DateFormat('MMM d, yyyy').format(_detailedViewEndDate ?? _endDate)}',
                    style: TextStyle(color: mutedColor, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  IconButton(
                    onPressed: () => _changeWeek(1),
                    icon: Icon(Icons.chevron_right, color: mutedColor, size: 20),
                    tooltip: 'Next Week',
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              Builder(
                builder: (context) {
                  double weeklyTotal = 0;
                  final start = _detailedViewStartDate ?? _startDate;
                  final end = _detailedViewEndDate ?? _endDate;
                  for (var plan in userPlans) {
                    weeklyTotal += _getPlanHoursForPeriod(plan, start, end);
                  }
                  return Text(
                    'Total Week: ${weeklyTotal.toInt()}h',
                    style: TextStyle(color: mutedColor, fontSize: 14, fontWeight: FontWeight.w600),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Daily Cards Scrollable Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: IntrinsicHeight(
              child: Row(
                children: List.generate(5, (index) {
                  final day = (_detailedViewStartDate ?? _startDate).add(Duration(days: index));
                  final dayName = [
                    'MONDAY',
                    'TUESDAY',
                    'WEDNESDAY',
                    'THURSDAY',
                    'FRIDAY',
                  ][index];
                  final dateStr = '${_getMonthName(day.month)} ${day.day}';
                  final dayPlans = userPlans
                      .where((p) => _getPlanHoursForPeriod(p, day, day) > 0)
                      .toList();
                  final dayTotal = dayPlans.fold(
                    0.0,
                    (sum, p) => sum + _getPlanHoursForPeriod(p, day, day),
                  );
  
                  return Container(
                    width: 260,
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                      boxShadow: isDark
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dayName,
                              style: TextStyle(
                                color: mutedColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: dayTotal > 8
                                    ? Colors.red.withValues(alpha: 0.1)
                                    : (dayTotal == 8
                                          ? Colors.green.withValues(alpha: 0.1)
                                          : Colors.blue.withValues(alpha: 0.1)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${dayTotal.toInt()}h',
                                style: TextStyle(
                                  color: dayTotal > 8
                                      ? Colors.red
                                      : (dayTotal == 8
                                            ? Colors.green
                                            : Colors.blue),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateStr,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (dayPlans.isEmpty)
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.event_available_outlined,
                                    color: mutedColor.withValues(alpha: 0.3),
                                    size: 40,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No allocations',
                                    style: TextStyle(
                                      color: mutedColor,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ...dayPlans.map(
                            (p) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: p.project.isBillable
                                    ? const Color(
                                        0xFF10B981,
                                      ).withValues(alpha: 0.1)
                                    : const Color(
                                        0xFFF59E0B,
                                      ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color:
                                      (p.project.isBillable
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFFF59E0B))
                                          .withValues(alpha: 0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          p.project.name.toUpperCase(),
                                          style: TextStyle(
                                            color: p.project.isBillable
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFFF59E0B),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          _showEditAllocationDialog(
                                            context,
                                            state.users,
                                            state.projects,
                                            p,
                                          );
                                        },
                                        child: Icon(
                                          Icons.edit_outlined,
                                          color: mutedColor,
                                          size: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () {
                                          _showDeleteConfirmationDialog(
                                            context,
                                            p.id,
                                          );
                                        },
                                        child: Icon(
                                          Icons.delete_outline,
                                          color: Colors.red.withValues(alpha: 0.7),
                                          size: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time_filled,
                                        color: textColor.withValues(alpha: 0.7),
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${p.hoursPerDay.toInt()} hours',
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStatBox(
    String label,
    String value,
    bool isDark, {
    Color? valueColor,
  }) {
    final mutedColor = isDark
        ? AppColors.kcDarkTextMuted
        : AppColors.kcLightTextMuted;
    final textColor = isDark
        ? AppColors.kcDarkTextPrimary
        : AppColors.kcLightTextPrimary;
    final borderColor = isDark
        ? AppColors.kcDarkBorderSoft
        : AppColors.kcLightBorder;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: mutedColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailLegendItem(
    String label,
    Color color,
    String value,
    bool isDark,
  ) {
    final textColor = isDark
        ? AppColors.kcDarkTextPrimary
        : AppColors.kcLightTextPrimary;
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text('$label $value', style: TextStyle(color: textColor, fontSize: 11)),
      ],
    );
  }

  String _getMonthName(int month) {
    return [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ][month - 1];
  }

  String _getHeaderDateText() {
    switch (_viewType) {
      case CapacityViewType.quarterly:
        final quarter = (_startDate.month - 1) ~/ 3 + 1;
        return 'Q$quarter ${_startDate.year} · ${DateFormat('MMM').format(_startDate)} – ${DateFormat('MMM').format(_endDate)} ${_startDate.year}';
      case CapacityViewType.monthly:
        return DateFormat('MMMM yyyy').format(_startDate);
      case CapacityViewType.weekly:
        return '${DateFormat('MMM d').format(_startDate)} – ${DateFormat('MMM d, yyyy').format(_endDate)}';
      case CapacityViewType.custom:
        return '${DateFormat('MMM d, yyyy').format(_startDate)}  to  ${DateFormat('MMM d, yyyy').format(_endDate)}';
    }
  }

  void _changeDateRange(int delta) {
    setState(() {
      switch (_viewType) {
        case CapacityViewType.quarterly:
          _startDate = DateTime(
            _startDate.year,
            _startDate.month + (delta * 3),
            1,
          );
          _endDate = DateTime(_startDate.year, _startDate.month + 3, 0);
          break;
        case CapacityViewType.monthly:
          _startDate = DateTime(_startDate.year, _startDate.month + delta, 1);
          _endDate = DateTime(_startDate.year, _startDate.month + 1, 0);
          break;
        case CapacityViewType.weekly:
          _startDate = _startDate.add(Duration(days: delta * 7));
          _endDate = _startDate.add(const Duration(days: 6));
          break;
        case CapacityViewType.custom:
          // Optionally shift by 1 month for custom if no specific picker is used
          _startDate = DateTime(_startDate.year, _startDate.month + delta, 1);
          _endDate = DateTime(_startDate.year, _startDate.month + 1, 0);
          break;
      }
    });
    _fetchData();
  }

  void _fetchData() {
    context.read<CapacityPlannerBloc>().add(
      LoadCapacityPlans(startDate: _startDate, endDate: _endDate),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2030, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.kcPrimaryColor,
              onPrimary: Colors.white,
              surface: const Color(0xFF1E293B),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 7));
          }
        } else {
          _endDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _startDate = _endDate.subtract(const Duration(days: 7));
          }
        }
      });
      _fetchData();
    }
  }

  Widget _buildHeaderControls(bool isDark) {
    final textColor = isDark
        ? AppColors.kcDarkTextPrimary
        : AppColors.kcLightTextPrimary;
    final borderColor = isDark
        ? AppColors.kcDarkBorderSoft
        : AppColors.kcLightBorder;

    Widget dateControl;
    if (_viewType == CapacityViewType.custom) {
      dateControl = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => _selectDate(context, true),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: textColor),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMM d, yyyy').format(_startDate),
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('to', style: TextStyle(color: textColor)),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => _selectDate(context, false),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: textColor),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMM d, yyyy').format(_endDate),
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      dateControl = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => _changeDateRange(-1),
            icon: Icon(Icons.chevron_left, color: textColor),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          Text(
            _getHeaderDateText(),
            style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _changeDateRange(1),
            icon: Icon(Icons.chevron_right, color: textColor),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      );
    }

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        dateControl,
        Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 480),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _buildTab(
                    'Quarterly',
                    CapacityViewType.quarterly,
                    isDark,
                    isFirst: true,
                  ),
                  _buildTab('Monthly', CapacityViewType.monthly, isDark),
                  _buildTab('Weekly', CapacityViewType.weekly, isDark),
                  _buildTab(
                    'Custom',
                    CapacityViewType.custom,
                    isDark,
                    isLast: true,
                  ),
                ],
              ),
            ),
            // ElevatedButton.icon(
            //   onPressed: () {
            //     final state = context.read<CapacityPlannerBloc>().state;
            //     if (state is CapacityPlannerLoaded) {
            //       _showAddAllocationDialog(
            //         context,
            //         state.users,
            //         state.projects,
            //       );
            //     }
            //   },
            //   icon: const Icon(Icons.add, size: 18),
            //   label: const Text('Add Allocation'),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: AppColors.kcPrimaryColor,
            //     foregroundColor: Colors.white,
            //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            //   ),
            // ),
          ],
        ),
      ],
    );
  }

  Widget _buildTab(
    String text,
    CapacityViewType type,
    bool isDark, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    final isSelected = _viewType == type;
    final textColor = isDark ? Colors.white : AppColors.kcLightTextPrimary;
    final mutedColor = isDark
        ? const Color(0xFF94A3B8)
        : AppColors.kcLightTextMuted;
    final selectedBg = isDark
        ? const Color(0xFF1E293B)
        : AppColors.kcPrimaryColor.withValues(alpha: 0.1);
    final borderColor = isDark
        ? const Color(0xFF334155)
        : AppColors.kcLightBorder;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _viewType = type;
            final now = DateTime.now();
            switch (type) {
              case CapacityViewType.quarterly:
                int quarter = (now.month - 1) ~/ 3;
                _startDate = DateTime(now.year, quarter * 3 + 1, 1);
                _endDate = DateTime(now.year, (quarter + 1) * 3 + 1, 0);
                break;
              case CapacityViewType.monthly:
                _startDate = DateTime(now.year, now.month, 1);
                _endDate = DateTime(now.year, now.month + 1, 0);
                break;
              case CapacityViewType.weekly:
                _startDate = now.subtract(Duration(days: now.weekday - 1));
                _endDate = _startDate.add(const Duration(days: 6));
                break;
              case CapacityViewType.custom:
                _startDate = DateTime(now.year, now.month, 1);
                _endDate = DateTime(now.year, now.month + 1, 0);
                break;
            }
          });
          _fetchData();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : Colors.transparent,
            border: isLast
                ? null
                : Border(right: BorderSide(color: borderColor)),
            borderRadius: BorderRadius.horizontal(
              left: isFirst ? const Radius.circular(8) : Radius.zero,
              right: isLast ? const Radius.circular(8) : Radius.zero,
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? textColor : mutedColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(CapacityPlannerLoaded state, bool isDark) {
    // Get unique members who have allocations
    final Map<String, List<CapacityPlanEntity>> groupedByMember = {};
    for (var plan in state.plans) {
      groupedByMember.putIfAbsent(plan.user.id, () => []).add(plan);
    }

    final uniqueMembers = <String, CapacityUserEntity>{};
    for (var plan in state.plans) {
      uniqueMembers[plan.user.id] = plan.user;
    }

    final uniqueMemberCount = uniqueMembers.length;
    final memberText = uniqueMemberCount == 1
        ? '1 member'
        : '$uniqueMemberCount members';

    double totalBillable = 0;
    double totalInternal = 0;

    // Calculate total possible capacity in the period
    int totalWorkDays = 0;
    DateTime current = _startDate;
    while (current.isBefore(_endDate) || current.isAtSameMomentAs(_endDate)) {
      if (current.weekday >= DateTime.monday &&
          current.weekday <= DateTime.friday) {
        totalWorkDays++;
      }
      current = current.add(const Duration(days: 1));
    }
    final double totalCapacityHours = uniqueMemberCount * totalWorkDays * 8.0;

    for (var plan in state.plans) {
      final hours = _getPlanHoursForPeriod(plan, _startDate, _endDate);
      if (plan.project.isBillable) {
        totalBillable += hours;
      } else {
        totalInternal += hours;
      }
    }

    final totalAllocated = totalBillable + totalInternal;
    final double billabilityPct = totalCapacityHours > 0
        ? (totalBillable / totalCapacityHours * 100)
        : 0;
    final double utilizationPct = totalCapacityHours > 0
        ? (totalAllocated / totalCapacityHours * 100)
        : 0;
    final double availableHours = (totalCapacityHours - totalAllocated).clamp(
      0,
      totalCapacityHours,
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildCard(
            'Total Capacity',
            '${totalCapacityHours.toInt()}h',
            memberText,
            isDark,
            null,
            Icons.people_outline,
          ),
          _buildCard(
            'Billability %',
            '${billabilityPct.round()}%',
            '${totalBillable.round()}h of ${totalCapacityHours.round()}h capacity',
            isDark,
            const Color(0xFF10B981),
            Icons.trending_up,
          ),
          _buildCard(
            'Utilization',
            '${utilizationPct.round()}%',
            utilizationPct > 90
                ? 'High load'
                : (utilizationPct > 60 ? 'Optimal' : 'Low load'),
            isDark,
            utilizationPct > 90
                ? const Color(0xFFEF4444)
                : (utilizationPct > 60
                      ? const Color(0xFF10B981)
                      : const Color(0xFFF59E0B)),
            Icons.trending_up,
          ),
          _buildCard(
            'Billable Hours',
            '${totalBillable.round()}h',
            '${totalAllocated > 0 ? (totalBillable / totalAllocated * 100).round() : 0}% of allocated',
            isDark,
            const Color(0xFF10B981),
            Icons.access_time,
          ),
          _buildCard(
            'Internal Hours',
            '${totalInternal.round()}h',
            '${totalAllocated > 0 ? (totalInternal / totalAllocated * 100).round() : 0}% of allocated',
            isDark,
            const Color(0xFFF59E0B),
            Icons.access_time,
          ),
          _buildCard(
            'Available Hours',
            '${availableHours.round()}h',
            availableHours < 40 ? 'Limited headroom' : 'Healthy headroom',
            isDark,
            availableHours < 40
                ? const Color(0xFFF59E0B)
                : const Color(0xFF10B981),
            Icons.calendar_today_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    String title,
    String value,
    String subtitle,
    bool isDark,
    Color? valueColor,
    IconData icon,
  ) {
    final cardColor = isDark ? AppColors.kcDarkCard : AppColors.kcLightCard;
    final borderColor = isDark
        ? AppColors.kcDarkBorderSoft
        : AppColors.kcLightBorder;
    final textColor = isDark
        ? AppColors.kcDarkTextPrimary
        : AppColors.kcLightTextPrimary;
    final mutedColor = isDark
        ? AppColors.kcDarkTextMuted
        : AppColors.kcLightTextMuted;

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: mutedColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: mutedColor, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: mutedColor, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTableControls(bool isDark) {
    final textColor = isDark
        ? AppColors.kcDarkTextPrimary
        : AppColors.kcLightTextPrimary;
    final mutedColor = isDark
        ? AppColors.kcDarkTextMuted
        : AppColors.kcLightTextMuted;

    Widget rightControls = const SizedBox.shrink();

    if (_viewType == CapacityViewType.quarterly ||
        _viewType == CapacityViewType.custom) {
      rightControls = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Weekly',
            style: TextStyle(
              color: !_isQuarterlyMonthlyView ? textColor : mutedColor,
              fontSize: 12,
            ),
          ),
          Switch(
            value: _isQuarterlyMonthlyView,
            onChanged: (val) {
              setState(() {
                _isQuarterlyMonthlyView = val;
              });
            },
            activeThumbColor: AppColors.kcPrimaryColor,
          ),
          Text(
            'Monthly',
            style: TextStyle(
              color: _isQuarterlyMonthlyView ? textColor : mutedColor,
              fontSize: 12,
            ),
          ),
        ],
      );
    } else if (_viewType == CapacityViewType.monthly) {
      rightControls = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Hide #',
            style: TextStyle(
              color: !_showNumbers ? textColor : mutedColor,
              fontSize: 12,
            ),
          ),
          Switch(
            value: _showNumbers,
            onChanged: (val) {
              setState(() {
                _showNumbers = val;
              });
            },
            activeTrackColor: AppColors.kcPrimaryColor.withValues(alpha: 0.5),
            activeThumbColor: AppColors.kcPrimaryColor,
          ),
          Text(
            'Show #',
            style: TextStyle(
              color: _showNumbers ? textColor : mutedColor,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 24),
          Text(
            'Daily',
            style: TextStyle(
              color: !_isMonthlyWeeklyView ? textColor : mutedColor,
              fontSize: 12,
            ),
          ),
          Switch(
            value: _isMonthlyWeeklyView,
            onChanged: (val) {
              setState(() {
                _isMonthlyWeeklyView = val;
              });
            },
            activeTrackColor: AppColors.kcPrimaryColor.withValues(alpha: 0.5),
            activeThumbColor: AppColors.kcPrimaryColor,
          ),
          Text(
            'Weekly',
            style: TextStyle(
              color: _isMonthlyWeeklyView ? textColor : mutedColor,
              fontSize: 12,
            ),
          ),
        ],
      );
    }

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _buildLegendItem(const Color(0xFF10B981), 'Billable', textColor),
            _buildLegendItem(const Color(0xFFF59E0B), 'Internal', textColor),
            _buildLegendItem(const Color(0xFFEF4444), 'Unallocated', textColor),
            _buildLegendItem(
              isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              'Weekend',
              textColor,
            ),
          ],
        ),
        rightControls,
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label, Color textColor) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: textColor, fontSize: 12)),
      ],
    );
  }

  Widget _buildDataTable(CapacityPlannerLoaded state, bool isDark) {
    final cardColor = isDark ? AppColors.kcDarkCard : AppColors.kcLightCard;
    final borderColor = isDark
        ? AppColors.kcDarkBorderSoft
        : AppColors.kcLightBorder;
    final textColor = isDark
        ? AppColors.kcDarkTextPrimary
        : AppColors.kcLightTextPrimary;

    // Group plans by userId
    final Map<String, List<CapacityPlanEntity>> groupedByMember = {};
    final Map<String, CapacityUserEntity> uniqueMembers = {};
    for (var plan in state.plans) {
      groupedByMember.putIfAbsent(plan.user.id, () => []).add(plan);
      uniqueMembers[plan.user.id] = plan.user;
    }

    double minTableWidth = MediaQuery.of(context).size.width - 32;
    if (_viewType == CapacityViewType.quarterly && !_isQuarterlyMonthlyView) {
      minTableWidth = 1200;
    } else if (_viewType == CapacityViewType.monthly) {
      minTableWidth = _isMonthlyWeeklyView ? 1000 : 1800;
    } else if (_viewType == CapacityViewType.weekly) {
      minTableWidth = 800;
    } else if (_viewType == CapacityViewType.quarterly &&
        _isQuarterlyMonthlyView) {
      minTableWidth = 1000;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        constraints: BoxConstraints(minWidth: minTableWidth),
        decoration: BoxDecoration(
          color: cardColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTableHeader(textColor, borderColor, minTableWidth),
              if (uniqueMembers.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 60,
                    horizontal: 24,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy_outlined,
                        size: 48,
                        color:
                            (isDark
                                    ? AppColors.kcDarkTextMuted
                                    : AppColors.kcLightTextMuted)
                                .withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Allocations Found',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'There are no project allocations for this ${_viewType == CapacityViewType.quarterly
                            ? 'quarter'
                            : _viewType == CapacityViewType.monthly
                            ? 'month'
                            : _viewType == CapacityViewType.weekly
                            ? 'week'
                            : 'period'}.',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.kcDarkTextMuted
                              : AppColors.kcLightTextMuted,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _showAddAllocationDialog(
                          context,
                          state.users,
                          state.projects,
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Allocation'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.kcPrimaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...uniqueMembers.values.map((user) {
                  final userPlans = groupedByMember[user.id] ?? [];
                  return _buildTableRow(
                    user,
                    userPlans,
                    textColor,
                    minTableWidth,
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader(
    Color textColor,
    Color borderColor,
    double totalWidth,
  ) {
    List<Widget> children = [];
    final headerStyle = TextStyle(
      color: textColor,
      fontWeight: FontWeight.bold,
      fontSize: 11,
    );

    if (_viewType == CapacityViewType.quarterly) {
      final months = [
        DateTime(_startDate.year, _startDate.month, 1),
        DateTime(_startDate.year, _startDate.month + 1, 1),
        DateTime(_startDate.year, _startDate.month + 2, 1),
      ];

      if (_isQuarterlyMonthlyView) {
        children = [
          _col(2, totalWidth, 9, Text('Team Member', style: headerStyle)),
          _col(
            1,
            totalWidth,
            9,
            Text(
              'Billability %',
              style: headerStyle,
              textAlign: TextAlign.center,
            ),
          ),
          ...months.map(
            (m) => _col(
              1,
              totalWidth,
              9,
              Text(
                DateFormat('MMM yyyy').format(m).toUpperCase(),
                style: headerStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          _col(
            1,
            totalWidth,
            9,
            Text('TOTAL', style: headerStyle, textAlign: TextAlign.center),
          ),
        ];
      } else {
        children = [
          _col(2, totalWidth, 20, Text('Team Member', style: headerStyle)),
          _col(
            1,
            totalWidth,
            20,
            Text(
              'Billability\n%',
              style: headerStyle,
              textAlign: TextAlign.center,
            ),
          ),
          ...months.map(
            (m) => _col(
              4,
              totalWidth,
              20,
              Column(
                children: [
                  Text(
                    DateFormat('MMM yyyy').format(m).toUpperCase(),
                    style: headerStyle,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(
                      4,
                      (i) => Expanded(
                        child: Text(
                          'W${i + 1}',
                          style: headerStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _col(
            5,
            totalWidth,
            20,
            Text(
              'PERIOD\nSUMMARY',
              style: headerStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ];
      }
    } else if (_viewType == CapacityViewType.monthly) {
      if (_isMonthlyWeeklyView) {
        final weeks = _getMonthWeeks(_startDate);
        children = [
          _col(
            2,
            totalWidth,
            4 + weeks.length,
            Text('Team Member', style: headerStyle),
          ),
          _col(
            1,
            totalWidth,
            4 + weeks.length,
            Text(
              'Billability %',
              style: headerStyle,
              textAlign: TextAlign.center,
            ),
          ),
          ...weeks.map(
            (w) => _col(
              1,
              totalWidth,
              4 + weeks.length,
              Column(
                children: [
                  Text('W${weeks.indexOf(w) + 1}', style: headerStyle),
                  Text(
                    '${DateFormat('MMM d').format(w.start)}–${w.end.day}',
                    style: headerStyle.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _col(
            1,
            totalWidth,
            4 + weeks.length,
            Text(
              'Monthly Summary',
              style: headerStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ];
      } else {
        final daysInMonth = DateTime(
          _startDate.year,
          _startDate.month + 1,
          0,
        ).day;
        children = [
          _col(
            3,
            totalWidth,
            8 + daysInMonth,
            Text('Team Member', style: headerStyle),
          ),
          _col(
            2,
            totalWidth,
            8 + daysInMonth,
            Text(
              'Billability %',
              style: headerStyle,
              textAlign: TextAlign.center,
            ),
          ),
          ...List.generate(daysInMonth, (i) {
            final day = DateTime(_startDate.year, _startDate.month, i + 1);
            final bool isWeekend = day.weekday > 5;
            return _col(
              1,
              totalWidth,
              8 + daysInMonth,
              Text(
                '${i + 1}',
                style: headerStyle.copyWith(
                  color: isWeekend
                      ? textColor.withValues(alpha: 0.3)
                      : textColor,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }),
          _col(
            3,
            totalWidth,
            8 + daysInMonth,
            Text(
              'Monthly Summary',
              style: headerStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ];
      }
    } else if (_viewType == CapacityViewType.weekly) {
      final days = List.generate(5, (i) => _startDate.add(Duration(days: i)));
      children = [
        _col(2, totalWidth, 9, Text('Team Member', style: headerStyle)),
        _col(
          1,
          totalWidth,
          9,
          Text(
            'Billability %',
            style: headerStyle,
            textAlign: TextAlign.center,
          ),
        ),
        ...days.map(
          (d) => _col(
            1,
            totalWidth,
            9,
            Column(
              children: [
                Text(DateFormat('EEE').format(d), style: headerStyle),
                Text(
                  DateFormat('MMM d').format(d),
                  style: headerStyle.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
        _col(
          1,
          totalWidth,
          9,
          Text('Total', style: headerStyle, textAlign: TextAlign.center),
        ),
      ];
    } else if (_viewType == CapacityViewType.custom) {
      children = [
        _col(2, totalWidth, 7, Text('Team Member', style: headerStyle)),
        _col(
          2,
          totalWidth,
          7,
          Text(
            'Billability %',
            style: headerStyle,
            textAlign: TextAlign.center,
          ),
        ),
        _col(
          3,
          totalWidth,
          7,
          Text(
            'Period Capacity',
            style: headerStyle,
            textAlign: TextAlign.center,
          ),
        ),
      ];
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(children: children),
    );
  }

  double _getPlanHoursForPeriod(
    CapacityPlanEntity plan,
    DateTime periodStart,
    DateTime periodEnd,
  ) {
    final planStart = plan.startDate;
    final planEnd = plan.isOngoing
        ? DateTime(2099, 12, 31)
        : (plan.endDate ?? plan.startDate);

    // Calculate overlap range
    final overlapStart = planStart.isAfter(periodStart)
        ? planStart
        : periodStart;
    final overlapEnd = planEnd.isBefore(periodEnd) ? planEnd : periodEnd;

    if (overlapStart.isAfter(overlapEnd)) return 0.0;

    // Count workdays in overlap range
    int workdays = 0;
    DateTime current = overlapStart;
    while (current.isBefore(overlapEnd) ||
        current.isAtSameMomentAs(overlapEnd)) {
      if (current.weekday >= DateTime.monday &&
          current.weekday <= DateTime.friday) {
        workdays++;
      }
      current = current.add(const Duration(days: 1));
    }

    return workdays * plan.hoursPerDay;
  }

  Widget _col(int flex, double totalWidth, int totalFlex, Widget child) {
    return SizedBox(width: (flex / totalFlex) * totalWidth, child: child);
  }

  List<DateTimeRange> _getMonthWeeks(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    List<DateTimeRange> weeks = [];
    DateTime current = firstDay;

    while (current.isBefore(lastDay) || current.isAtSameMomentAs(lastDay)) {
      DateTime weekStart = current;
      // Find the coming Sunday
      int daysToSunday = 7 - current.weekday;
      DateTime weekEnd = current.add(Duration(days: daysToSunday));

      if (weekEnd.isAfter(lastDay)) {
        weekEnd = lastDay;
      }

      // Adjust to only show workdays in the label (Mon-Fri)
      DateTime labelStart = weekStart;
      while (labelStart.weekday > 5 && labelStart.isBefore(weekEnd)) {
        labelStart = labelStart.add(const Duration(days: 1));
      }
      DateTime labelEnd = weekEnd;
      while (labelEnd.weekday > 5 && labelEnd.isAfter(labelStart)) {
        labelEnd = labelEnd.subtract(const Duration(days: 1));
      }

      weeks.add(DateTimeRange(start: labelStart, end: labelEnd));
      current = weekEnd.add(const Duration(days: 1));
    }
    return weeks;
  }

  Widget _buildSegmentedBar({
    required double billable,
    required double internal,
    required double totalCapacity,
    bool showNumbers = true,
  }) {
    final unallocated = (totalCapacity - billable - internal).clamp(
      0.0,
      totalCapacity,
    );

    return Container(
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          if (billable > 0)
            Expanded(
              flex: (billable * 100).toInt(),
              child: Container(
                color: const Color(0xFF10B981),
                alignment: Alignment.center,
                child: showNumbers && billable >= 8
                    ? Text(
                        '${billable.toInt()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ),
          if (internal > 0)
            Expanded(
              flex: (internal * 100).toInt(),
              child: Container(
                color: const Color(0xFFF59E0B),
                alignment: Alignment.center,
                child: showNumbers && internal >= 8
                    ? Text(
                        '${internal.toInt()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ),
          if (unallocated > 0)
            Expanded(
              flex: (unallocated * 100).toInt(),
              child: Container(
                color: const Color(0xFF884045),
                alignment: Alignment.center,
                child: showNumbers && unallocated >= 8
                    ? Text(
                        '${unallocated.toInt()}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTableRow(
    CapacityUserEntity user,
    List<CapacityPlanEntity> userPlans,
    Color textColor,
    double totalWidth,
  ) {
    final textStyle = TextStyle(color: textColor, fontSize: 13);
    final userName = '${user.firstName} ${user.lastName}';

    // Dynamic aggregation based on view range
    double totalBillable = 0;
    double totalInternal = 0;

    // Period total capacity
    int periodWorkDays = 0;
    DateTime current = _startDate;
    while (current.isBefore(_endDate) || current.isAtSameMomentAs(_endDate)) {
      if (current.weekday >= DateTime.monday &&
          current.weekday <= DateTime.friday) {
        periodWorkDays++;
      }
      current = current.add(const Duration(days: 1));
    }
    final double periodCapacity = periodWorkDays * 8.0;

    for (var plan in userPlans) {
      final hours = _getPlanHoursForPeriod(plan, _startDate, _endDate);
      if (plan.project.isBillable) {
        totalBillable += hours;
      } else {
        totalInternal += hours;
      }
    }

    final billabilityPct = periodCapacity > 0
        ? (totalBillable / periodCapacity * 100).round()
        : 0;

    List<Widget> children = [];

    if (_viewType == CapacityViewType.quarterly) {
      if (_isQuarterlyMonthlyView) {
        final months = [
          DateTime(_startDate.year, _startDate.month, 1),
          DateTime(_startDate.year, _startDate.month + 1, 1),
          DateTime(_startDate.year, _startDate.month + 2, 1),
        ];

        children = [
          _col(2, totalWidth, 9, Text(userName, style: textStyle)),
          _col(
            1,
            totalWidth,
            9,
            Text(
              '$billabilityPct%',
              style: TextStyle(
                color: const Color(0xFFF59E0B),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          ...months.map((m) {
            final mStart = m;
            final mEnd = DateTime(m.year, m.month + 1, 0);
            double mBillable = 0;
            double mInternal = 0;
            int mWorkDays = 0;
            DateTime c = mStart;
            while (c.isBefore(mEnd) || c.isAtSameMomentAs(mEnd)) {
              if (c.weekday >= DateTime.monday &&
                  c.weekday <= DateTime.friday) {
                mWorkDays++;
              }
              c = c.add(const Duration(days: 1));
            }
            for (var p in userPlans) {
              final h = _getPlanHoursForPeriod(p, mStart, mEnd);
              if (p.project.isBillable) {
                mBillable += h;
              } else {
                mInternal += h;
              }
            }
            return _col(
              1,
              totalWidth,
              9,
              _buildSegmentedBar(
                billable: mBillable,
                internal: mInternal,
                totalCapacity: mWorkDays * 8.0,
              ),
            );
          }),
          _col(
            1,
            totalWidth,
            9,
            _buildSegmentedBar(
              billable: totalBillable,
              internal: totalInternal,
              totalCapacity: periodCapacity,
            ),
          ),
        ];
      } else {
        children = [
          _col(2, totalWidth, 20, Text(userName, style: textStyle)),
          _col(
            1,
            totalWidth,
            20,
            Text(
              '$billabilityPct%',
              style: TextStyle(
                color: const Color(0xFFF59E0B),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          _col(
            12,
            totalWidth,
            20,
            _buildSegmentedBar(
              billable: totalBillable,
              internal: totalInternal,
              totalCapacity: periodCapacity,
            ),
          ),
          _col(
            5,
            totalWidth,
            20,
            _buildSegmentedBar(
              billable: totalBillable,
              internal: totalInternal,
              totalCapacity: periodCapacity,
            ),
          ),
        ];
      }
    } else if (_viewType == CapacityViewType.monthly) {
      if (_isMonthlyWeeklyView) {
        final weeks = _getMonthWeeks(_startDate);
        children = [
          _col(
            2,
            totalWidth,
            4 + weeks.length,
            Text(userName, style: textStyle),
          ),
          _col(
            1,
            totalWidth,
            4 + weeks.length,
            Text(
              '$billabilityPct%',
              style: TextStyle(
                color: const Color(0xFFF59E0B),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          ...weeks.map((w) {
            double wBillable = 0;
            double wInternal = 0;
            int wWorkDays = 0;
            DateTime c = w.start;
            while (c.isBefore(w.end) || c.isAtSameMomentAs(w.end)) {
              if (c.weekday >= DateTime.monday && c.weekday <= DateTime.friday)
                wWorkDays++;
              c = c.add(const Duration(days: 1));
            }
            for (var p in userPlans) {
              final h = _getPlanHoursForPeriod(p, w.start, w.end);
              if (p.project.isBillable)
                wBillable += h;
              else
                wInternal += h;
            }
            return _col(
              1,
              totalWidth,
              4 + weeks.length,
              _buildSegmentedBar(
                billable: wBillable,
                internal: wInternal,
                totalCapacity: wWorkDays * 8.0,
                showNumbers: _showNumbers,
              ),
            );
          }),
          _col(
            1,
            totalWidth,
            4 + weeks.length,
            _buildSegmentedBar(
              billable: totalBillable,
              internal: totalInternal,
              totalCapacity: periodCapacity,
              showNumbers: _showNumbers,
            ),
          ),
        ];
      } else {
        final daysInMonth = DateTime(
          _startDate.year,
          _startDate.month + 1,
          0,
        ).day;
        children = [
          _col(
            3,
            totalWidth,
            8 + daysInMonth,
            Text(userName, style: textStyle),
          ),
          _col(
            2,
            totalWidth,
            8 + daysInMonth,
            Text(
              '$billabilityPct%',
              style: TextStyle(
                color: const Color(0xFFF59E0B),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          ...List.generate(daysInMonth, (i) {
            final day = DateTime(_startDate.year, _startDate.month, i + 1);
            double dBillable = 0;
            double dInternal = 0;
            final bool isWorkDay =
                day.weekday >= DateTime.monday &&
                day.weekday <= DateTime.friday;

            if (isWorkDay) {
              for (var p in userPlans) {
                final h = _getPlanHoursForPeriod(p, day, day);
                if (p.project.isBillable)
                  dBillable += h;
                else
                  dInternal += h;
              }
            }

            Widget cellContent;
            if (!isWorkDay) {
              cellContent = Container(
                height: 28,
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 1),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            } else if (dBillable > 0 || dInternal > 0) {
              cellContent = _buildSegmentedBar(
                billable: dBillable,
                internal: dInternal,
                totalCapacity: 8.0,
                showNumbers: false,
              );
            } else {
              // Unallocated workday - thin line at the bottom
              cellContent = Container(
                height: 28,
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.only(bottom: 4),
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF884045),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }

            return _col(1, totalWidth, 8 + daysInMonth, cellContent);
          }),
          _col(
            3,
            totalWidth,
            8 + daysInMonth,
            _buildSegmentedBar(
              billable: totalBillable,
              internal: totalInternal,
              totalCapacity: periodCapacity,
              showNumbers: _showNumbers,
            ),
          ),
        ];
      }
    } else if (_viewType == CapacityViewType.weekly) {
      final days = List.generate(5, (i) => _startDate.add(Duration(days: i)));
      children = [
        _col(2, totalWidth, 9, Text(userName, style: textStyle)),
        _col(
          1,
          totalWidth,
          9,
          Text(
            '$billabilityPct%',
            style: TextStyle(
              color: const Color(0xFFF59E0B),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        ...days.map((day) {
          double dBillable = 0;
          double dInternal = 0;
          for (var p in userPlans) {
            final h = _getPlanHoursForPeriod(p, day, day);
            if (p.project.isBillable)
              dBillable += h;
            else
              dInternal += h;
          }
          return _col(
            1,
            totalWidth,
            9,
            _buildSegmentedBar(
              billable: dBillable,
              internal: dInternal,
              totalCapacity: 8.0,
              showNumbers: _showNumbers,
            ),
          );
        }),
        _col(
          1,
          totalWidth,
          9,
          Text(
            '${totalBillable.toInt() + totalInternal.toInt()}h',
            style: textStyle.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ];
    } else {
      // Default / Weekly / Custom view fallback
      children = [
        _col(2, totalWidth, 7, Text(userName, style: textStyle)),
        _col(
          2,
          totalWidth,
          7,
          Text(
            '$billabilityPct%',
            style: TextStyle(
              color: const Color(0xFFF59E0B),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        _col(
          3,
          totalWidth,
          7,
          _buildSegmentedBar(
            billable: totalBillable,
            internal: totalInternal,
            totalCapacity: periodCapacity,
            showNumbers: _showNumbers,
          ),
        ),
      ];
    }

    return InkWell(
      onTap: () {
        setState(() {
          _selectedMemberId = user.id;
          // Initialize detailed view dates to the week containing _startDate
          _detailedViewStartDate = _startDate.subtract(Duration(days: _startDate.weekday - 1));
          _detailedViewEndDate = _detailedViewStartDate!.add(const Duration(days: 6));
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
          ),
        ),
        child: Row(children: children),
      ),
    );
  }
}
