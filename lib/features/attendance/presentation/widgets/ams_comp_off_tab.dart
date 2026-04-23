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
  final void Function({required String workedDate, required String days, required String reason}) onSubmit;

  @override
  State<AmsCompOffTab> createState() => _AmsCompOffTabState();
}

class _AmsCompOffTabState extends State<AmsCompOffTab> {
  final TextEditingController _workedDateController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  String _days = '1';

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

  void _submit() {
    if (_workedDateController.text.trim().isEmpty) return;
    widget.onSubmit(
      workedDate: _workedDateController.text.trim(),
      days: _days,
      reason: _reasonController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
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
              const Text('Apply for Comp Off', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20)),
              const SizedBox(height: 14),
              _label('Worked Date'),
              TextFormField(
                controller: _workedDateController,
                readOnly: true,
                onTap: _pickDate,
                style: const TextStyle(color: Colors.white),
                decoration: _dec('dd-mm-yyyy'),
              ),
              const SizedBox(height: 10),
              _label('Days'),
              DropdownButtonFormField<String>(
                initialValue: _days,
                dropdownColor: AppColors.kcBackgroundColorDark,
                decoration: _dec('1 Day'),
                items: const <String>['1', '0.5']
                    .map((String d) => DropdownMenuItem<String>(value: d, child: Text('$d Day${d == '1' ? '' : 's'}')))
                    .toList(growable: false),
                onChanged: (String? v) => setState(() => _days = v ?? '1'),
              ),
              const SizedBox(height: 10),
              _label('Reason'),
              TextFormField(
                controller: _reasonController,
                minLines: 2,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: _dec('Why did you work on a holiday/weekend?'),
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
                  ),
                  child: widget.isSubmitting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Submit Comp Off Request'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text('CompOff History', style: TextStyle(color: AppColors.kcDarkTextSecondary, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        if (widget.history.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('No comp-off requests yet', style: TextStyle(color: AppColors.kcDarkTextFaint)),
            ),
          )
        else
          ...widget.history.map((Map<String, String> h) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.kcDarkCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.kcDarkBorderStrong),
              ),
              child: Row(
                children: <Widget>[
                  Text((h['workedDate'] ?? '-'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                  const SizedBox(width: 10),
                  Text('${h['days'] ?? '-'} day', style: const TextStyle(color: AppColors.kcDarkTextSecondary, fontSize: 12)),
                  const SizedBox(width: 10),
                  Expanded(child: Text((h['reason'] ?? ''), overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.kcDarkTextSecondary, fontSize: 12))),
                ],
              ),
            );
          }),
      ],
    );
  }
}
