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

  static const List<String> _statuses = <String>[
    'In Progress',
    'Completed',
    'Blocked',
  ];

  final TextEditingController _descriptionController = TextEditingController();
  final Map<DateTime, List<_DsrEntry>> _entriesByDate = <DateTime, List<_DsrEntry>>{};

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

  List<String> get _hoursOptions {
    return List<String>.generate(17, (int index) {
      final double value = index * 0.5;
      return '${value.toStringAsFixed(1)}h';
    });
  }

  DateTime get _todayKey => _dayKey(DateTime.now());

  List<MapEntry<DateTime, List<_DsrEntry>>> get _historyGroups {
    final DateTime today = _todayKey;
    final List<MapEntry<DateTime, List<_DsrEntry>>> groups = _entriesByDate.entries
        .where((MapEntry<DateTime, List<_DsrEntry>> e) => !_isSameDate(e.key, today))
        .toList();
    groups.sort((a, b) => b.key.compareTo(a.key));
    return groups;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
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

    _entriesByDate[yesterday] = <_DsrEntry>[
      _DsrEntry(
        project: 'FotoFinish',
        hours: 1.0,
        status: 'Completed',
        description: 'Checked and fixed the site list API issue and created ticket notes.',
        date: yesterday,
      ),
      _DsrEntry(
        project: 'Flutter Acceleration',
        hours: 8.0,
        status: 'Completed',
        description:
            'Implemented PDF generation with both table and without-table format and worked on onboarding module updates.',
        date: yesterday,
      ),
    ];

    _entriesByDate[older] = <_DsrEntry>[
      _DsrEntry(
        project: 'MyBuddy',
        hours: 2.5,
        status: 'Completed',
        description: 'Integrated Google map markers and polished address selection flow.',
        date: older,
      ),
      _DsrEntry(
        project: 'Rent My Stuff',
        hours: 6.5,
        status: 'In Progress',
        description: 'Started cart summary refactor and API sync for order history.',
        date: older,
      ),
    ];
  }

  void _addEntry() {
    if (_selectedProject == null || _selectedHours == null) {
      return;
    }

    final double parsedHours = double.parse(_selectedHours!.replaceAll('h', '').trim());
    final DateTime dateKey = _dayKey(_selectedDate);
    final _DsrEntry entry = _DsrEntry(
      project: _selectedProject!,
      hours: parsedHours,
      status: _selectedStatus,
      description: _descriptionController.text.trim(),
      date: dateKey,
    );

    setState(() {
      _entriesByDate.putIfAbsent(dateKey, () => <_DsrEntry>[]).add(entry);
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
      final List<_DsrEntry>? list = _entriesByDate[date];
      if (list == null || index >= list.length) return;
      list.removeAt(index);
      if (list.isEmpty) _entriesByDate.remove(date);
    });
  }

  Future<void> _editEntry(DateTime date, int index) async {
    final List<_DsrEntry>? list = _entriesByDate[date];
    if (list == null || index >= list.length) return;
    final _DsrEntry current = list[index];
    final TextEditingController descController = TextEditingController(text: current.description);
    String selectedStatus = current.status;
    String? selectedHours = '${current.hours.toStringAsFixed(1)}h';

    final bool? shouldSave = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF121F3C),
          title: const Text('Edit DSR', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _dropdownField<String>(
                value: selectedHours,
                hintText: 'Select hours',
                items: _hoursOptions,
                onChanged: (String? v) => selectedHours = v,
              ),
              const SizedBox(height: 10),
              _dropdownField<String>(
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
                style: const TextStyle(color: Color(0xFFE6EFFF)),
                decoration: _fieldDecoration('Description'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save'),
            ),
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
    const Color pageTop = Color(0xFF101C34);
    const Color pageBottom = Color(0xFF0A1630);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[pageTop, pageBottom],
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
              style: TextStyle(color: Color(0xFF8FA5CE), fontSize: 14),
            ),
            const SizedBox(height: 10),
            _tabStrip(),
            const SizedBox(height: 10),
            if (_activeTab == _DsrTab.add) ...<Widget>[
              _buildAddTab(),
            ] else ...<Widget>[
              _buildHistoryTab(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tabStrip() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0E1B36),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2D4166)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _tabButton(title: 'Add DSR', selected: _activeTab == _DsrTab.add, onTap: () {
            setState(() => _activeTab = _DsrTab.add);
          }),
          _tabButton(
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
    final List<_DsrEntry> entries = _entriesByDate[dateKey] ?? <_DsrEntry>[];
    final double totalHours =
        entries.fold<double>(0, (double sum, _DsrEntry entry) => sum + entry.hours);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0C1730),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF2E4268)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.calendar_today_outlined, color: Color(0xFF93AADA), size: 14),
                const SizedBox(width: 8),
                Text(
                  'Today (${_formatDate(_selectedDate)})',
                  style: const TextStyle(color: Color(0xFFDCE8FF), fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 18),
                const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF93AADA)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF0A162E),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF46608C)),
          ),
          child: Text(
            '${totalHours.toStringAsFixed(1)}h logged',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 12),
        _CardShell(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Add Entry',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                _label('Project'),
                _dropdownField<String>(
                  value: _selectedProject,
                  hintText: 'Select project',
                  items: _projects,
                  onChanged: (String? value) => setState(() => _selectedProject = value),
                ),
                const SizedBox(height: 10),
                _label('Hours'),
                _dropdownField<String>(
                  value: _selectedHours,
                  hintText: 'Select hours',
                  items: _hoursOptions,
                  onChanged: (String? value) => setState(() => _selectedHours = value),
                ),
                const SizedBox(height: 10),
                _label('Status'),
                _dropdownField<String>(
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
                      backgroundColor: const Color(0xFF2C5DBD),
                      foregroundColor: const Color(0xFFE8F0FF),
                      minimumSize: const Size.fromHeight(40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _label('Description'),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: const TextStyle(color: Color(0xFFE6EFFF)),
                  decoration: _fieldDecoration('What did you work on?'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _CardShell(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: entries.isEmpty
                ? const SizedBox(
                    height: 110,
                    child: Center(
                      child: Text(
                        'No entries for this date. Add your first DSR\nentry above.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF9BB0D7), height: 1.35),
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: entries.map(_todayEntryTile).toList(),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    if (_historyGroups.isEmpty) {
      return const _CardShell(
        child: Padding(
          padding: EdgeInsets.all(14),
          child: Text(
            'No history records found.',
            style: TextStyle(color: Color(0xFF9BB0D7)),
          ),
        ),
      );
    }

    return Column(
      children: _historyGroups.map((MapEntry<DateTime, List<_DsrEntry>> group) {
        final DateTime date = group.key;
        final List<_DsrEntry> entries = group.value;
        final double total = entries.fold<double>(0, (double s, _DsrEntry e) => s + e.hours);
        final DateTime yesterday = _todayKey.subtract(const Duration(days: 1));
        final bool canMutate = _isSameDate(date, yesterday);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _historyCard(
            date: date,
            entries: entries,
            total: total,
            canMutate: canMutate,
          ),
        );
      }).toList(),
    );
  }

  Widget _historyCard({
    required DateTime date,
    required List<_DsrEntry> entries,
    required double total,
    required bool canMutate,
  }) {
    return _CardShell(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  _formatDate(date),
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                if (!canMutate)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2947),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF3E547D)),
                    ),
                    child: const Text(
                      'Read-only',
                      style: TextStyle(color: Color(0xFFADC3EB), fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF7389B0)),
                  ),
                  child: Text(
                    '${total.toStringAsFixed(1)}h',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const _HistoryHeaderRow(),
            const SizedBox(height: 8),
            ...List<Widget>.generate(entries.length, (int index) {
              final _DsrEntry entry = entries[index];
              return _historyEntryRow(
                date: date,
                index: index,
                entry: entry,
                canMutate: canMutate,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _historyEntryRow({
    required DateTime date,
    required int index,
    required _DsrEntry entry,
    required bool canMutate,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1D39),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF243A5E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Text(
                  entry.project,
                  style: const TextStyle(
                    color: Color(0xFFE7F1FF),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF788CAB)),
                ),
                child: Text(
                  '${entry.hours.toStringAsFixed(1)}h',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              _statusPill(entry.status),
              if (canMutate) ...<Widget>[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _editEntry(date, index),
                  child: const Icon(Icons.edit_outlined, color: Color(0xFFC0D2F2), size: 17),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () => _deleteEntry(date, index),
                  child: const Icon(Icons.delete_outline, color: Color(0xFFC0D2F2), size: 17),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFF142548),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              entry.description.isEmpty ? 'No description provided.' : entry.description,
              style: const TextStyle(
                color: Color(0xFFD9E6FF),
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusPill(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF2C67C5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: const TextStyle(color: Color(0xFFE9F1FF), fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _todayEntryTile(_DsrEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1A34),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF334A71)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  entry.project,
                  style: const TextStyle(color: Color(0xFFE7F0FF), fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.description.isEmpty ? 'No description provided.' : entry.description,
                  style: const TextStyle(color: Color(0xFF9CB1D8), fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                '${entry.hours.toStringAsFixed(1)}h',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                entry.status,
                style: const TextStyle(
                  color: Color(0xFF8AA5D7),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tabButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF204D99) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF7D95BE),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static Widget _label(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(color: Color(0xFF8FA5CE), fontWeight: FontWeight.w500),
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF7E95BD)),
      filled: true,
      fillColor: const Color(0xFF0A1730),
      contentPadding: const EdgeInsets.all(12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFF233A60)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFF4A74B8)),
      ),
    );
  }

  Widget _dropdownField<T>({
    required T? value,
    required String hintText,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      onChanged: onChanged,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF6D85B2)),
      dropdownColor: const Color(0xFF0D1A34),
      style: const TextStyle(color: Color(0xFFE4EEFF), fontSize: 14),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: const Color(0xFF0A1730),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF233A60)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF4A74B8)),
        ),
      ),
      hint: Text(hintText, style: const TextStyle(color: Color(0xFF7E95BD))),
      items: items
          .map((T item) => DropdownMenuItem<T>(value: item, child: Text('$item')))
          .toList(),
    );
  }
}

class _HistoryHeaderRow extends StatelessWidget {
  const _HistoryHeaderRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: Text(
            'Project',
            style: TextStyle(color: Color(0xFF8DA2C9), fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(
          width: 50,
          child: Text(
            'Hours',
            style: TextStyle(color: Color(0xFF8DA2C9), fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(
          width: 60,
          child: Text(
            'Status',
            style: TextStyle(color: Color(0xFF8DA2C9), fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(
          width: 54,
          child: Text(
            'Action',
            style: TextStyle(color: Color(0xFF8DA2C9), fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111F3C),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF506084).withValues(alpha: 0.55)),
      ),
      child: child,
    );
  }
}

class _DsrEntry {
  const _DsrEntry({
    required this.project,
    required this.hours,
    required this.status,
    required this.description,
    required this.date,
  });

  final String project;
  final double hours;
  final String status;
  final String description;
  final DateTime date;

  _DsrEntry copyWith({
    String? project,
    double? hours,
    String? status,
    String? description,
    DateTime? date,
  }) {
    return _DsrEntry(
      project: project ?? this.project,
      hours: hours ?? this.hours,
      status: status ?? this.status,
      description: description ?? this.description,
      date: date ?? this.date,
    );
  }
}
