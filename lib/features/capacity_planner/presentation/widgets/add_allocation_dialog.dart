import 'package:core/core/theme/app_colors.dart';
import 'package:core/features/auth/domain/entities/user_entity.dart';
import 'package:core/features/projects/domain/entities/project_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddAllocationDialog extends StatefulWidget {
  final List<UserEntity> members;
  final List<ProjectEntity> projects;

  const AddAllocationDialog({
    super.key,
    required this.members,
    required this.projects,
  });

  @override
  State<AddAllocationDialog> createState() => _AddAllocationDialogState();
}

class _AddAllocationDialogState extends State<AddAllocationDialog> {
  UserEntity? _selectedMember;
  ProjectEntity? _selectedProject;
  DateTime _startDate = DateTime.now();
  bool _isOngoing = false;
  int _numberOfDays = 0;
  String _hoursPerDay = '8h';
  bool _useEndDate = false;
  DateTime? _endDate;

  final List<String> _hourOptions = [
    '0.5h', '1h', '1.5h', '2h', '2.5h', '3h', '3.5h', '4h',
    '4.5h', '5h', '5.5h', '6h', '6.5h', '7h', '7.5h', '8h', '8.5h', '9h'
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.kcDarkPage : Colors.white;
    final textColor = isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTextPrimary;
    final fieldFillColor = isDark ? AppColors.kcDarkInput : Colors.grey[100];
    final borderColor = isDark ? AppColors.kcDarkBorderSoft : Colors.grey[300]!;
    final labelColor = isDark ? AppColors.kcDarkTextSecondary : AppColors.kcLightTextSecondary;

    return Dialog(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Add Allocation',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Team Member
                _buildLabel('Team Member', labelColor),
                const SizedBox(height: 8),
                _buildDropdown<UserEntity>(
                  hint: 'Select member',
                  value: _selectedMember,
                  items: widget.members.map((m) => DropdownMenuItem(
                    value: m,
                    child: Text('${m.firstName} ${m.lastName}'),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedMember = val),
                  isDark: isDark,
                  fieldFillColor: fieldFillColor,
                  borderColor: borderColor,
                ),
                
                const SizedBox(height: 20),
                
                // Project
                _buildLabel('Project', labelColor),
                const SizedBox(height: 8),
                _buildDropdown<ProjectEntity>(
                  hint: 'Select a project first',
                  value: _selectedProject,
                  items: widget.projects.map((p) => DropdownMenuItem(
                    value: p,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            p.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (p.isBillable) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[800] : Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Billable',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedProject = val),
                  isDark: isDark,
                  fieldFillColor: fieldFillColor,
                  borderColor: borderColor,
                ),
                
                const SizedBox(height: 20),
                
                // Start Date
                _buildLabel('Start Date', labelColor),
                const SizedBox(height: 8),
                _buildDatePickerField(
                  context,
                  _startDate,
                  (date) => setState(() => _startDate = date),
                  isDark,
                  fieldFillColor,
                  borderColor,
                ),
                
                const SizedBox(height: 16),
                
                // Ongoing
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _isOngoing,
                        onChanged: (val) => setState(() => _isOngoing = val ?? false),
                        activeColor: AppColors.kcPrimaryColor,
                        side: BorderSide(color: isDark ? Colors.grey[400]! : Colors.grey[600]!),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Ongoing ',
                      style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '(no end date)',
                      style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Number of Days / End Date
                if (!_isOngoing) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildLabel(_useEndDate ? 'End Date' : 'Number of Days', labelColor),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => setState(() => _useEndDate = !_useEndDate),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          _useEndDate ? 'Switch to Number of Days' : 'Switch to End Date',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_useEndDate)
                    _buildDatePickerField(
                      context,
                      _endDate ?? _startDate.add(const Duration(days: 1)),
                      (date) => setState(() => _endDate = date),
                      isDark,
                      fieldFillColor,
                      borderColor,
                    )
                  else
                    _buildTextField(
                      hint: 'Business days',
                      isDark: isDark,
                      fieldFillColor: fieldFillColor,
                      borderColor: borderColor,
                      keyboardType: TextInputType.number,
                      onChanged: (val) => _numberOfDays = int.tryParse(val) ?? 0,
                    ),
                  const SizedBox(height: 20),
                ],
                
                // Hours per Day
                _buildLabel('Hours per Day', labelColor),
                const SizedBox(height: 8),
                _buildDropdown<String>(
                  hint: 'Select hours',
                  value: _hoursPerDay,
                  items: _hourOptions.map((h) => DropdownMenuItem(
                    value: h,
                    child: Text(h),
                  )).toList(),
                  onChanged: (val) => setState(() => _hoursPerDay = val ?? '8h'),
                  isDark: isDark,
                  fieldFillColor: fieldFillColor,
                  borderColor: borderColor,
                ),
                
                const SizedBox(height: 32),
                
                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textColor,
                        side: BorderSide(color: borderColor),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        // Handle Add
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF334F9A) : AppColors.kcPrimaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color textColor) {
    return Text(
      text,
      style: TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required bool isDark,
    required Color? fieldFillColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: fieldFillColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600], fontSize: 14),
          ),
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          items: items,
          onChanged: onChanged,
          icon: Icon(Icons.keyboard_arrow_down, color: isDark ? Colors.grey[400] : Colors.grey[600]),
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required bool isDark,
    required Color? fieldFillColor,
    required Color borderColor,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      onChanged: onChanged,
      keyboardType: keyboardType,
      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600], fontSize: 14),
        filled: true,
        fillColor: fieldFillColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.kcPrimaryColor),
        ),
      ),
    );
  }

  Widget _buildDatePickerField(
    BuildContext context,
    DateTime date,
    ValueChanged<DateTime> onDateSelected,
    bool isDark,
    Color? fieldFillColor,
    Color borderColor,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: isDark 
                  ? ColorScheme.dark(
                      primary: AppColors.kcPrimaryColor,
                      onPrimary: Colors.white,
                      surface: const Color(0xFF1E293B),
                      onSurface: Colors.white,
                    )
                  : ColorScheme.light(
                      primary: AppColors.kcPrimaryColor,
                      onPrimary: Colors.white,
                    ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) onDateSelected(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: fieldFillColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('dd/MM/yyyy').format(date),
              style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
            ),
            Icon(Icons.calendar_today, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
          ],
        ),
      ),
    );
  }
}
