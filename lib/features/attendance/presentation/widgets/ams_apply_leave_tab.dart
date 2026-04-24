import 'package:core/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AmsApplyLeaveTab extends StatefulWidget {
  const AmsApplyLeaveTab({
    required this.leaveTypes,
    required this.isSubmitting,
    required this.isCalculatingDays,
    required this.onCalculateDays,
    required this.onClearCalculatedDays,
    required this.onSubmit,
    this.calculatedTotalDays,
    this.calculatedHolidayCount,
    this.calculatedWeekendCount,
    this.prefill,
    this.onClose,
    super.key,
  });

  final List<Map<String, dynamic>> leaveTypes;
  final bool isSubmitting;
  final bool isCalculatingDays;
  final num? calculatedTotalDays;
  final int? calculatedHolidayCount;
  final int? calculatedWeekendCount;
  final Map<String, dynamic>? prefill;
  final VoidCallback? onClose;
  final void Function({
    required String startDate,
    required String startHalf,
    required String endDate,
    required String endHalf,
  }) onCalculateDays;
  final VoidCallback onClearCalculatedDays;
  final void Function({
    int? leaveId,
    required int leaveTypeId,
    required String startDate,
    required String startHalf,
    required String endDate,
    required String endHalf,
    required String reason,
  }) onSubmit;

  @override
  State<AmsApplyLeaveTab> createState() => _AmsApplyLeaveTabState();
}

class _AmsApplyLeaveTabState extends State<AmsApplyLeaveTab> {
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  int? _leaveId;
  int? _leaveTypeId;
  String _startHalf = 'full_day';
  String _endHalf = 'full_day';
  static const Map<String, String> _halfLabel = <String, String>{
    'full_day': 'Full Day',
    'first_half': 'First Half',
    'second_half': 'Second Half',
  };

  @override
  void initState() {
    super.initState();
    _applyPrefill();
  }

