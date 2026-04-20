import 'package:core/features/calendar/domain/entities/calendar_event.dart';
import 'package:core/features/calendar/presentation/widgets/custom_calendar_widget.dart';
import 'package:flutter/material.dart';

class CalendarTestScreen extends StatefulWidget {
  const CalendarTestScreen({super.key});

  @override
  State<CalendarTestScreen> createState() => _CalendarTestScreenState();
}

class _CalendarTestScreenState extends State<CalendarTestScreen> {
  DateTime? _selectedDate;
  bool _showOutsideDays = true;
  bool _sundayStart = true;
  bool _useAltPalette = false;

  DateTime get _today => DateUtils.dateOnly(DateTime.now());

  Set<DateTime> get _highlightedDates => <DateTime>{
    _today,
    _today.add(const Duration(days: 2)),
    _today.add(const Duration(days: 6)),
    _today.subtract(const Duration(days: 3)),
  };

  List<CalendarEvent> get _events => <CalendarEvent>[
    CalendarEvent(
      id: 'evt-standup',
      title: 'Standup',
      startAt: DateTime(_today.year, _today.month, _today.day, 10),
      backgroundColor: const Color(0xFFE6F4EA),
      borderColor: const Color(0xFF82C99A),
    ),
    CalendarEvent(
      id: 'evt-design',
      title: 'Design Review',
      startAt: DateTime(_today.year, _today.month, _today.day + 2, 14),
      backgroundColor: const Color(0xFFE8F0FE),
      borderColor: const Color(0xFF8AB4F8),
    ),
    CalendarEvent(
      id: 'evt-release',
      title: 'Release Window',
      startAt: DateTime(_today.year, _today.month, _today.day + 6, 9),
      endAt: DateTime(_today.year, _today.month, _today.day + 7, 18),
      backgroundColor: const Color(0xFFFFF4E5),
      borderColor: const Color(0xFFF6C17A),
    ),
    CalendarEvent(
      id: 'evt-sync-1',
      title: 'Client Sync',
      startAt: DateTime(_today.year, _today.month, _today.day + 6, 17),
      backgroundColor: const Color(0xFFFDECEC),
      borderColor: const Color(0xFFEF9A9A),
    ),
    CalendarEvent(
      id: 'evt-sync-2',
      title: 'Budget Review',
      startAt: DateTime(_today.year, _today.month, _today.day + 6, 18),
      backgroundColor: const Color(0xFFF3E8FF),
      borderColor: const Color(0xFFD8B4FE),
    ),
  ];

  CustomCalendarStyle get _style {
    if (_useAltPalette) {
      return const CustomCalendarStyle(
        selectedDayColor: Color(0xFFBE123C),
        highlightedDayColor: Color(0xFF1D4ED8),
        selectedRangeColor: Color(0x1ABE123C),
        headerBackgroundColor: Color(0xFFFDF2F8),
        weekdayBackgroundColor: Color(0xFFFFF1F2),
        defaultEventBackgroundColor: Color(0xFFFFFBEB),
        defaultEventBorderColor: Color(0xFFFCD34D),
      );
    }
    return const CustomCalendarStyle(
      selectedDayColor: Color(0xFF0F766E),
      highlightedDayColor: Color(0xFF2563EB),
      selectedRangeColor: Color(0x142563EB),
      headerBackgroundColor: Color(0xFFF8FAFC),
      weekdayBackgroundColor: Color(0xFFF8FAFC),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime rangeStart = _today.subtract(const Duration(days: 45));
    final DateTime rangeEnd = _today.add(const Duration(days: 120));

    return Scaffold(
      appBar: AppBar(title: const Text('Custom Calendar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CustomCalendarWidget(
            initialMonth: _today,
            selectedDate: _selectedDate,
            selectedRangeStart: _today.subtract(const Duration(days: 2)),
            selectedRangeEnd: _today.add(const Duration(days: 5)),
            startDate: rangeStart,
            endDate: rangeEnd,
            highlightedDates: _highlightedDates,
            events: _events,
            style: _style,
            weekStartsOn: _sundayStart ? DateTime.sunday : DateTime.monday,
            showOutsideDays: _showOutsideDays,
            maxEventsPerDay: 2,
            onDateSelected: (DateTime date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live Options',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _showOutsideDays,
                    title: const Text('Show outside month dates'),
                    onChanged: (bool value) {
                      setState(() => _showOutsideDays = value);
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _sundayStart,
                    title: const Text('Week starts on Sunday'),
                    onChanged: (bool value) {
                      setState(() => _sundayStart = value);
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _useAltPalette,
                    title: const Text('Use alternate color palette'),
                    onChanged: (bool value) {
                      setState(() => _useAltPalette = value);
                    },
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _selectedDate == null
                        ? 'Selected date: none'
                        : 'Selected date: ${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Selectable range: '
                    '${rangeStart.year}-${rangeStart.month.toString().padLeft(2, '0')}-${rangeStart.day.toString().padLeft(2, '0')} '
                    'to '
                    '${rangeEnd.year}-${rangeEnd.month.toString().padLeft(2, '0')}-${rangeEnd.day.toString().padLeft(2, '0')}',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
