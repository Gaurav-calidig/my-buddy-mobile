import 'package:core/core/theme/app_colors.dart';
import 'package:core/features/attendance/domain/entities/leave_request_entity.dart';
import 'package:core/features/attendance/presentation/widgets/ams_fy_dropdown.dart';
import 'package:core/features/attendance/presentation/widgets/ams_status_pill.dart';
import 'package:flutter/material.dart';

class AmsMyLeavesTab extends StatefulWidget {
  const AmsMyLeavesTab({
    required this.isLoading,
    required this.items,
    required this.fiscalYears,
    required this.selectedFiscalYear,
    required this.onFiscalYearChanged,
    required this.onEdit,
    required this.onCancel,
    required this.actionInProgressId,
    super.key,
  });

  final bool isLoading;
  final List<LeaveRequestEntity> items;
  final List<String> fiscalYears;
  final String selectedFiscalYear;
  final ValueChanged<String> onFiscalYearChanged;
  final ValueChanged<LeaveRequestEntity> onEdit;
  final ValueChanged<int> onCancel;
  final int? actionInProgressId;

  @override
  State<AmsMyLeavesTab> createState() => _AmsMyLeavesTabState();
}

class _AmsMyLeavesTabState extends State<AmsMyLeavesTab> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime d) {
    final String mm = d.month.toString().padLeft(2, '0');
    final String dd = d.day.toString().padLeft(2, '0');
    return '$mm/$dd/${d.year}';
  }

  String _fyLabel(DateTime date) {
    final int startYear = date.month >= 4 ? date.year : date.year - 1;
    final int endYear2 = (startYear + 1) % 100;
    final String yy = endYear2.toString().padLeft(2, '0');
    return '$startYear-$yy';
  }

  List<LeaveRequestEntity> _filtered() {
    if (widget.selectedFiscalYear.isEmpty) return widget.items;
    return widget.items.where((LeaveRequestEntity e) => _fyLabel(e.startDate) == widget.selectedFiscalYear).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final List<LeaveRequestEntity> visible = _filtered();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.kcDarkCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.kcDarkBorderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text('Leave History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              const Spacer(),
              if (widget.fiscalYears.isNotEmpty)
                AmsFyDropdown(
                  items: widget.fiscalYears,
                  value: widget.selectedFiscalYear,
                  onChanged: widget.onFiscalYearChanged,
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (widget.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
            )
          else if (visible.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(child: Text('No leave requests found.', style: TextStyle(color: AppColors.kcDarkTextFaint))),
            )
          else
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Scrollbar(
                  controller: _controller,
                  thumbVisibility: true,
                  trackVisibility: true,
                  radius: const Radius.circular(10),
                  thickness: 4,
                  child: SingleChildScrollView(
                    controller: _controller,
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: constraints.maxWidth, maxWidth: 760),
                      child: Column(
                        children: <Widget>[
                          const _WideHeader(),
                          const SizedBox(height: 6),
                          ...visible.map((LeaveRequestEntity e) => _WideRow(
                                item: e,
                                fmtDate: _fmtDate,
                                onEdit: widget.onEdit,
                                onCancel: widget.onCancel,
                                actionInProgressId: widget.actionInProgressId,
                              )),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _WideHeader extends StatelessWidget {
  const _WideHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: <Widget>[
        SizedBox(width: 92, child: Text('Type', style: TextStyle(color: AppColors.kcDarkTextMuted, fontSize: 11, fontWeight: FontWeight.w600))),
        SizedBox(width: 180, child: Text('Dates', style: TextStyle(color: AppColors.kcDarkTextMuted, fontSize: 11, fontWeight: FontWeight.w600))),
        SizedBox(width: 44, child: Text('Days', textAlign: TextAlign.center, style: TextStyle(color: AppColors.kcDarkTextMuted, fontSize: 11, fontWeight: FontWeight.w600))),
        SizedBox(width: 96, child: Text('Status', textAlign: TextAlign.center, style: TextStyle(color: AppColors.kcDarkTextMuted, fontSize: 11, fontWeight: FontWeight.w600))),
        SizedBox(width: 210, child: Text('Reason', overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.kcDarkTextMuted, fontSize: 11, fontWeight: FontWeight.w600))),
        SizedBox(width: 74, child: Text('Actions', textAlign: TextAlign.center, style: TextStyle(color: AppColors.kcDarkTextMuted, fontSize: 11, fontWeight: FontWeight.w600))),
      ],
    );
  }
}

class _WideRow extends StatelessWidget {
  const _WideRow({
    required this.item,
    required this.fmtDate,
    required this.onEdit,
    required this.onCancel,
    required this.actionInProgressId,
  });

  final LeaveRequestEntity item;
  final String Function(DateTime d) fmtDate;
  final ValueChanged<LeaveRequestEntity> onEdit;
  final ValueChanged<int> onCancel;
  final int? actionInProgressId;

  String _dates() {
    final String a = fmtDate(item.startDate);
    final String b = fmtDate(item.endDate);
    return a == b ? a : '$a - $b';
  }

  @override
  Widget build(BuildContext context) {
    final String type = item.leaveType?.name ?? 'Leave';
    return Row(
      children: <Widget>[
        SizedBox(width: 92, child: Text(type, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12))),
        SizedBox(width: 180, child: Text(_dates(), style: const TextStyle(color: AppColors.kcDarkTextPrimary, fontSize: 12))),
        SizedBox(width: 44, child: Text(item.totalDays.toString(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12))),
        SizedBox(width: 96, child: Center(child: AmsStatusPill(status: item.status))),
        SizedBox(width: 210, child: Text(item.reason, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.kcDarkTextSecondary, fontSize: 12))),
        SizedBox(
          width: 74,
          child: _ActionButtons(
            isPending: item.status.toLowerCase() == 'pending',
            loading: actionInProgressId == item.id,
            onEdit: () => onEdit(item),
            onCancel: () => onCancel(item.id),
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.isPending,
    required this.loading,
    required this.onEdit,
    required this.onCancel,
  });

  final bool isPending;
  final bool loading;
  final VoidCallback onEdit;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    if (!isPending) {
      return const Center(child: Text('-', style: TextStyle(color: AppColors.kcDarkTextMuted)));
    }
    if (loading) {
      return const Center(child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 1.8)));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        InkWell(onTap: onEdit, child: const Icon(Icons.edit_outlined, size: 15, color: AppColors.kcDarkTextSecondary)),
        const SizedBox(width: 8),
        InkWell(onTap: onCancel, child: const Icon(Icons.close, size: 15, color: AppColors.kcDarkTextSecondary)),
      ],
    );
  }
}
