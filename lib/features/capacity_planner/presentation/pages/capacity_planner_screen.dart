import 'package:core/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/features/capacity_planner/presentation/bloc/capacity_planner_bloc.dart';
import 'package:core/features/capacity_planner/presentation/bloc/capacity_planner_event.dart';
import 'package:core/features/capacity_planner/presentation/bloc/capacity_planner_state.dart';
import 'package:core/features/capacity_planner/domain/entities/capacity_plan_entity.dart';
import 'package:core/core/widgets/custom_app_bar.dart';
import 'package:core/core/widgets/template_feature_drawer.dart';

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
    final backgroundColor = isDark ? AppColors.kcDarkPage : AppColors.kcLightPage;

    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: const TemplateFeatureDrawer(),
      appBar: const CustomAppBar(title: 'Capacity Planner'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Allocation', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.kcPrimaryColor,
      ),
      body: BlocBuilder<CapacityPlannerBloc, CapacityPlannerState>(
        builder: (context, state) {
          if (state is CapacityPlannerLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CapacityPlannerError) {
            return Center(child: Text('Error: ${state.message}', style: TextStyle(color: Colors.red)));
          } else if (state is CapacityPlannerLoaded) {
            return _buildContent(context, state, isDark);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, CapacityPlannerLoaded state, bool isDark) {
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
          _startDate = DateTime(_startDate.year, _startDate.month + (delta * 3), 1);
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
    final textColor = isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTextPrimary;
    final borderColor = isDark ? AppColors.kcDarkBorderSoft : AppColors.kcLightBorder;

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
              decoration: BoxDecoration(border: Border.all(color: borderColor), borderRadius: BorderRadius.circular(6)),
              child: Row(children: [Icon(Icons.calendar_today, size: 16, color: textColor), const SizedBox(width: 8), Text(DateFormat('MMM d, yyyy').format(_startDate), style: TextStyle(color: textColor))]),
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
              decoration: BoxDecoration(border: Border.all(color: borderColor), borderRadius: BorderRadius.circular(6)),
              child: Row(children: [Icon(Icons.calendar_today, size: 16, color: textColor), const SizedBox(width: 8), Text(DateFormat('MMM d, yyyy').format(_endDate), style: TextStyle(color: textColor))]),
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
                  _buildTab('Quarterly', CapacityViewType.quarterly, isDark, isFirst: true),
                  _buildTab('Monthly', CapacityViewType.monthly, isDark),
                  _buildTab('Weekly', CapacityViewType.weekly, isDark),
                  _buildTab('Custom', CapacityViewType.custom, isDark, isLast: true),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTab(String text, CapacityViewType type, bool isDark, {bool isFirst = false, bool isLast = false}) {
    final isSelected = _viewType == type;
    final textColor = isDark ? Colors.white : AppColors.kcLightTextPrimary;
    final mutedColor = isDark ? const Color(0xFF94A3B8) : AppColors.kcLightTextMuted;
    final selectedBg = isDark ? const Color(0xFF1E293B) : AppColors.kcPrimaryColor.withValues(alpha: 0.1);
    final borderColor = isDark ? const Color(0xFF334155) : AppColors.kcLightBorder;

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
                _endDate = DateTime(now.year, (quarter + 1) * 3, 0);
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
            border: isLast ? null : Border(right: BorderSide(color: borderColor)),
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
    String totalCap = '520h';
    String billability = '57%';
    String utilization = '57%';
    String billableHours = '296h';
    String internalHours = '0h';
    String availableHours = '224h';
    
    if (_viewType == CapacityViewType.monthly || _viewType == CapacityViewType.custom) {
      totalCap = '168h';
      billability = '71%';
      utilization = '71%';
      billableHours = '120h';
      availableHours = '48h';
    } else if (_viewType == CapacityViewType.weekly) {
      totalCap = '40h';
      billability = '100%';
      utilization = '100%';
      billableHours = '40h';
      availableHours = '0h';
    }

    final memberCount = state.plans.length;
    final memberText = memberCount == 1 ? '1 member' : '$memberCount members';

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildCard('Total Capacity', totalCap, memberText, isDark, null),
          _buildCard('Billability %', billability, '$billableHours of $totalCap capacity', isDark, const Color(0xFF10B981)),
          _buildCard('Utilization', utilization, utilization == '100%' ? 'High load' : (utilization == '71%' ? 'Optimal' : 'Low load'), isDark, utilization == '100%' ? const Color(0xFFEF4444) : (utilization == '71%' ? const Color(0xFF10B981) : const Color(0xFFF59E0B))),
          _buildCard('Billable Hours', billableHours, '100% of allocated', isDark, const Color(0xFF10B981)),
          _buildCard('Internal Hours', internalHours, '0% of allocated', isDark, const Color(0xFFF59E0B)),
          _buildCard('Available Hours', availableHours, availableHours == '0h' || availableHours == '48h' ? 'Limited headroom' : 'Healthy headroom', isDark, availableHours == '0h' ? const Color(0xFFF59E0B) : const Color(0xFF10B981)),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String value, String subtitle, bool isDark, Color? valueColor) {
    final cardColor = isDark ? AppColors.kcDarkCard : AppColors.kcLightCard;
    final borderColor = isDark ? AppColors.kcDarkBorderSoft : AppColors.kcLightBorder;
    final textColor = isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTextPrimary;
    final mutedColor = isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextMuted;

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
              Icon(Icons.analytics_outlined, size: 16, color: mutedColor),
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
    final textColor = isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTextPrimary;
    final mutedColor = isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextMuted;

    Widget rightControls = const SizedBox.shrink();

    if (_viewType == CapacityViewType.quarterly || _viewType == CapacityViewType.custom) {
      rightControls = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Weekly', style: TextStyle(color: !_isQuarterlyMonthlyView ? textColor : mutedColor, fontSize: 12)),
          Switch(
            value: _isQuarterlyMonthlyView,
            onChanged: (val) {
              setState(() {
                _isQuarterlyMonthlyView = val;
              });
            },
            activeThumbColor: AppColors.kcPrimaryColor,
          ),
          Text('Monthly', style: TextStyle(color: _isQuarterlyMonthlyView ? textColor : mutedColor, fontSize: 12)),
        ],
      );
    } else if (_viewType == CapacityViewType.monthly) {
      rightControls = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Hide #', style: TextStyle(color: !_showNumbers ? textColor : mutedColor, fontSize: 12)),
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
          Text('Show #', style: TextStyle(color: _showNumbers ? textColor : mutedColor, fontSize: 12)),
          const SizedBox(width: 24),
          Text('Daily', style: TextStyle(color: !_isMonthlyWeeklyView ? textColor : mutedColor, fontSize: 12)),
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
          Text('Weekly', style: TextStyle(color: _isMonthlyWeeklyView ? textColor : mutedColor, fontSize: 12)),
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
            _buildLegendItem(isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9), 'Weekend', textColor),
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
    final borderColor = isDark ? AppColors.kcDarkBorderSoft : AppColors.kcLightBorder;
    final textColor = isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTextPrimary;

    if (state.plans.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48),
        decoration: BoxDecoration(
          color: cardColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No allocations for this period. Click "Add Allocation" to get started.',
            style: TextStyle(color: isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextMuted),
          ),
        ),
      );
    }

    double minTableWidth = MediaQuery.of(context).size.width - 32;
    if (_viewType == CapacityViewType.quarterly && !_isQuarterlyMonthlyView) {
      minTableWidth = 1200; // Increased for 13 weeks
    } else if (_viewType == CapacityViewType.monthly) {
      minTableWidth = _isMonthlyWeeklyView ? 1000 : 1800;
    } else if (_viewType == CapacityViewType.weekly) {
      minTableWidth = 800;
    } else if (_viewType == CapacityViewType.quarterly && _isQuarterlyMonthlyView) {
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
              ...state.plans.map((plan) => _buildTableRow(plan, textColor, minTableWidth)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader(Color textColor, Color borderColor, double totalWidth) {
    List<Widget> children = [];
    final headerStyle = TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 11);

    if (_viewType == CapacityViewType.quarterly) {
      if (_isQuarterlyMonthlyView) {
        children = [
          _col(2, totalWidth, 9, Text('Team Member', style: headerStyle)),
          _col(1, totalWidth, 9, Text('Billability %', style: headerStyle, textAlign: TextAlign.center)),
          _col(1, totalWidth, 9, Text('APR 2026', style: headerStyle, textAlign: TextAlign.center)),
          _col(2, totalWidth, 9, Text('MAY 2026', style: headerStyle, textAlign: TextAlign.center)),
          _col(1, totalWidth, 9, Text('JUN 2026', style: headerStyle, textAlign: TextAlign.center)),
          _col(2, totalWidth, 9, Text('PERIOD SUMMARY', style: headerStyle, textAlign: TextAlign.center)),
        ];
      } else {
        children = [
          _col(2, totalWidth, 20, Text('Team Member', style: headerStyle)),
          _col(1, totalWidth, 20, Text('Billability\n%', style: headerStyle, textAlign: TextAlign.center)),
          _col(5, totalWidth, 20, Column(children: [Text('APR 2026', style: headerStyle), const SizedBox(height: 8), Row(children: List.generate(5, (i) => Expanded(child: Text('W${i + 1}', style: headerStyle, textAlign: TextAlign.center))))])),
          _col(4, totalWidth, 20, Column(children: [Text('MAY 2026', style: headerStyle), const SizedBox(height: 8), Row(children: List.generate(4, (i) => Expanded(child: Text('W${i + 6}', style: headerStyle, textAlign: TextAlign.center))))])),
          _col(4, totalWidth, 20, Column(children: [Text('JUN 2026', style: headerStyle), const SizedBox(height: 8), Row(children: List.generate(4, (i) => Expanded(child: Text('W${i + 10}', style: headerStyle, textAlign: TextAlign.center))))])),
          _col(2, totalWidth, 20, Text('PERIOD\nSUMMARY', style: headerStyle, textAlign: TextAlign.center)),
        ];
      }
    } else if (_viewType == CapacityViewType.monthly) {
      if (_isMonthlyWeeklyView) {
        children = [
          _col(2, totalWidth, 10, Text('Team Member', style: headerStyle)),
          _col(1, totalWidth, 10, Text('Billability %', style: headerStyle, textAlign: TextAlign.center)),
          _col(1, totalWidth, 10, Column(children: [Text('W1', style: headerStyle), Text('Aug 3–7', style: headerStyle.copyWith(fontSize: 9, fontWeight: FontWeight.normal))])),
          _col(1, totalWidth, 10, Column(children: [Text('W2', style: headerStyle), Text('Aug 10–14', style: headerStyle.copyWith(fontSize: 9, fontWeight: FontWeight.normal))])),
          _col(1, totalWidth, 10, Column(children: [Text('W3', style: headerStyle), Text('Aug 17–21', style: headerStyle.copyWith(fontSize: 9, fontWeight: FontWeight.normal))])),
          _col(1, totalWidth, 10, Column(children: [Text('W4', style: headerStyle), Text('Aug 24–28', style: headerStyle.copyWith(fontSize: 9, fontWeight: FontWeight.normal))])),
          _col(1, totalWidth, 10, Column(children: [Text('W5', style: headerStyle), Text('Aug 31–31', style: headerStyle.copyWith(fontSize: 9, fontWeight: FontWeight.normal))])),
          _col(2, totalWidth, 10, Text('Monthly Summary', style: headerStyle, textAlign: TextAlign.center)),
        ];
      } else {
        children = [
          _col(3, totalWidth, 40, Text('Team Member', style: headerStyle)),
          _col(2, totalWidth, 40, Text('Billability %', style: headerStyle, textAlign: TextAlign.center)),
          ...List.generate(31, (i) => _col(1, totalWidth, 40, Text('${i + 1}', style: headerStyle, textAlign: TextAlign.center))),
          _col(4, totalWidth, 40, Text('Monthly Summary', style: headerStyle, textAlign: TextAlign.center)),
        ];
      }
    } else if (_viewType == CapacityViewType.weekly) {
      children = [
        _col(2, totalWidth, 9, Text('Team Member', style: headerStyle)),
        _col(1, totalWidth, 9, Text('Billability %', style: headerStyle, textAlign: TextAlign.center)),
        _col(1, totalWidth, 9, Column(children: [Text('Mon', style: headerStyle), Text('May 11', style: headerStyle.copyWith(fontSize: 9, fontWeight: FontWeight.normal))])),
        _col(1, totalWidth, 9, Column(children: [Text('Tue', style: headerStyle), Text('May 12', style: headerStyle.copyWith(fontSize: 9, fontWeight: FontWeight.normal))])),
        _col(1, totalWidth, 9, Column(children: [Text('Wed', style: headerStyle), Text('May 13', style: headerStyle.copyWith(fontSize: 9, fontWeight: FontWeight.normal))])),
        _col(1, totalWidth, 9, Column(children: [Text('Thu', style: headerStyle), Text('May 14', style: headerStyle.copyWith(fontSize: 9, fontWeight: FontWeight.normal))])),
        _col(1, totalWidth, 9, Column(children: [Text('Fri', style: headerStyle), Text('May 15', style: headerStyle.copyWith(fontSize: 9, fontWeight: FontWeight.normal))])),
        _col(1, totalWidth, 9, Text('Total', style: headerStyle, textAlign: TextAlign.center)),
      ];
    } else if (_viewType == CapacityViewType.custom) {
      children = [
        _col(2, totalWidth, 7, Text('Team Member', style: headerStyle)),
        _col(2, totalWidth, 7, Text('Billability %', style: headerStyle, textAlign: TextAlign.center)),
        _col(3, totalWidth, 7, Text('MAY 2026', style: headerStyle, textAlign: TextAlign.center)),
      ];
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: borderColor))),
      child: Row(children: children),
    );
  }

  Widget _col(int flex, double totalWidth, int totalFlex, Widget child) {
    return SizedBox(
      width: (flex / totalFlex) * totalWidth,
      child: child,
    );
  }

  Widget _buildBlock(String text, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      height: 28,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: _showNumbers && text.isNotEmpty
          ? Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            )
          : null,
    );
  }

  Widget _buildEmptyBlock(Color color, String tooltipMessage) {
    return Tooltip(
      message: tooltipMessage,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Match dark tooltip background
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      textStyle: const TextStyle(color: Colors.white, fontSize: 13),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        height: 24,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
      ),
    );
  }

  Widget _buildTableRow(CapacityPlanEntity plan, Color textColor, double totalWidth) {
    List<Widget> children = [];
    final greenBg = const Color(0xFF10B981);
    final redBg = const Color(0xFF884045); // Dark reddish to match dark theme screenshot
    final yellowBg = const Color(0xFFF59E0B);
    final textStyle = TextStyle(color: textColor, fontSize: 13);

    final userName = '${plan.user.firstName} ${plan.user.lastName}';
    final isBillable = plan.project.isBillable;

    final billabilityColor = isBillable ? const Color(0xFFF59E0B) : const Color(0xFF60A5FA);
    final billabilityText = isBillable ? '54%' : '0%';
    final activeColor = isBillable ? greenBg : yellowBg;

    if (_viewType == CapacityViewType.quarterly) {
      if (_isQuarterlyMonthlyView) {
        children = [
          _col(2, totalWidth, 9, Text(userName, style: textStyle)),
          _col(1, totalWidth, 9, Text(billabilityText, style: TextStyle(color: billabilityColor, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
          _col(1, totalWidth, 9, _buildBlock('176h', redBg)),
          _col(2, totalWidth, 9, Row(children: [Expanded(flex: 2, child: _buildBlock('120h', activeColor)), Expanded(flex: 1, child: _buildBlock('48h', redBg))])),
          _col(1, totalWidth, 9, _buildBlock('176h', activeColor)),
          _col(2, totalWidth, 9, Row(children: [Expanded(child: _buildBlock('296h', activeColor)), Expanded(child: _buildBlock('224h', redBg))])),
        ];
      } else {
        children = [
          _col(2, totalWidth, 20, Text(userName, style: textStyle)),
          _col(1, totalWidth, 20, Text(billabilityText, style: TextStyle(color: billabilityColor, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
          _col(5, totalWidth, 20, Row(children: List.generate(5, (index) => Expanded(child: _buildEmptyBlock(redBg, '$userName • W${index + 1} • Apr\nBillable: 40h\nInternal: 0h\nAvailable: 0h'))))),
          _col(4, totalWidth, 20, Row(children: List.generate(4, (index) => Expanded(child: _buildEmptyBlock(activeColor, '$userName • W${index + 6} • May\nBillable: 40h\nInternal: 0h\nAvailable: 0h'))))),
          _col(4, totalWidth, 20, Row(children: List.generate(4, (index) => Expanded(child: _buildEmptyBlock(activeColor, '$userName • W${index + 10} • Jun\nBillable: 40h\nInternal: 0h\nAvailable: 0h'))))),
          _col(2, totalWidth, 20, Row(children: [Expanded(child: _buildBlock('296h', activeColor)), Expanded(child: _buildBlock('224h', redBg))])),
        ];
      }
    } else if (_viewType == CapacityViewType.monthly) {
      if (_isMonthlyWeeklyView) {
        children = [
          _col(2, totalWidth, 10, Text(userName, style: textStyle)),
          _col(1, totalWidth, 10, Text(billabilityText, style: TextStyle(color: billabilityColor, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
          ...List.generate(5, (i) => _col(1, totalWidth, 10, _buildBlock('168h', i % 2 == 0 ? activeColor : redBg))),
          _col(2, totalWidth, 10, Row(children: [Expanded(flex: 2, child: _buildBlock('120h', activeColor)), Expanded(flex: 1, child: _buildBlock('48h', redBg))])),
        ];
      } else {
        children = [
          _col(3, totalWidth, 40, Text(userName, style: textStyle)),
          _col(2, totalWidth, 40, Text(billabilityText, style: TextStyle(color: billabilityColor, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
          ...List.generate(31, (i) => _col(1, totalWidth, 40, _buildBlock((i + 1) % 7 == 0 || (i + 1) % 7 == 6 ? '' : '8h', (i + 1) % 7 == 0 || (i + 1) % 7 == 6 ? (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)) : activeColor))),
          _col(4, totalWidth, 40, Row(children: [Expanded(flex: 2, child: _buildBlock('120h', activeColor)), Expanded(flex: 1, child: _buildBlock('48h', redBg))])),
        ];
      }
    } else if (_viewType == CapacityViewType.weekly) {
      children = [
        _col(2, totalWidth, 9, Text(userName, style: textStyle)),
        _col(1, totalWidth, 9, Text('100%', style: TextStyle(color: activeColor, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
        _col(1, totalWidth, 9, _buildBlock('8h', activeColor)),
        _col(1, totalWidth, 9, _buildBlock('8h', activeColor)),
        _col(1, totalWidth, 9, _buildBlock('8h', activeColor)),
        _col(1, totalWidth, 9, _buildBlock('8h', activeColor)),
        _col(1, totalWidth, 9, _buildBlock('8h', activeColor)),
        _col(1, totalWidth, 9, Text('40h', style: textStyle, textAlign: TextAlign.center)),
      ];
    } else if (_viewType == CapacityViewType.custom) {
      children = [
        _col(2, totalWidth, 7, Text(userName, style: textStyle)),
        _col(2, totalWidth, 7, Text('75%', style: TextStyle(color: activeColor, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
        _col(3, totalWidth, 7, Row(children: [Expanded(flex: 2, child: _buildBlock('120h', activeColor)), Expanded(flex: 1, child: _buildBlock('48h', redBg))])),
      ];
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05)))),
      child: Row(children: children),
    );
  }
}
