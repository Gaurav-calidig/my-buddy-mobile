import 'package:core/core/theme/app_colors.dart';
import 'package:core/features/dsr/domain/entities/dsr_entry_entity.dart';
import 'package:core/features/dsr/presentation/bloc/dsr_bloc.dart';
import 'package:core/features/dsr/presentation/bloc/dsr_event.dart';
import 'package:core/features/dsr/presentation/bloc/dsr_state.dart';
import 'package:core/features/dsr/presentation/widgets/dsr_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyDsrScreen extends StatefulWidget {
  const MyDsrScreen({super.key});

  @override
  State<MyDsrScreen> createState() => _MyDsrScreenState();
}

enum _DsrTab { add, history }

class _MyDsrScreenState extends State<MyDsrScreen> {
  static const List<String> _statuses = <String>['In Progress', 'Completed', 'Blocked'];

  final TextEditingController _descriptionController = TextEditingController();

  _DsrTab _activeTab = _DsrTab.add;
  String? _selectedProject;
  String? _selectedHours;
  String _selectedStatus = 'Completed';

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  List<String> get _hoursOptions => List<String>.generate(19, (int index) {
    final double value = index * 0.5;
    return '${value.toStringAsFixed(1)}h';
  });

  DateTime get _todayKey => _dayKey(DateTime.now());

