import 'package:core/core/theme/app_colors.dart';
import 'package:core/features/attendance/domain/entities/comp_off_request_entity.dart';
import 'package:core/features/attendance/domain/entities/leave_request_entity.dart';
import 'package:core/features/attendance/presentation/widgets/ams_status_pill.dart';
import 'package:flutter/material.dart';

class AmsApprovalsTab extends StatefulWidget {
  const AmsApprovalsTab({
    required this.isLoading,
    required this.pendingLeaves,
    required this.pendingCompOffs,
    required this.approvedLeaves,
    required this.actionInProgressId,
    required this.onApproveLeave,
    required this.onRejectLeave,
    required this.onApproveCompOff,
    required this.onRejectCompOff,
    required this.onDeleteApprovedLeave,
    super.key,
  });

  final bool isLoading;
  final List<LeaveRequestEntity> pendingLeaves;
  final List<CompOffRequestEntity> pendingCompOffs;
  final List<LeaveRequestEntity> approvedLeaves;
  final int? actionInProgressId;
  final void Function(int leaveId, String note) onApproveLeave;
  final void Function(int leaveId, String note) onRejectLeave;
  final ValueChanged<int> onApproveCompOff;
  final ValueChanged<int> onRejectCompOff;
  final ValueChanged<int> onDeleteApprovedLeave;

  @override
  State<AmsApprovalsTab> createState() => _AmsApprovalsTabState();
}

class _AmsApprovalsTabState extends State<AmsApprovalsTab> {
  late final ScrollController _pendingScrollCtrl;
  late final ScrollController _compOffScrollCtrl;
  late final ScrollController _approvedScrollCtrl;

  @override
  void initState() {
    super.initState();
    _pendingScrollCtrl = ScrollController();
    _compOffScrollCtrl = ScrollController();
    _approvedScrollCtrl = ScrollController();
  }

