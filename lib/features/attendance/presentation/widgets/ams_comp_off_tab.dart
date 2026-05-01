import 'package:core/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AmsCompOffTab extends StatefulWidget {
  const AmsCompOffTab({
    required this.isSubmitting,
    required this.history,
    required this.onSubmit,
    super.key,
  });

  final bool isSubmitting;
  final List<Map<String, String>> history;
  final void Function({required String workedDate, required String leaveDays, required String reason}) onSubmit;

  @override
  State<AmsCompOffTab> createState() => _AmsCompOffTabState();
}

class _AmsCompOffTabState extends State<AmsCompOffTab> {
  final TextEditingController _workedDateController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  String _days = '1';

  @override
  void didUpdateWidget(covariant AmsCompOffTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool submitFinished = oldWidget.isSubmitting && !widget.isSubmitting;
    final bool historyIncreased = widget.history.length > oldWidget.history.length;
    if (submitFinished && historyIncreased) {
      _workedDateController.clear();
      _reasonController.clear();
      setState(() => _days = '1');
    }
  }

  @override
  void dispose() {
    _workedDateController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
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
    _workedDateController.text = '${picked.year}-$mm-$dd';
  }

  InputDecoration _dec(String hint, {required bool isDark}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextMuted),
      filled: true,
      fillColor: isDark ? const Color(0xFF0C1730) : AppColors.kcLightInput,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: isDark ? AppColors.kcDarkBorderStrong : AppColors.kcLightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.kcPrimaryColor),
      ),
    );
  }

  Widget _label(String text, {required bool isDark}) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.kcLightTitle,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      );

  void _submit() {
    if (_workedDateController.text.trim().isEmpty) return;
    widget.onSubmit(
      workedDate: _workedDateController.text.trim(),
      leaveDays: _days,
      reason: _reasonController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.kcDarkCard : AppColors.kcLightCard;
    final borderColor = isDark ? AppColors.kcDarkBorderStrong : AppColors.kcLightBorder;
    final titleColor = isDark ? Colors.white : AppColors.kcLightTitle;
    final secondaryColor = isDark ? AppColors.kcDarkTextSecondary : AppColors.kcLightTextSecondary;
    final dropdownBg = isDark ? AppColors.kcBackgroundColorDark : AppColors.kcLightCard;
    final valueColor = isDark ? Colors.white : AppColors.kcLightTitle;
    final mutedColor = isDark ? AppColors.kcDarkTextFaint : AppColors.kcLightTextMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Apply for Comp Off', style: TextStyle(color: titleColor, fontWeight: FontWeight.w700, fontSize: 20)),
              const SizedBox(height: 14),
              _label('Worked Date', isDark: isDark),
              TextFormField(
                controller: _workedDateController,
                readOnly: true,
                onTap: _pickDate,
                style: TextStyle(color: valueColor),
                decoration: _dec('dd-mm-yyyy', isDark: isDark),
              ),
              const SizedBox(height: 10),
              _label('Days', isDark: isDark),
              DropdownButtonFormField<String>(
                initialValue: _days,
                dropdownColor: dropdownBg,
                style: TextStyle(color: valueColor, fontSize: 13, fontWeight: FontWeight.w600),
                iconEnabledColor: secondaryColor,
                decoration: _dec('1 Day', isDark: isDark),
                items: const <String>['0.5', '1']
                    .map((String d) => DropdownMenuItem<String>(value: d, child: Text('$d Day${d == '1' ? '' : 's'}', style: TextStyle(color: valueColor))))
                    .toList(growable: false),
                onChanged: (String? v) => setState(() => _days = v ?? '1'),
              ),
              const SizedBox(height: 10),
              _label('Reason', isDark: isDark),
              TextFormField(
                controller: _reasonController,
                minLines: 2,
                maxLines: 3,
                style: TextStyle(color: valueColor),
                decoration: _dec('Why did you work on a holiday/weekend?', isDark: isDark),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kcPrimaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: widget.isSubmitting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Submit Comp Off Request'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text('CompOff History', style: TextStyle(color: secondaryColor, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        if (widget.history.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text('No comp-off requests yet', style: TextStyle(color: mutedColor)),
            ),
          )
        else
          ...widget.history.map((Map<String, String> h) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: <Widget>[
                  Text((h['workedDate'] ?? '-'), style: TextStyle(color: titleColor, fontWeight: FontWeight.w700, fontSize: 12)),
                  const SizedBox(width: 10),
                  Text('${h['leaveDays'] ?? '-'} day', style: TextStyle(color: secondaryColor, fontSize: 12)),
                  const SizedBox(width: 10),
                  Expanded(child: Text((h['reason'] ?? ''), overflow: TextOverflow.ellipsis, style: TextStyle(color: secondaryColor, fontSize: 12))),
                  const SizedBox(width: 8),
                  Text((h['status'] ?? '').toUpperCase(), style: TextStyle(color: isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextMuted, fontSize: 10)),
                ],
              ),
            );
          }),
      ],
    );
  }
}
