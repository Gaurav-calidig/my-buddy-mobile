import 'package:core/core/theme/app_colors.dart';
import 'package:core/core/dependency_injection/injection_container.dart';
import 'package:core/features/taskhub/domain/entities/sprint_entity.dart';
import 'package:core/features/taskhub/domain/usecases/sprint_usecases.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ManageSprintsDialog extends StatefulWidget {
  final int projectId;

  const ManageSprintsDialog({super.key, required this.projectId});

  @override
  State<ManageSprintsDialog> createState() => _ManageSprintsDialogState();
}

class _ManageSprintsDialogState extends State<ManageSprintsDialog> {
  final _getSprintsUseCase = sl<GetSprintsUseCase>();
  final _createSprintUseCase = sl<CreateSprintUseCase>();
  final _updateSprintUseCase = sl<UpdateSprintUseCase>();
  final _deleteSprintUseCase = sl<DeleteSprintUseCase>();

  List<SprintEntity> _sprints = [];
  bool _loading = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  SprintEntity? _editingSprint;
  bool _showForm = false;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  String _status = 'active';

  @override
  void initState() {
    super.initState();
    _loadSprints();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _loadSprints() async {
    setState(() => _loading = true);
    try {
      final results = await _getSprintsUseCase(widget.projectId);
      setState(() {
        _sprints = results;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading sprints: $e')));
      }
    }
  }

  void _startCreate() {
    setState(() {
      _editingSprint = null;
      _nameController.text = '';
      _goalController.text = '';
      _startDate = DateTime.now();
      _endDate = DateTime.now().add(const Duration(days: 7));
      _status = 'planned';
      _showForm = true;
    });
  }

  void _startEdit(SprintEntity sprint) {
    setState(() {
      _editingSprint = sprint;
      _nameController.text = sprint.name;
      _goalController.text = sprint.goal;
      _startDate = sprint.startDate;
      _endDate = sprint.endDate;
      _status = _normalizeStatus(sprint.status);
      _showForm = true;
    });
  }

  void _cancelForm() {
    setState(() {
      _editingSprint = null;
      _showForm = false;
    });
  }

  Future<void> _saveSprint() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    try {
      final sprint = _editingSprint;
      if (sprint == null) {
        await _createSprintUseCase(
          projectId: widget.projectId,
          name: name,
          startDate: _startDate,
          endDate: _endDate,
          goal: _goalController.text.trim(),
          status: _status,
        );
      } else {
        await _updateSprintUseCase(
          projectId: widget.projectId,
          sprintId: sprint.id,
          name: name,
          startDate: _startDate,
          endDate: _endDate,
          goal: _goalController.text.trim(),
          status: _status,
        );
      }
      await _loadSprints();
      if (mounted) _cancelForm();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving sprint: $e')));
      }
    }
  }