  @override
  void didUpdateWidget(covariant AmsApplyLeaveTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.prefill != widget.prefill) {
      _applyPrefill();
    }
  }

  void _applyPrefill() {
    final Map<String, dynamic>? p = widget.prefill;
    if (p == null) return;
    _leaveId = p['leaveId'] as int?;
    _leaveTypeId = p['leaveTypeId'] as int?;
    _startController.text = (p['startDate'] ?? '').toString();
    _endController.text = (p['endDate'] ?? '').toString();
    _startHalf = (p['startHalf'] ?? 'full_day').toString();
    _endHalf = (p['endHalf'] ?? 'full_day').toString();
    _reasonController.text = (p['reason'] ?? '').toString();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _triggerCalculateDaysIfReady();
    });
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null) return;
    final String mm = picked.month.toString().padLeft(2, '0');
    final String dd = picked.day.toString().padLeft(2, '0');
    controller.text = '${picked.year}-$mm-$dd';
  }

  void _showValidationError(String message) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.kcBackgroundColorDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Validation Error', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text(message, style: const TextStyle(color: Colors.white70)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK', style: TextStyle(color: AppColors.kcDarkPrimarySoft)),
            ),
          ],
        );
      },
    );
  }

  void _submit() {
    if (_leaveTypeId == null || _startController.text.trim().isEmpty || _endController.text.trim().isEmpty) {
      return;
    }

    final DateTime start = DateTime.parse(_startController.text.trim());
    final DateTime end = DateTime.parse(_endController.text.trim());

    if (start.isAfter(end)) {
      _showValidationError('Start date must be before or the same as the end date.');
      return;
    }

    widget.onSubmit(
      leaveId: _leaveId,
      leaveTypeId: _leaveTypeId!,
      startDate: _startController.text.trim(),
      startHalf: _startHalf,
      endDate: _endController.text.trim(),
      endHalf: _endHalf,
      reason: _reasonController.text.trim(),
    );
  }

  void _triggerCalculateDaysIfReady() {
    final String startDate = _startController.text.trim();
    final String endDate = _endController.text.trim();
    if (startDate.isEmpty || endDate.isEmpty) {
      widget.onClearCalculatedDays();
      return;
    }
    final DateTime start = DateTime.parse(startDate);
    final DateTime end = DateTime.parse(endDate);
    if (start.isAfter(end)) {
      widget.onClearCalculatedDays();
      return;
    }
    widget.onCalculateDays(
      startDate: startDate,
      startHalf: _startHalf,
      endDate: endDate,
      endHalf: _endHalf,
    );
  }

  InputDecoration _dec(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.kcDarkTextMuted),
      filled: true,
      fillColor: const Color(0xFF0C1730),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.kcDarkBorderStrong),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.kcDarkPrimarySoft),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
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
              const Expanded(
                child: Text(
                  'Apply for Leave',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
                ),
              ),
              if (widget.onClose != null)
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close, color: AppColors.kcDarkTextSecondary),
                  tooltip: 'Cancel',
                ),
            ],
          ),
          const SizedBox(height: 14),
          _label('Leave Type'),
          DropdownButtonFormField<int>(
            initialValue: _leaveTypeId,
            hint: const Text(
              'Select leave type',
              style: TextStyle(color: AppColors.kcDarkTextMuted, fontSize: 15),
            ),
            dropdownColor: AppColors.kcBackgroundColorDark,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            iconEnabledColor: AppColors.kcDarkTextSecondary,
            decoration: _dec(''),
            items: widget.leaveTypes
                .map((Map<String, dynamic> item) => DropdownMenuItem<int>(
                      value: item['id'] as int,
                      child: Text(item['name'].toString(), style: const TextStyle(color: Colors.white)),
                    ))
                .toList(growable: false),
            onChanged: (int? v) => setState(() => _leaveTypeId = v),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _label('Start Date'),
                    TextFormField(
                      controller: _startController,
                      readOnly: true,
                      onTap: () async {
                        await _pickDate(_startController);
                        _triggerCalculateDaysIfReady();
                      },
                      style: const TextStyle(color: Colors.white),
                      decoration: _dec('dd-mm-yyyy'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _label('Start Half'),
                    DropdownButtonFormField<String>(
                      initialValue: _startHalf,
                      dropdownColor: AppColors.kcBackgroundColorDark,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      iconEnabledColor: AppColors.kcDarkTextSecondary,
                      decoration: _dec('Full Day'),
                      items: const <String>['full_day', 'first_half', 'second_half']
                          .map((String s) => DropdownMenuItem<String>(value: s, child: Text(_halfLabel[s] ?? s, style: const TextStyle(color: Colors.white))))
                          .toList(growable: false),
                      onChanged: (String? v) {
                        setState(() => _startHalf = v ?? 'full_day');
                        _triggerCalculateDaysIfReady();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _label('End Date'),
                    TextFormField(
                      controller: _endController,
                      readOnly: true,
                      onTap: () async {
                        await _pickDate(_endController);
                        _triggerCalculateDaysIfReady();
                      },
                      style: const TextStyle(color: Colors.white),
                      decoration: _dec('dd-mm-yyyy'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _label('End Half'),
                    DropdownButtonFormField<String>(
                      initialValue: _endHalf,
                      dropdownColor: AppColors.kcBackgroundColorDark,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      iconEnabledColor: AppColors.kcDarkTextSecondary,
                      decoration: _dec('Full Day'),
                      items: const <String>['full_day', 'first_half', 'second_half']
                          .map((String s) => DropdownMenuItem<String>(value: s, child: Text(_halfLabel[s] ?? s, style: const TextStyle(color: Colors.white))))
                          .toList(growable: false),
                      onChanged: (String? v) {
                        setState(() => _endHalf = v ?? 'full_day');
                        _triggerCalculateDaysIfReady();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFF0C1730),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.kcDarkBorderStrong),
            ),
            child: widget.isCalculatingDays
                ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 8),
                      Text('Calculating leave days...', style: TextStyle(color: AppColors.kcDarkTextSecondary, fontSize: 12)),
                    ],
                  )
                : Text(
                    widget.calculatedTotalDays == null
                        ? 'Select start and end date to calculate leave days.'
                        : 'Total days: ${widget.calculatedTotalDays} | Holidays: ${widget.calculatedHolidayCount ?? 0} | Weekends: ${widget.calculatedWeekendCount ?? 0}',
                    style: const TextStyle(color: AppColors.kcDarkTextSecondary, fontSize: 12),
                  ),
          ),
          const SizedBox(height: 10),
          _label('Reason'),
          TextFormField(
            controller: _reasonController,
            minLines: 2,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: _dec('Optional reason'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kcDarkPrimarySoft,
                foregroundColor: AppColors.kcDarkTextPrimary,
                minimumSize: const Size.fromHeight(40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: widget.isSubmitting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(_leaveId == null ? 'Submit Leave Request' : 'Update Leave Request'),
            ),
          ),
        ],
      ),
    );
  }
}