  DateTime _dayKey(DateTime date) => DateTime(date.year, date.month, date.day);

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String year = date.year.toString();
    return '$day/$month/$year';
  }

  void _addEntry(DsrState state, DateTime selectedDate) {
    final String projectName = (_selectedProject ?? '').trim();
    final String selectedHours = (_selectedHours ?? '').trim();
    if (projectName.isEmpty || selectedHours.isEmpty) {
      return;
    }

    final int projectIndex = state.projects.indexWhere((p) => p.name == projectName);
    if (projectIndex == -1) return;
    final project = state.projects[projectIndex];

    final String normalizedHours = selectedHours.replaceAll('h', '').trim();
    final String description = _descriptionController.text.trim();
    final String status = _selectedStatus.trim().toLowerCase();

    context.read<DsrBloc>().add(
      DsrCreateRequested(
        projectId: project.id,
        date: selectedDate,
        description: description,
        hours: normalizedHours,
        status: status,
      ),
    );

    setState(() {
      _selectedHours = null;
      _selectedStatus = 'Completed';
      _descriptionController.clear();
    });
  }

  void _deleteEntry(DateTime date, int index) {
    // Keeping current delete action local-only by design until delete API is wired.
  }

  Future<void> _editEntry(DateTime date, int index, DsrEntryEntity current) async {
    final TextEditingController descController = TextEditingController(text: current.description);
    String selectedStatus = current.status;
    String? selectedHours = '${current.hours.toStringAsFixed(1)}h';

    final bool? shouldSave = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.kcBackgroundColorDark,
          title: const Text('Edit DSR', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DsrDropdownField<String>(
                value: selectedHours,
                hintText: 'Select hours',
                items: _hoursOptions,
                onChanged: (String? v) => selectedHours = v,
              ),
              const SizedBox(height: 10),
              DsrDropdownField<String>(
                value: selectedStatus,
                hintText: 'Select status',
                items: _statuses,
                onChanged: (String? v) {
                  if (v != null) selectedStatus = v;
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descController,
                maxLines: 4,
                style: const TextStyle(color: AppColors.kcDarkTextPrimary),
                decoration: dsrFieldDecoration('Description'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Save')),
          ],
        );
      },
    );

    if (shouldSave != true || selectedHours == null) return;
    descController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DsrBloc, DsrState>(
      builder: (context, state) {
        final DateTime selectedDate = state.selectedDate ?? _todayKey;
        final bool showTabLoader = state.isLoading;
        final List<String> projectNames = state.projects.map((p) => p.name).toList(growable: false);
        if (_selectedProject == null && projectNames.isNotEmpty) {
          _selectedProject = projectNames.first;
        }

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[AppColors.kcDarkGradientTop, AppColors.kcDarkGradientBottom],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Daily Status Report',
                  style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Log your daily work activity and hours',
                  style: TextStyle(color: AppColors.kcDarkTextSecondary, fontSize: 14),
                ),
                const SizedBox(height: 10),
                _tabStrip(),
                const SizedBox(height: 10),
                if (state.errorMessage != null) ...<Widget>[
                  Text(
                    state.errorMessage!,
                    style: const TextStyle(
                      color: AppColors.kcDarkErrorText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                if (showTabLoader)
                  const Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_activeTab == _DsrTab.add)
                  _buildAddTab(state: state, selectedDate: selectedDate, projectNames: projectNames)
                else
                  _buildHistoryTab(state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tabStrip() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.kcDarkCardSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.kcDarkBorderStrong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DsrTabButton(
            title: 'Add DSR',
            selected: _activeTab == _DsrTab.add,
            onTap: () => setState(() => _activeTab = _DsrTab.add),
          ),
          DsrTabButton(
            title: 'My DSR History',
            selected: _activeTab == _DsrTab.history,
            onTap: () {
              setState(() => _activeTab = _DsrTab.history);
              context.read<DsrBloc>().add(const DsrHistoryLoadRequested());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddTab({
    required DsrState state,
    required DateTime selectedDate,
    required List<String> projectNames,
  }) {
    final DateTime dateKey = _dayKey(selectedDate);
    final List<DsrEntryEntity> entries = state.entriesByDate[dateKey] ?? <DsrEntryEntity>[];
    final double totalHours = entries.fold<double>(0, (double sum, DsrEntryEntity entry) => sum + entry.hours);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.kcDarkInput,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.kcDarkBorderSoft),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<DateTime>(
              value: selectedDate,
              dropdownColor: AppColors.kcBackgroundColorDark,
              iconEnabledColor: AppColors.kcDarkTextSecondary,
              style: const TextStyle(color: AppColors.kcDarkTextPrimary, fontWeight: FontWeight.w600),
              items: <DateTime>[
                _todayKey,
                _todayKey.subtract(const Duration(days: 1)),
              ].map((date) {
                final bool isToday = _isSameDate(date, _todayKey);
                final String label = isToday ? 'Today' : 'Yesterday';
                return DropdownMenuItem<DateTime>(
                  value: date,
                  child: Text('$label (${_formatDate(date)})'),
                );
              }).toList(growable: false),
              onChanged: (value) {
                if (value == null) return;
                context.read<DsrBloc>().add(DsrDateChangedRequested(value));
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.kcDarkInput,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.kcDarkBorderMid),
          ),
          child: Text(
            '${totalHours.toStringAsFixed(1)}h logged',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 12),
        DsrCardShell(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Add Entry', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 14),
                const DsrLabel('Project'),
                DsrDropdownField<String>(
                  value: _selectedProject,
                  hintText: 'Select project',
                  items: projectNames,
                  onChanged: (String? value) => setState(() => _selectedProject = value),
                ),
                const SizedBox(height: 10),
                const DsrLabel('Hours'),
                DsrDropdownField<String>(
                  value: _selectedHours,
                  hintText: 'Select hours',
                  items: _hoursOptions,
                  onChanged: (String? value) => setState(() => _selectedHours = value),
                ),
                const SizedBox(height: 10),
                const DsrLabel('Status'),
                DsrDropdownField<String>(
                  value: _selectedStatus,
                  hintText: 'Select status',
                  items: _statuses,
                  onChanged: (String? value) {
                    if (value != null) setState(() => _selectedStatus = value);
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _addEntry(state, selectedDate),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kcDarkPrimarySoft,
                      foregroundColor: AppColors.kcDarkTextPrimary,
                      minimumSize: const Size.fromHeight(40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const DsrLabel('Description'),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: const TextStyle(color: AppColors.kcDarkTextPrimary),
                  decoration: dsrFieldDecoration('What did you work on?'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        DsrCardShell(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: entries.isEmpty
                ? const SizedBox(
                    height: 110,
                    child: Center(
                      child: Text(
                        'No DSR entries found for selected date.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.kcDarkTextFaint, height: 1.35),
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: entries.map((entry) => DsrTodayEntryTile(entry: entry)).toList(),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab(DsrState state) {
    final DateTime today = _todayKey;
    final List<MapEntry<DateTime, List<DsrEntryEntity>>> historyGroups = state.entriesByDate.entries
        .where((MapEntry<DateTime, List<DsrEntryEntity>> e) => !_isSameDate(e.key, today))
        .toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    if (historyGroups.isEmpty) {
      return const DsrCardShell(
        child: Padding(
          padding: EdgeInsets.all(14),
          child: Text('No history records found.', style: TextStyle(color: AppColors.kcDarkTextFaint)),
        ),
      );
    }

    return Column(
      children: historyGroups.map((MapEntry<DateTime, List<DsrEntryEntity>> group) {
        final DateTime date = group.key;
        final List<DsrEntryEntity> entries = group.value;
        final double total = entries.fold<double>(0, (double s, DsrEntryEntity e) => s + e.hours);
        final DateTime yesterday = _todayKey.subtract(const Duration(days: 1));
        final bool canMutate = _isSameDate(date, yesterday);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _historyCard(date: date, entries: entries, total: total, canMutate: canMutate),
        );
      }).toList(),
    );
  }

  Widget _historyCard({
    required DateTime date,
    required List<DsrEntryEntity> entries,
    required double total,
    required bool canMutate,
  }) {
    return DsrCardShell(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(_formatDate(date), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                const Spacer(),
                if (!canMutate)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.kcDarkReadOnlyBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.kcDarkReadOnlyBorder),
                    ),
                    child: const Text('Read-only', style: TextStyle(color: AppColors.kcDarkTextPrimary, fontSize: 10, fontWeight: FontWeight.w600)),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.kcDarkBorderMid),
                  ),
                  child: Text('${total.toStringAsFixed(1)}h', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const DsrHistoryHeaderRow(),
            const SizedBox(height: 8),
            ...List<Widget>.generate(entries.length, (int index) {
              final DsrEntryEntity entry = entries[index];
              return _historyEntryRow(date: date, index: index, entry: entry, canMutate: canMutate);
            }),
          ],
        ),
      ),
    );
  }

  Widget _historyEntryRow({
    required DateTime date,
    required int index,
    required DsrEntryEntity entry,
    required bool canMutate,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      decoration: BoxDecoration(
        color: AppColors.kcDarkSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.kcDarkBorderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Text(entry.project, style: const TextStyle(color: AppColors.kcDarkTextPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.kcDarkBorderMid),
                ),
                child: Text('${entry.hours.toStringAsFixed(1)}h', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              DsrStatusPill(status: entry.status),
              if (canMutate) ...<Widget>[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _editEntry(date, index, entry),
                  child: const Icon(Icons.edit_outlined, color: AppColors.kcDarkTextPrimary, size: 17),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () => _deleteEntry(date, index),
                  child: const Icon(Icons.delete_outline, color: AppColors.kcDarkTextPrimary, size: 17),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: AppColors.kcDarkReadOnlyBg, borderRadius: BorderRadius.circular(6)),
            child: Text(
              entry.description.isEmpty ? 'No description provided.' : entry.description,
              style: const TextStyle(color: AppColors.kcDarkTextPrimary, fontSize: 12, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