  Future<void> _deleteSprint(SprintEntity sprint) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.kcDarkCard,
        title: const Text(
          'Delete Sprint',
          style: TextStyle(color: AppColors.kcDarkTextPrimary),
        ),
        content: Text(
          'Are you sure you want to delete ${sprint.name}?',
          style: const TextStyle(color: AppColors.kcDarkTextMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _deleteSprintUseCase(
          projectId: widget.projectId,
          sprintId: sprint.id,
        );
        _loadSprints();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting sprint: $e')));
        }
      }
    }
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.kcDarkTextSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    int? minLines,
    int? maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.kcDarkTextPrimary),
          minLines: minLines,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.kcDarkTextMuted),
            filled: true,
            fillColor: AppColors.kcDarkInputAlt,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: AppColors.kcDarkBorderSoft.withValues(alpha: 0.55),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.kcDarkPrimary),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate({
    required DateTime initial,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.kcDarkPrimary,
              surface: AppColors.kcDarkCard,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) onPicked(picked);
  }

  Widget _dateField({
    required String label,
    required DateTime value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.kcDarkInputAlt,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.kcDarkBorderSoft.withValues(alpha: 0.55),
              ),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              DateFormat('dd/MM/yyyy').format(value),
              style: const TextStyle(
                color: AppColors.kcDarkTextPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Status'),
        const SizedBox(height: 6),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.kcDarkInputAlt,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.kcDarkBorderSoft.withValues(alpha: 0.55),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _status,
              dropdownColor: AppColors.kcDarkCard,
              iconEnabledColor: AppColors.kcDarkTextMuted,
              style: const TextStyle(
                color: AppColors.kcDarkTextPrimary,
                fontWeight: FontWeight.w700,
              ),
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'active', child: Text('Active')),
                DropdownMenuItem(value: 'completed', child: Text('Completed')),
                DropdownMenuItem(value: 'planned', child: Text('Planning')),
              ],
              onChanged: (v) {
                if (v == null) return;
                setState(() => _status = v);
              },
            ),
          ),
        ),
      ],
    );
  }

  String _normalizeStatus(String status) {
    if (status == 'planning') return 'planned';
    if (status != 'active' && status != 'completed' && status != 'planned') {
      return 'active';
    }
    return status;
  }

  Color _statusPillColor(String status) {
    final normalized = _normalizeStatus(status);
    switch (normalized) {
      case 'completed':
        return Colors.green.shade600;
      case 'planned':
        return AppColors.kcDarkTextMuted.withValues(alpha: 0.65);
      case 'active':
      default:
        return AppColors.kcDarkPrimary;
    }
  }

  String _statusLabel(String status) {
    final normalized = _normalizeStatus(status);
    switch (normalized) {
      case 'completed':
        return 'completed';
      case 'planned':
        return 'planned';
      case 'active':
      default:
        return 'active';
    }
  }

  Widget _sprintRow(SprintEntity sprint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        sprint.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.kcDarkTextPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _statusPillColor(sprint.status),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _statusLabel(sprint.status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${DateFormat('dd/MM/yyyy').format(sprint.startDate)} - ${DateFormat('dd/MM/yyyy').format(sprint.endDate)}',
                  style: const TextStyle(color: AppColors.kcDarkTextMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Edit sprint',
                icon: const Icon(
                  Icons.edit,
                  size: 18,
                  color: AppColors.kcDarkTextMuted,
                ),
                onPressed: () => _startEdit(sprint),
              ),
              IconButton(
                tooltip: 'Delete sprint',
                icon: const Icon(
                  Icons.delete,
                  size: 18,
                  color: AppColors.kcDarkTextMuted,
                ),
                onPressed: () => _deleteSprint(sprint),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.kcDarkSurface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Manage Sprints',
                    style: TextStyle(
                      color: AppColors.kcDarkTextPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.kcDarkTextMuted,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(color: AppColors.kcDarkBorderSoft, height: 1),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 14, bottom: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_sprints.isEmpty) ...[
                              const Text(
                                'No sprints yet. Create one to get started.',
                                style: TextStyle(
                                  color: AppColors.kcDarkTextMuted,
                                ),
                              ),
                              const SizedBox(height: 14),
                              OutlinedButton.icon(
                                onPressed: _startCreate,
                                icon: const Icon(Icons.add),
                                label: const Text('New Sprint'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.kcDarkTextPrimary,
                                  side: BorderSide(
                                    color: AppColors.kcDarkBorderSoft
                                        .withValues(alpha: 0.8),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ] else ...[
                              for (final sprint in _sprints) ...[
                                _sprintRow(sprint),
                                const Divider(
                                  color: AppColors.kcDarkBorderSoft,
                                  height: 1,
                                ),
                              ],
                              const SizedBox(height: 14),
                              OutlinedButton.icon(
                                onPressed: _startCreate,
                                icon: const Icon(Icons.add),
                                label: const Text('New Sprint'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.kcDarkTextPrimary,
                                  side: BorderSide(
                                    color: AppColors.kcDarkBorderSoft
                                        .withValues(alpha: 0.8),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                            if (_showForm) ...[
                              const SizedBox(height: 18),
                              const Divider(
                                color: AppColors.kcDarkBorderSoft,
                                height: 1,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                _editingSprint == null
                                    ? 'New Sprint'
                                    : 'Edit Sprint',
                                style: const TextStyle(
                                  color: AppColors.kcDarkTextPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _field(
                                controller: _nameController,
                                label: 'Name',
                                hint: 'Sprint name',
                              ),
                              const SizedBox(height: 12),
                              _field(
                                controller: _goalController,
                                label: 'Goal (optional)',
                                hint: 'Sprint goal',
                                minLines: 3,
                                maxLines: 3,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _dateField(
                                      label: 'Start Date',
                                      value: _startDate,
                                      onTap: () => _pickDate(
                                        initial: _startDate,
                                        onPicked: (d) =>
                                            setState(() => _startDate = d),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _dateField(
                                      label: 'End Date',
                                      value: _endDate,
                                      onTap: () => _pickDate(
                                        initial: _endDate,
                                        onPicked: (d) =>
                                            setState(() => _endDate = d),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _statusDropdown(),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: _saveSprint,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.kcDarkPrimary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      _editingSprint == null
                                          ? 'Create'
                                          : 'Update',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  TextButton(
                                    onPressed: _cancelForm,
                                    style: TextButton.styleFrom(
                                      foregroundColor:
                                          AppColors.kcDarkTextSecondary,
                                    ),
                                    child: const Text('Cancel'),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