  @override
  void dispose() {
    _pendingScrollCtrl.dispose();
    _compOffScrollCtrl.dispose();
    _approvedScrollCtrl.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime d) {
    final String dd = d.day.toString().padLeft(2, '0');
    final String mm = d.month.toString().padLeft(2, '0');
    final String yyyy = d.year.toString();
    return '$dd/$mm/$yyyy';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.kcDarkCard : AppColors.kcLightCard;
    final borderColor = isDark ? AppColors.kcDarkBorderStrong : AppColors.kcLightBorder;
    final titleColor = isDark ? Colors.white : AppColors.kcLightTitle;
    final mutedColor = isDark ? AppColors.kcDarkTextFaint : AppColors.kcLightTextMuted;

    if (widget.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // ─── Pending Leave Requests ─────────────────────────
        _buildSectionCard(
          title: 'Pending Leave Requests (${widget.pendingLeaves.length})',
          isDark: isDark,
          cardBg: cardBg,
          borderColor: borderColor,
          titleColor: titleColor,
          mutedColor: mutedColor,
          child: widget.pendingLeaves.isEmpty
              ? _emptyMessage('No pending leave requests', mutedColor)
              : _buildPendingLeaveTable(isDark),
        ),
        const SizedBox(height: 14),
        // ─── Pending Comp-Off Requests ──────────────────────
        _buildSectionCard(
          title: 'Pending Comp-Off Requests (${widget.pendingCompOffs.length})',
          isDark: isDark,
          cardBg: cardBg,
          borderColor: borderColor,
          titleColor: titleColor,
          mutedColor: mutedColor,
          child: widget.pendingCompOffs.isEmpty
              ? _emptyMessage('No pending comp-off requests', mutedColor)
              : _buildPendingCompOffTable(isDark),
        ),
        const SizedBox(height: 14),
        // ─── Approved Leaves ────────────────────────────────
        _buildSectionCard(
          title: 'Approved Leaves (${widget.approvedLeaves.length})',
          isDark: isDark,
          cardBg: cardBg,
          borderColor: borderColor,
          titleColor: titleColor,
          mutedColor: mutedColor,
          child: widget.approvedLeaves.isEmpty
              ? _emptyMessage('No approved leave requests', mutedColor)
              : _buildApprovedLeaveTable(isDark),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
    required Color titleColor,
    required Color mutedColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: TextStyle(color: titleColor, fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _emptyMessage(String text, Color color) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Center(child: Text(text, style: TextStyle(color: color, fontSize: 12))),
      );

  // ──────────── PENDING LEAVE TABLE ────────────

  Widget _buildPendingLeaveTable(bool isDark) {
    final titleColor = isDark ? Colors.white : AppColors.kcLightTitle;
    final bodyColor = isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTextPrimary;
    final labelColor = isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextMuted;
    final secondaryColor = isDark ? AppColors.kcDarkTextSecondary : AppColors.kcLightTextSecondary;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Scrollbar(
          controller: _pendingScrollCtrl,
          thumbVisibility: true,
          trackVisibility: true,
          radius: const Radius.circular(10),
          thickness: 4,
          child: SingleChildScrollView(
            controller: _pendingScrollCtrl,
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth, maxWidth: 780),
              child: Column(
                children: <Widget>[
                  _pendingLeaveHeader(labelColor),
                  const SizedBox(height: 6),
                  ...widget.pendingLeaves.map((LeaveRequestEntity e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _pendingLeaveRow(e, titleColor, bodyColor, secondaryColor, isDark),
                      )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _pendingLeaveHeader(Color labelColor) {
    const TextStyle style = TextStyle(fontSize: 11, fontWeight: FontWeight.w600);
    return Row(
      children: <Widget>[
        SizedBox(width: 100, child: Text('User', style: style.copyWith(color: labelColor))),
        SizedBox(width: 100, child: Text('Type', style: style.copyWith(color: labelColor))),
        SizedBox(width: 140, child: Text('Dates', style: style.copyWith(color: labelColor))),
        SizedBox(width: 44, child: Text('Days', textAlign: TextAlign.center, style: style.copyWith(color: labelColor))),
        SizedBox(width: 180, child: Text('Reason', style: style.copyWith(color: labelColor))),
        SizedBox(width: 130, child: Text('Applied On', style: style.copyWith(color: labelColor))),
        SizedBox(width: 80, child: Text('Actions', textAlign: TextAlign.center, style: style.copyWith(color: labelColor))),
      ],
    );
  }

  Widget _pendingLeaveRow(LeaveRequestEntity e, Color titleColor, Color bodyColor, Color secondaryColor, bool isDark) {
    final String userName = e.user?.fullName ?? 'Unknown';
    final String type = e.leaveType?.name ?? 'Leave';
    final String dates = _fmtDate(e.startDate) == _fmtDate(e.endDate) ? _fmtDate(e.startDate) : '${_fmtDate(e.startDate)} - ${_fmtDate(e.endDate)}';
    final bool isActionInProgress = widget.actionInProgressId == e.id;

    return Row(
      children: <Widget>[
        SizedBox(width: 100, child: Text(userName, overflow: TextOverflow.ellipsis, style: TextStyle(color: titleColor, fontWeight: FontWeight.w700, fontSize: 12))),
        SizedBox(
          width: 100,
          child: Row(
            children: <Widget>[
              Flexible(child: Text(type, overflow: TextOverflow.ellipsis, style: TextStyle(color: bodyColor, fontSize: 12))),
              if (e.isUnpaid) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF7A2F2F) : const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('Unpaid', style: TextStyle(color: isDark ? Colors.white : const Color(0xFFD32F2F), fontSize: 9, fontWeight: FontWeight.w700)),
                ),
              ],
            ],
          ),
        ),
        SizedBox(width: 140, child: Text(dates, style: TextStyle(color: bodyColor, fontSize: 12))),
        SizedBox(width: 44, child: Text(e.totalDays.toString(), textAlign: TextAlign.center, style: TextStyle(color: titleColor, fontWeight: FontWeight.w700, fontSize: 12))),
        SizedBox(width: 180, child: Text(e.reason, overflow: TextOverflow.ellipsis, style: TextStyle(color: secondaryColor, fontSize: 12))),
        SizedBox(width: 130, child: Text(_fmtDate(e.createdAt), style: TextStyle(color: secondaryColor, fontSize: 12))),
        SizedBox(
          width: 80,
          child: isActionInProgress
              ? const Center(child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 1.8)))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      onTap: () => _showApproveDialog(e.id),
                      child: const Icon(Icons.check_circle_outline, size: 18, color: Color(0xFF4CAF50)),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _showRejectDialog(e.id),
                      child: const Icon(Icons.cancel_outlined, size: 18, color: Color(0xFFF44336)),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  // ──────────── PENDING COMP OFF TABLE ────────────

  Widget _buildPendingCompOffTable(bool isDark) {
    final titleColor = isDark ? Colors.white : AppColors.kcLightTitle;
    final bodyColor = isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTextPrimary;
    final labelColor = isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextMuted;
    final secondaryColor = isDark ? AppColors.kcDarkTextSecondary : AppColors.kcLightTextSecondary;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Scrollbar(
          controller: _compOffScrollCtrl,
          thumbVisibility: true,
          trackVisibility: true,
          radius: const Radius.circular(10),
          thickness: 4,
          child: SingleChildScrollView(
            controller: _compOffScrollCtrl,
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth, maxWidth: 620),
              child: Column(
                children: <Widget>[
                  _compOffHeader(labelColor),
                  const SizedBox(height: 6),
                  ...widget.pendingCompOffs.map((CompOffRequestEntity e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _compOffRow(e, titleColor, bodyColor, secondaryColor),
                      )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _compOffHeader(Color labelColor) {
    const TextStyle style = TextStyle(fontSize: 11, fontWeight: FontWeight.w600);
    return Row(
      children: <Widget>[
        SizedBox(width: 120, child: Text('User', style: style.copyWith(color: labelColor))),
        SizedBox(width: 120, child: Text('Worked Date', style: style.copyWith(color: labelColor))),
        SizedBox(width: 160, child: Text('Reason', style: style.copyWith(color: labelColor))),
        SizedBox(width: 50, child: Text('Days', textAlign: TextAlign.center, style: style.copyWith(color: labelColor))),
        SizedBox(width: 80, child: Text('Actions', textAlign: TextAlign.center, style: style.copyWith(color: labelColor))),
      ],
    );
  }

  Widget _compOffRow(CompOffRequestEntity e, Color titleColor, Color bodyColor, Color secondaryColor) {
    final String userName = e.user?.fullName ?? 'Unknown';
    final bool isActionInProgress = widget.actionInProgressId == e.id;

    return Row(
      children: <Widget>[
        SizedBox(width: 120, child: Text(userName, overflow: TextOverflow.ellipsis, style: TextStyle(color: titleColor, fontWeight: FontWeight.w700, fontSize: 12))),
        SizedBox(width: 120, child: Text(_fmtDate(e.workedDate), style: TextStyle(color: bodyColor, fontSize: 12))),
        SizedBox(width: 160, child: Text(e.reason, overflow: TextOverflow.ellipsis, style: TextStyle(color: secondaryColor, fontSize: 12))),
        SizedBox(width: 50, child: Text(e.leaveDays.toString(), textAlign: TextAlign.center, style: TextStyle(color: titleColor, fontWeight: FontWeight.w700, fontSize: 12))),
        SizedBox(
          width: 80,
          child: isActionInProgress
              ? const Center(child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 1.8)))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      onTap: () => widget.onApproveCompOff(e.id),
                      child: const Icon(Icons.check_circle_outline, size: 18, color: Color(0xFF4CAF50)),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => widget.onRejectCompOff(e.id),
                      child: const Icon(Icons.cancel_outlined, size: 18, color: Color(0xFFF44336)),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  // ──────────── APPROVED LEAVE TABLE ────────────

  Widget _buildApprovedLeaveTable(bool isDark) {
    final titleColor = isDark ? Colors.white : AppColors.kcLightTitle;
    final bodyColor = isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTextPrimary;
    final labelColor = isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextMuted;
    final secondaryColor = isDark ? AppColors.kcDarkTextSecondary : AppColors.kcLightTextSecondary;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Scrollbar(
          controller: _approvedScrollCtrl,
          thumbVisibility: true,
          trackVisibility: true,
          radius: const Radius.circular(10),
          thickness: 4,
          child: SingleChildScrollView(
            controller: _approvedScrollCtrl,
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth, maxWidth: 760),
              child: Column(
                children: <Widget>[
                  _approvedLeaveHeader(labelColor),
                  const SizedBox(height: 6),
                  ...widget.approvedLeaves.map((LeaveRequestEntity e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _approvedLeaveRow(e, titleColor, bodyColor, secondaryColor, isDark),
                      )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _approvedLeaveHeader(Color labelColor) {
    const TextStyle style = TextStyle(fontSize: 11, fontWeight: FontWeight.w600);
    return Row(
      children: <Widget>[
        SizedBox(width: 100, child: Text('User', style: style.copyWith(color: labelColor))),
        SizedBox(width: 100, child: Text('Type', style: style.copyWith(color: labelColor))),
        SizedBox(width: 140, child: Text('Dates', style: style.copyWith(color: labelColor))),
        SizedBox(width: 44, child: Text('Days', textAlign: TextAlign.center, style: style.copyWith(color: labelColor))),
        SizedBox(width: 180, child: Text('Reason', style: style.copyWith(color: labelColor))),
        SizedBox(width: 60, child: Text('Delete', textAlign: TextAlign.center, style: style.copyWith(color: labelColor))),
      ],
    );
  }

  Widget _approvedLeaveRow(LeaveRequestEntity e, Color titleColor, Color bodyColor, Color secondaryColor, bool isDark) {
    final String userName = e.user?.fullName ?? 'Unknown';
    final String type = e.leaveType?.name ?? 'Leave';
    final String dates = _fmtDate(e.startDate) == _fmtDate(e.endDate) ? _fmtDate(e.startDate) : '${_fmtDate(e.startDate)} - ${_fmtDate(e.endDate)}';
    final bool isActionInProgress = widget.actionInProgressId == e.id;

    return Row(
      children: <Widget>[
        SizedBox(width: 100, child: Text(userName, overflow: TextOverflow.ellipsis, style: TextStyle(color: titleColor, fontWeight: FontWeight.w700, fontSize: 12))),
        SizedBox(width: 100, child: Text(type, overflow: TextOverflow.ellipsis, style: TextStyle(color: bodyColor, fontSize: 12))),
        SizedBox(width: 140, child: Text(dates, style: TextStyle(color: bodyColor, fontSize: 12))),
        SizedBox(width: 44, child: Text(e.totalDays.toString(), textAlign: TextAlign.center, style: TextStyle(color: titleColor, fontWeight: FontWeight.w700, fontSize: 12))),
        SizedBox(width: 180, child: Text(e.reason, overflow: TextOverflow.ellipsis, style: TextStyle(color: secondaryColor, fontSize: 12))),
        SizedBox(
          width: 60,
          child: isActionInProgress
              ? const Center(child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 1.8)))
              : Center(
                  child: InkWell(
                    onTap: () => _showDeleteDialog(e.id),
                    child: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFF44336)),
                  ),
                ),
        ),
      ],
    );
  }

  // ──────────── DIALOGS ────────────

  void _showApproveDialog(int leaveId) {
    final TextEditingController noteCtrl = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? AppColors.kcBackgroundColorDark : AppColors.kcLightCard;
    final titleColor = isDark ? Colors.white : AppColors.kcLightTitle;
    final secondaryColor = isDark ? AppColors.kcDarkTextSecondary : AppColors.kcLightTextSecondary;

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: dialogBg,
        title: Text('Approve Leave', style: TextStyle(color: titleColor, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Add a note (optional):', style: TextStyle(color: secondaryColor, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: noteCtrl,
              maxLines: 2,
              style: TextStyle(color: titleColor),
              decoration: InputDecoration(
                hintText: 'e.g. Enjoy your time off!',
                hintStyle: TextStyle(color: isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextMuted),
                filled: true,
                fillColor: isDark ? const Color(0xFF0C1730) : AppColors.kcLightInput,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: isDark ? AppColors.kcDarkBorderStrong : AppColors.kcLightBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: AppColors.kcPrimaryColor),
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              widget.onApproveLeave(leaveId, noteCtrl.text.trim());
            },
            child: const Text('Approve', style: TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(int leaveId) {
    final TextEditingController noteCtrl = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? AppColors.kcBackgroundColorDark : AppColors.kcLightCard;
    final titleColor = isDark ? Colors.white : AppColors.kcLightTitle;
    final secondaryColor = isDark ? AppColors.kcDarkTextSecondary : AppColors.kcLightTextSecondary;

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: dialogBg,
        title: Text('Reject Leave', style: TextStyle(color: titleColor, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Add a note (optional):', style: TextStyle(color: secondaryColor, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: noteCtrl,
              maxLines: 2,
              style: TextStyle(color: titleColor),
              decoration: InputDecoration(
                hintText: 'Reason for rejection...',
                hintStyle: TextStyle(color: isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextMuted),
                filled: true,
                fillColor: isDark ? const Color(0xFF0C1730) : AppColors.kcLightInput,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: isDark ? AppColors.kcDarkBorderStrong : AppColors.kcLightBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: AppColors.kcPrimaryColor),
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              widget.onRejectLeave(leaveId, noteCtrl.text.trim());
            },
            child: const Text('Reject', style: TextStyle(color: Color(0xFFF44336), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(int leaveId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? AppColors.kcBackgroundColorDark : AppColors.kcLightCard;
    final titleColor = isDark ? Colors.white : AppColors.kcLightTitle;
    final secondaryColor = isDark ? AppColors.kcDarkTextSecondary : AppColors.kcLightTextSecondary;

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: dialogBg,
        title: Text('Delete approved leave?', style: TextStyle(color: titleColor, fontWeight: FontWeight.w700)),
        content: Text('This will permanently delete this approved leave record.', style: TextStyle(color: secondaryColor)),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              widget.onDeleteApprovedLeave(leaveId);
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFF44336), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
