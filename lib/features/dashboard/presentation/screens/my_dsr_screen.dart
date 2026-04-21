import 'package:flutter/material.dart';

class MyDsrScreen extends StatefulWidget {
  const MyDsrScreen({super.key});

  @override
  State<MyDsrScreen> createState() => _MyDsrScreenState();
}

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
  final List<_DsrEntry> _entries = <_DsrEntry>[];

  String? _selectedProject;
  String? _selectedHours;
  String _selectedStatus = 'Completed';
  DateTime _selectedDate = DateTime.now();

  List<String> get _hoursOptions {
    return List<String>.generate(17, (int index) {
      final double value = index * 0.5;
      return '${value.toStringAsFixed(1)}h';
    });
  }

  double get _totalLoggedHours {
    return _entries.fold<double>(
      0,
      (double sum, _DsrEntry entry) => sum + entry.hours,
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String year = date.year.toString();
    return '$day/$month/$year';
  }

  void _addEntry() {
    if (_selectedProject == null || _selectedHours == null) {
      return;
    }

    final double parsedHours = double.parse(
      _selectedHours!.replaceAll('h', '').trim(),
    );

    final _DsrEntry entry = _DsrEntry(
      project: _selectedProject!,
      hours: parsedHours,
      status: _selectedStatus,
      description: _descriptionController.text.trim(),
      date: _selectedDate,
    );

    setState(() {
      _entries.add(entry);
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

    if (picked == null) {
      return;
    }

    setState(() {
      _selectedDate = picked;
      _entries.clear();
    });
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
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Daily Status Report',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Log your daily work activity and hours',
              style: TextStyle(
                color: Color(0xFF8FA5CE),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0E1B36),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2D4166)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _tabButton(
                    title: 'Add DSR',
                    selected: true,
                  ),
                  _tabButton(
                    title: 'My DSR History',
                    selected: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
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
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: Color(0xFF93AADA),
                      size: 14,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Today (${_formatDate(_selectedDate)})',
                      style: const TextStyle(
                        color: Color(0xFFDCE8FF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 18),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF93AADA),
                    ),
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
                '${_totalLoggedHours.toStringAsFixed(1)}h logged',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
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
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _label('Project'),
                    _dropdownField<String>(
                      value: _selectedProject,
                      hintText: 'Select project',
                      items: _projects,
                      onChanged: (String? value) {
                        setState(() => _selectedProject = value);
                      },
                    ),
                    const SizedBox(height: 10),
                    _label('Hours'),
                    _dropdownField<String>(
                      value: _selectedHours,
                      hintText: 'Select hours',
                      items: _hoursOptions,
                      onChanged: (String? value) {
                        setState(() => _selectedHours = value);
                      },
                    ),
                    const SizedBox(height: 10),
                    _label('Status'),
                    _dropdownField<String>(
                      value: _selectedStatus,
                      hintText: 'Select status',
                      items: _statuses,
                      onChanged: (String? value) {
                        if (value == null) return;
                        setState(() => _selectedStatus = value);
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _label('Description'),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      style: const TextStyle(color: Color(0xFFE6EFFF)),
                      decoration: InputDecoration(
                        hintText: 'What did you work on?',
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _CardShell(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: _entries.isEmpty
                    ? const SizedBox(
                        height: 110,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.error_outline,
                                color: Color(0xFF6178A5),
                                size: 22,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'No entries for this date. Add your first DSR\nentry above.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF9BB0D7),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _entries.map((e) => _entryTile(e)).toList(),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton({required String title, required bool selected}) {
    return Container(
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
    );
  }

  Widget _entryTile(_DsrEntry entry) {
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
                  style: const TextStyle(
                    color: Color(0xFFE7F0FF),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.description.isEmpty
                      ? 'No description provided.'
                      : entry.description,
                  style: const TextStyle(
                    color: Color(0xFF9CB1D8),
                    fontSize: 12,
                  ),
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
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
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

  static Widget _label(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF8FA5CE),
          fontWeight: FontWeight.w500,
        ),
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
      hint: Text(
        hintText,
        style: const TextStyle(color: Color(0xFF7E95BD)),
      ),
      items: items
          .map(
            (T item) => DropdownMenuItem<T>(
              value: item,
              child: Text('$item'),
            ),
          )
          .toList(),
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
}
