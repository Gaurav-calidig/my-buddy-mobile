import 'package:core/features/dsr/presentation/models/dsr_entry.dart';
import 'package:core/features/dsr/presentation/widgets/dsr_widgets.dart';
import 'package:core/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class MyDsrScreen extends StatefulWidget {
  const MyDsrScreen({super.key});

  @override
  State<MyDsrScreen> createState() => _MyDsrScreenState();
}

enum _DsrTab { add, history }

class _MyDsrScreenState extends State<MyDsrScreen> {
  static const List<String> _projects = <String>[
    'FotoFinish',
    'MyBuddy',
    'Urbangate',
    'VGS - Homework app',
    'Flutter Acceleration',
    'Rent My Stuff',
  ];

  static const List<String> _statuses = <String>['In Progress', 'Completed', 'Blocked'];

  final TextEditingController _descriptionController = TextEditingController();
  final Map<DateTime, List<DsrEntry>> _entriesByDate = <DateTime, List<DsrEntry>>{};

  _DsrTab _activeTab = _DsrTab.add;
  String? _selectedProject;
  String? _selectedHours;
  String _selectedStatus = 'Completed';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _seedHistoryData();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  List<String> get _hoursOptions => List<String>.generate(17, (int index) {
    final double value = index * 0.5;
    return '${value.toStringAsFixed(1)}h';
  });

  DateTime get _todayKey => _dayKey(DateTime.now());

  List<MapEntry<DateTime, List<DsrEntry>>> get _historyGroups {
    final DateTime today = _todayKey;
    final List<MapEntry<DateTime, List<DsrEntry>>> groups = _entriesByDate.entries
        .where((MapEntry<DateTime, List<DsrEntry>> e) => !_isSameDate(e.key, today))
        .toList();
    groups.sort((a, b) => b.key.compareTo(a.key));
    return groups;
  }

  DateTime _dayKey(DateTime date) => DateTime(date.year, date.month, date.day);

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String year = date.year.toString();
    return '$day/$month/$year';
  }

  void _seedHistoryData() {
    final DateTime today = _todayKey;
    final DateTime yesterday = today.subtract(const Duration(days: 1));
    final DateTime older = today.subtract(const Duration(days: 4));

    _entriesByDate[yesterday] = <DsrEntry>[
      DsrEntry(
        project: 'FotoFinish',
        hours: 1.0,
        status: 'Completed',
        description: 'Checked and fixed the site list API issue and created ticket notes.',
        date: yesterday,
      ),
      DsrEntry(
        project: 'Flutter Acceleration',
        hours: 8.0,
        status: 'Completed',
        description:
            'Implemented PDF generation with both table and without-table format and worked on onboarding module updates.',
        date: yesterday,
      ),
    ];

    _entriesByDate[older] = <DsrEntry>[
      DsrEntry(
        project: 'MyBuddy',
        hours: 2.5,
        status: 'Completed',
        description: 'Integrated Google map markers and polished address selection flow.',
        date: older,
      ),
      DsrEntry(
        project: 'Rent My Stuff',
        hours: 6.5,
        status: 'In Progress',
        description: 'Started cart summary refactor and API sync for order history.',
        date: older,
      ),
    ];
  }

  void _addEntry() {
    if (_selectedProject == null || _selectedHours == null) return;

    final double parsedHours = double.parse(_selectedHours!.replaceAll('h', '').trim());
    final DateTime dateKey = _dayKey(_selectedDate);
    final DsrEntry entry = DsrEntry(
      project: _selectedProject!,
      hours: parsedHours,
      status: _selectedStatus,
      description: _descriptionController.text.trim(),
      date: dateKey,
    );

    setState(() {
      _entriesByDate.putIfAbsent(dateKey, () => <DsrEntry>[]).add(entry);
      _descriptionController.clear();
      _selectedProject = null;
      _selectedHours = null;
      _selectedStatus = 'Completed';
    });
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null) return;
    setState(() => _selectedDate = picked);
  }

  void _deleteEntry(DateTime date, int index) {
    setState(() {
      final List<DsrEntry>? list = _entriesByDate[date];
      if (list == null || index >= list.length) return;
      list.removeAt(index);
      if (list.isEmpty) _entriesByDate.remove(date);
    });
  }

  Future<void> _editEntry(DateTime date, int index) async {
    final List<DsrEntry>? list = _entriesByDate[date];
    if (list == null || index >= list.length) return;

    final DsrEntry current = list[index];
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
    final double parsedHours = double.parse(selectedHours!.replaceAll('h', '').trim());

    setState(() {
      list[index] = current.copyWith(
        hours: parsedHours,
        status: selectedStatus,
        description: descController.text.trim(),
      );
    });
    descController.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            if (_activeTab == _DsrTab.add) _buildAddTab() else _buildHistoryTab(),
          ],
        ),
      ),
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
            onTap: () => setState(() => _activeTab = _DsrTab.history),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTab() {
    final DateTime dateKey = _dayKey(_selectedDate);
    final List<DsrEntry> entries = _entriesByDate[dateKey] ?? <DsrEntry>[];
    final double totalHours = entries.fold<double>(0, (double sum, DsrEntry entry) => sum + entry.hours);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.kcDarkInput,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.kcDarkBorderSoft),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.calendar_today_outlined, color: AppColors.kcDarkTextSecondary, size: 14),
                const SizedBox(width: 8),
                Text(
                  'Today (${_formatDate(_selectedDate)})',
                  style: const TextStyle(color: AppColors.kcDarkTextPrimary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 18),
                const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.kcDarkTextSecondary),
              ],
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
                  items: _projects,
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
                    onPressed: _addEntry,
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
                        'No entries for this date. Add your first DSR\nentry above.',
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

  Widget _buildHistoryTab() {
    if (_historyGroups.isEmpty) {
      return const DsrCardShell(
        child: Padding(
          padding: EdgeInsets.all(14),
          child: Text('No history records found.', style: TextStyle(color: AppColors.kcDarkTextFaint)),
        ),
      );
    }

    return Column(
      children: _historyGroups.map((MapEntry<DateTime, List<DsrEntry>> group) {
        final DateTime date = group.key;
        final List<DsrEntry> entries = group.value;
        final double total = entries.fold<double>(0, (double s, DsrEntry e) => s + e.hours);
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
    required List<DsrEntry> entries,
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
              final DsrEntry entry = entries[index];
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
    required DsrEntry entry,
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
                  onTap: () => _editEntry(date, index),
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
