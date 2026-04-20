import 'package:core/features/calendar/domain/entities/calendar_event.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

typedef CalendarHeaderBuilder =
    Widget Function(
      BuildContext context,
      DateTime visibleMonth,
      VoidCallback onPreviousMonth,
      VoidCallback onNextMonth,
    );

typedef CalendarWeekdayBuilder =
    Widget Function(BuildContext context, int weekday, String label);

typedef CalendarDayBuilder =
    Widget Function(
      BuildContext context,
      DateTime date,
      CalendarDayState state,
      List<CalendarEvent> events,
    );

typedef CalendarEventBuilder =
    Widget Function(BuildContext context, DateTime date, CalendarEvent event);

@immutable
class CalendarDayState {
  const CalendarDayState({
    required this.isCurrentMonth,
    required this.isToday,
    required this.isSelected,
    required this.isHighlighted,
    required this.isDisabled,
    required this.isInSelectedRange,
  });

  final bool isCurrentMonth;
  final bool isToday;
  final bool isSelected;
  final bool isHighlighted;
  final bool isDisabled;
  final bool isInSelectedRange;
}

@immutable
class CustomCalendarStyle {
  const CustomCalendarStyle({
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFFE5E7EB),
    this.headerBackgroundColor = Colors.transparent,
    this.weekdayBackgroundColor = const Color(0xFFF8FAFC),
    this.monthTitleTextStyle = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: Color(0xFF111827),
    ),
    this.weekdayTextStyle = const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Color(0xFF6B7280),
    ),
    this.dayTextStyle = const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Color(0xFF111827),
    ),
    this.outsideMonthDayTextStyle = const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Color(0xFF9CA3AF),
    ),
    this.selectedDayTextStyle = const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
    this.highlightedDayTextStyle = const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
    this.todayDayTextStyle = const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: Color(0xFF111827),
    ),
    this.disabledDayTextStyle = const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Color(0xFFD1D5DB),
    ),
    this.eventTextStyle = const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: Color(0xFF111827),
    ),
    this.selectedDayColor = const Color(0xFF0F766E),
    this.highlightedDayColor = const Color(0xFF2563EB),
    this.todayBorderColor = const Color(0xFF111827),
    this.selectedRangeColor = const Color(0x142563EB),
    this.defaultEventBackgroundColor = const Color(0xFFF8FAFC),
    this.defaultEventBorderColor = const Color(0xFFE2E8F0),
    this.cellPadding = const EdgeInsets.all(6),
    this.headerPadding = const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    this.weekdayPadding = const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 10,
    ),
    this.dayNumberPadding = const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 4,
    ),
    this.eventPadding = const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    this.cellBorderRadius = const BorderRadius.all(Radius.circular(0)),
    this.dayNumberBorderRadius = const BorderRadius.all(Radius.circular(999)),
    this.eventBorderRadius = const BorderRadius.all(Radius.circular(6)),
    this.showOuterBorder = true,
    this.showCellBorder = true,
  });

  final Color backgroundColor;
  final Color borderColor;
  final Color headerBackgroundColor;
  final Color weekdayBackgroundColor;
  final TextStyle monthTitleTextStyle;
  final TextStyle weekdayTextStyle;
  final TextStyle dayTextStyle;
  final TextStyle outsideMonthDayTextStyle;
  final TextStyle selectedDayTextStyle;
  final TextStyle highlightedDayTextStyle;
  final TextStyle todayDayTextStyle;
  final TextStyle disabledDayTextStyle;
  final TextStyle eventTextStyle;
  final Color selectedDayColor;
  final Color highlightedDayColor;
  final Color todayBorderColor;
  final Color selectedRangeColor;
  final Color defaultEventBackgroundColor;
  final Color defaultEventBorderColor;
  final EdgeInsetsGeometry cellPadding;
  final EdgeInsetsGeometry headerPadding;
  final EdgeInsetsGeometry weekdayPadding;
  final EdgeInsetsGeometry dayNumberPadding;
  final EdgeInsetsGeometry eventPadding;
  final BorderRadiusGeometry cellBorderRadius;
  final BorderRadiusGeometry dayNumberBorderRadius;
  final BorderRadiusGeometry eventBorderRadius;
  final bool showOuterBorder;
  final bool showCellBorder;

  CustomCalendarStyle copyWith({
    Color? backgroundColor,
    Color? borderColor,
    Color? headerBackgroundColor,
    Color? weekdayBackgroundColor,
    TextStyle? monthTitleTextStyle,
    TextStyle? weekdayTextStyle,
    TextStyle? dayTextStyle,
    TextStyle? outsideMonthDayTextStyle,
    TextStyle? selectedDayTextStyle,
    TextStyle? highlightedDayTextStyle,
    TextStyle? todayDayTextStyle,
    TextStyle? disabledDayTextStyle,
    TextStyle? eventTextStyle,
    Color? selectedDayColor,
    Color? highlightedDayColor,
    Color? todayBorderColor,
    Color? selectedRangeColor,
    Color? defaultEventBackgroundColor,
    Color? defaultEventBorderColor,
    EdgeInsetsGeometry? cellPadding,
    EdgeInsetsGeometry? headerPadding,
    EdgeInsetsGeometry? weekdayPadding,
    EdgeInsetsGeometry? dayNumberPadding,
    EdgeInsetsGeometry? eventPadding,
    BorderRadiusGeometry? cellBorderRadius,
    BorderRadiusGeometry? dayNumberBorderRadius,
    BorderRadiusGeometry? eventBorderRadius,
    bool? showOuterBorder,
    bool? showCellBorder,
  }) {
    return CustomCalendarStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      headerBackgroundColor:
          headerBackgroundColor ?? this.headerBackgroundColor,
      weekdayBackgroundColor:
          weekdayBackgroundColor ?? this.weekdayBackgroundColor,
      monthTitleTextStyle: monthTitleTextStyle ?? this.monthTitleTextStyle,
      weekdayTextStyle: weekdayTextStyle ?? this.weekdayTextStyle,
      dayTextStyle: dayTextStyle ?? this.dayTextStyle,
      outsideMonthDayTextStyle:
          outsideMonthDayTextStyle ?? this.outsideMonthDayTextStyle,
      selectedDayTextStyle: selectedDayTextStyle ?? this.selectedDayTextStyle,
      highlightedDayTextStyle:
          highlightedDayTextStyle ?? this.highlightedDayTextStyle,
      todayDayTextStyle: todayDayTextStyle ?? this.todayDayTextStyle,
      disabledDayTextStyle: disabledDayTextStyle ?? this.disabledDayTextStyle,
      eventTextStyle: eventTextStyle ?? this.eventTextStyle,
      selectedDayColor: selectedDayColor ?? this.selectedDayColor,
      highlightedDayColor: highlightedDayColor ?? this.highlightedDayColor,
      todayBorderColor: todayBorderColor ?? this.todayBorderColor,
      selectedRangeColor: selectedRangeColor ?? this.selectedRangeColor,
      defaultEventBackgroundColor:
          defaultEventBackgroundColor ?? this.defaultEventBackgroundColor,
      defaultEventBorderColor:
          defaultEventBorderColor ?? this.defaultEventBorderColor,
      cellPadding: cellPadding ?? this.cellPadding,
      headerPadding: headerPadding ?? this.headerPadding,
      weekdayPadding: weekdayPadding ?? this.weekdayPadding,
      dayNumberPadding: dayNumberPadding ?? this.dayNumberPadding,
      eventPadding: eventPadding ?? this.eventPadding,
      cellBorderRadius: cellBorderRadius ?? this.cellBorderRadius,
      dayNumberBorderRadius:
          dayNumberBorderRadius ?? this.dayNumberBorderRadius,
      eventBorderRadius: eventBorderRadius ?? this.eventBorderRadius,
      showOuterBorder: showOuterBorder ?? this.showOuterBorder,
      showCellBorder: showCellBorder ?? this.showCellBorder,
    );
  }
}

/// A reusable month-view calendar where styling and rendering hooks are fully customizable.
class CustomCalendarWidget extends StatefulWidget {
  const CustomCalendarWidget({
    super.key,
    this.initialMonth,
    this.selectedDate,
    this.selectedRangeStart,
    this.selectedRangeEnd,
    this.startDate,
    this.endDate,
    this.onDateSelected,
    this.onMonthChanged,
    this.highlightedDates = const <DateTime>{},
    this.isDateHighlighted,
    this.isDateEnabled,
    this.events = const <CalendarEvent>[],
    this.eventLoader,
    this.headerBuilder,
    this.weekdayBuilder,
    this.dayBuilder,
    this.eventBuilder,
    this.style = const CustomCalendarStyle(),
    this.locale,
    this.weekStartsOn = DateTime.sunday,
    this.showOutsideDays = true,
    this.fixedSixWeekRows = true,
    this.maxEventsPerDay = 2,
    this.showMoreEventsIndicator = true,
    this.dayCellHeight = 110,
  }) : assert(
         weekStartsOn >= DateTime.monday && weekStartsOn <= DateTime.sunday,
         'weekStartsOn must be a valid weekday (1..7).',
       );

  final DateTime? initialMonth;
  final DateTime? selectedDate;
  final DateTime? selectedRangeStart;
  final DateTime? selectedRangeEnd;
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<DateTime>? onDateSelected;
  final ValueChanged<DateTime>? onMonthChanged;
  final Set<DateTime> highlightedDates;
  final bool Function(DateTime date)? isDateHighlighted;
  final bool Function(DateTime date)? isDateEnabled;
  final List<CalendarEvent> events;
  final List<CalendarEvent> Function(DateTime date)? eventLoader;
  final CalendarHeaderBuilder? headerBuilder;
  final CalendarWeekdayBuilder? weekdayBuilder;
  final CalendarDayBuilder? dayBuilder;
  final CalendarEventBuilder? eventBuilder;
  final CustomCalendarStyle style;
  final String? locale;
  final int weekStartsOn;
  final bool showOutsideDays;
  final bool fixedSixWeekRows;
  final int maxEventsPerDay;
  final bool showMoreEventsIndicator;
  final double dayCellHeight;

  @override
  State<CustomCalendarWidget> createState() => _CustomCalendarWidgetState();
}

class _CustomCalendarWidgetState extends State<CustomCalendarWidget> {
  late DateTime _visibleMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateUtils.dateOnly(DateTime.now());
    final DateTime initialSource =
        widget.initialMonth ?? widget.selectedDate ?? now;
    _visibleMonth = _clampToAllowedMonth(_monthOnly(initialSource));
    _selectedDate = widget.selectedDate == null
        ? null
        : DateUtils.dateOnly(widget.selectedDate!);
  }

  @override
  void didUpdateWidget(covariant CustomCalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      _selectedDate = widget.selectedDate == null
          ? null
          : DateUtils.dateOnly(widget.selectedDate!);
    }
    if (widget.startDate != oldWidget.startDate ||
        widget.endDate != oldWidget.endDate) {
      _visibleMonth = _clampToAllowedMonth(_visibleMonth);
    }
  }

  DateTime _monthOnly(DateTime value) => DateTime(value.year, value.month);

  DateTime _clampToAllowedMonth(DateTime month) {
    final DateTime monthStart = _monthOnly(month);
    final DateTime? allowedStart = widget.startDate == null
        ? null
        : _monthOnly(DateUtils.dateOnly(widget.startDate!));
    final DateTime? allowedEnd = widget.endDate == null
        ? null
        : _monthOnly(DateUtils.dateOnly(widget.endDate!));

    if (allowedStart != null && monthStart.isBefore(allowedStart)) {
      return allowedStart;
    }
    if (allowedEnd != null && monthStart.isAfter(allowedEnd)) {
      return allowedEnd;
    }
    return monthStart;
  }

  bool _isMonthAllowed(DateTime month) {
    final DateTime monthStart = _monthOnly(month);
    final DateTime monthEnd = DateTime(month.year, month.month + 1, 0);
    final DateTime? startDate = widget.startDate == null
        ? null
        : DateUtils.dateOnly(widget.startDate!);
    final DateTime? endDate = widget.endDate == null
        ? null
        : DateUtils.dateOnly(widget.endDate!);

    if (startDate != null && monthEnd.isBefore(startDate)) {
      return false;
    }
    if (endDate != null && monthStart.isAfter(endDate)) {
      return false;
    }
    return true;
  }

  void _changeMonth(int delta) {
    final DateTime nextMonth = _monthOnly(
      DateTime(_visibleMonth.year, _visibleMonth.month + delta),
    );
    if (!_isMonthAllowed(nextMonth)) return;

    setState(() {
      _visibleMonth = nextMonth;
    });
    widget.onMonthChanged?.call(nextMonth);
  }

  bool _isSameDay(DateTime a, DateTime b) => DateUtils.isSameDay(a, b);

  bool _isDayDisabled(DateTime day) {
    final DateTime date = DateUtils.dateOnly(day);
    final DateTime? startDate = widget.startDate == null
        ? null
        : DateUtils.dateOnly(widget.startDate!);
    final DateTime? endDate = widget.endDate == null
        ? null
        : DateUtils.dateOnly(widget.endDate!);
    if (startDate != null && date.isBefore(startDate)) return true;
    if (endDate != null && date.isAfter(endDate)) return true;
    if (widget.isDateEnabled != null) {
      return !widget.isDateEnabled!(date);
    }
    return false;
  }

  bool _isDayHighlighted(
    DateTime day,
    Set<DateTime> normalizedHighlightedDays,
  ) {
    if (normalizedHighlightedDays.contains(day)) return true;
    if (widget.isDateHighlighted != null) {
      return widget.isDateHighlighted!(day);
    }
    return false;
  }

  bool _isInSelectedRange(DateTime day) {
    if (widget.selectedRangeStart == null || widget.selectedRangeEnd == null) {
      return false;
    }
    final DateTime start = DateUtils.dateOnly(widget.selectedRangeStart!);
    final DateTime end = DateUtils.dateOnly(widget.selectedRangeEnd!);
    final DateTime normalized = DateUtils.dateOnly(day);

    final DateTime from = start.isBefore(end) ? start : end;
    final DateTime to = start.isBefore(end) ? end : start;
    return !normalized.isBefore(from) && !normalized.isAfter(to);
  }

  List<DateTime> _visibleDays() {
    final DateTime firstOfMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month,
      1,
    );
    final int offset =
        (firstOfMonth.weekday - widget.weekStartsOn + DateTime.daysPerWeek) %
        DateTime.daysPerWeek;
    final DateTime firstVisibleDay = firstOfMonth.subtract(
      Duration(days: offset),
    );

    if (widget.fixedSixWeekRows) {
      return List<DateTime>.generate(
        42,
        (int index) =>
            DateUtils.dateOnly(firstVisibleDay.add(Duration(days: index))),
      );
    }

    final int daysInMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month + 1,
      0,
    ).day;
    final int totalCells = ((offset + daysInMonth) / 7).ceil() * 7;
    return List<DateTime>.generate(
      totalCells,
      (int index) =>
          DateUtils.dateOnly(firstVisibleDay.add(Duration(days: index))),
    );
  }

  List<String> _weekdayLabels() {
    final String pattern = 'EEE';
    return List<String>.generate(7, (int index) {
      final int weekday =
          ((widget.weekStartsOn + index - 1) % DateTime.daysPerWeek) + 1;
      final DateTime referenceDate = DateTime(2024, 1, weekday);
      return DateFormat(pattern, widget.locale).format(referenceDate);
    });
  }

  Map<DateTime, List<CalendarEvent>> _groupEventsByDay() {
    final Map<DateTime, List<CalendarEvent>> grouped =
        <DateTime, List<CalendarEvent>>{};
    for (final CalendarEvent event in widget.events) {
      final DateTime start = DateUtils.dateOnly(event.startAt);
      final DateTime end = DateUtils.dateOnly(event.endAt ?? event.startAt);
      final DateTime from = start.isBefore(end) ? start : end;
      final DateTime to = start.isBefore(end) ? end : start;
      DateTime cursor = from;
      while (!cursor.isAfter(to)) {
        grouped.putIfAbsent(cursor, () => <CalendarEvent>[]).add(event);
        cursor = cursor.add(const Duration(days: 1));
      }
    }

    for (final List<CalendarEvent> dayEvents in grouped.values) {
      dayEvents.sort((a, b) => a.startAt.compareTo(b.startAt));
    }
    return grouped;
  }

  List<CalendarEvent> _eventsForDay(
    DateTime day,
    Map<DateTime, List<CalendarEvent>> groupedEvents,
  ) {
    if (widget.eventLoader != null) {
      return widget.eventLoader!(day);
    }
    return groupedEvents[day] ?? const <CalendarEvent>[];
  }

  void _onTapDay(DateTime day, CalendarDayState state) {
    if (state.isDisabled) return;
    setState(() {
      _selectedDate = day;
    });
    widget.onDateSelected?.call(day);
  }

  @override
  Widget build(BuildContext context) {
    final Map<DateTime, List<CalendarEvent>> groupedEvents =
        _groupEventsByDay();
    final List<DateTime> visibleDays = _visibleDays();
    final List<String> weekdayLabels = _weekdayLabels();
    final DateTime today = DateUtils.dateOnly(DateTime.now());
    final Set<DateTime> highlightedDays = widget.highlightedDates
        .map<DateTime>(DateUtils.dateOnly)
        .toSet();

    return Container(
      decoration: BoxDecoration(
        color: widget.style.backgroundColor,
        borderRadius: widget.style.cellBorderRadius,
        border: widget.style.showOuterBorder
            ? Border.all(color: widget.style.borderColor)
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          _buildWeekdayRow(weekdayLabels),
          Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.top,
            children: List<TableRow>.generate((visibleDays.length / 7).ceil(), (
              int weekIndex,
            ) {
              return TableRow(
                children: List<Widget>.generate(7, (int dayIndex) {
                  final int index = (weekIndex * 7) + dayIndex;
                  if (index >= visibleDays.length) {
                    return const SizedBox.shrink();
                  }
                  final DateTime day = visibleDays[index];
                  final bool isCurrentMonth = day.month == _visibleMonth.month;
                  final bool isToday = _isSameDay(day, today);
                  final bool isSelected =
                      _selectedDate != null && _isSameDay(day, _selectedDate!);
                  final bool isDisabled = _isDayDisabled(day);
                  final bool isHighlighted = _isDayHighlighted(
                    day,
                    highlightedDays,
                  );
                  final bool isInRange = _isInSelectedRange(day);
                  final CalendarDayState state = CalendarDayState(
                    isCurrentMonth: isCurrentMonth,
                    isToday: isToday,
                    isSelected: isSelected,
                    isHighlighted: isHighlighted,
                    isDisabled: isDisabled,
                    isInSelectedRange: isInRange,
                  );
                  final List<CalendarEvent> events = _eventsForDay(
                    day,
                    groupedEvents,
                  );

                  if (!widget.showOutsideDays && !isCurrentMonth) {
                    return SizedBox(height: widget.dayCellHeight);
                  }

                  return SizedBox(
                    height: widget.dayCellHeight,
                    child: InkWell(
                      onTap: () => _onTapDay(day, state),
                      child:
                          widget.dayBuilder?.call(
                            context,
                            day,
                            state,
                            events,
                          ) ??
                          _buildDefaultDayCell(day, state, events),
                    ),
                  );
                }),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    if (widget.headerBuilder != null) {
      return widget.headerBuilder!(
        context,
        _visibleMonth,
        () => _changeMonth(-1),
        () => _changeMonth(1),
      );
    }

    final bool canGoPrevious = _isMonthAllowed(
      DateTime(_visibleMonth.year, _visibleMonth.month - 1),
    );
    final bool canGoNext = _isMonthAllowed(
      DateTime(_visibleMonth.year, _visibleMonth.month + 1),
    );

    return Container(
      color: widget.style.headerBackgroundColor,
      padding: widget.style.headerPadding,
      child: Row(
        children: [
          IconButton(
            onPressed: canGoPrevious ? () => _changeMonth(-1) : null,
            icon: const Icon(Icons.chevron_left_rounded),
            tooltip: 'Previous month',
          ),
          Expanded(
            child: Text(
              DateFormat('MMMM y', widget.locale).format(_visibleMonth),
              textAlign: TextAlign.center,
              style: widget.style.monthTitleTextStyle,
            ),
          ),
          IconButton(
            onPressed: canGoNext ? () => _changeMonth(1) : null,
            icon: const Icon(Icons.chevron_right_rounded),
            tooltip: 'Next month',
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayRow(List<String> labels) {
    return Container(
      color: widget.style.weekdayBackgroundColor,
      child: Row(
        children: List<Widget>.generate(7, (int index) {
          final int weekday =
              ((widget.weekStartsOn + index - 1) % DateTime.daysPerWeek) + 1;
          if (widget.weekdayBuilder != null) {
            return Expanded(
              child: widget.weekdayBuilder!(context, weekday, labels[index]),
            );
          }
          return Expanded(
            child: Padding(
              padding: widget.style.weekdayPadding,
              child: Text(
                labels[index],
                textAlign: TextAlign.center,
                style: widget.style.weekdayTextStyle,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDefaultDayCell(
    DateTime day,
    CalendarDayState state,
    List<CalendarEvent> events,
  ) {
    final Color? baseFill = state.isSelected
        ? widget.style.selectedDayColor.withValues(alpha: 0.14)
        : state.isInSelectedRange
        ? widget.style.selectedRangeColor
        : null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: baseFill,
        border: widget.style.showCellBorder
            ? Border(
                top: BorderSide(color: widget.style.borderColor),
                left: BorderSide(color: widget.style.borderColor),
              )
            : null,
      ),
      child: Padding(
        padding: widget.style.cellPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDayBadge(day, state),
            const SizedBox(height: 6),
            Expanded(child: _buildEventsList(day, events)),
          ],
        ),
      ),
    );
  }

  Widget _buildDayBadge(DateTime day, CalendarDayState state) {
    final TextStyle textStyle = state.isDisabled
        ? widget.style.disabledDayTextStyle
        : state.isSelected
        ? widget.style.selectedDayTextStyle
        : state.isHighlighted
        ? widget.style.highlightedDayTextStyle
        : state.isToday
        ? widget.style.todayDayTextStyle
        : state.isCurrentMonth
        ? widget.style.dayTextStyle
        : widget.style.outsideMonthDayTextStyle;

    final Color? fillColor = state.isSelected
        ? widget.style.selectedDayColor
        : state.isHighlighted
        ? widget.style.highlightedDayColor
        : null;

    final Border? border =
        state.isToday && !state.isSelected && !state.isHighlighted
        ? Border.all(color: widget.style.todayBorderColor)
        : null;

    return Container(
      padding: widget.style.dayNumberPadding,
      decoration: BoxDecoration(
        color: fillColor,
        border: border,
        borderRadius: widget.style.dayNumberBorderRadius,
      ),
      child: Text('${day.day}', style: textStyle),
    );
  }

  Widget _buildEventsList(DateTime day, List<CalendarEvent> events) {
    if (events.isEmpty) return const SizedBox.shrink();

    final int visibleCount = events.length <= widget.maxEventsPerDay
        ? events.length
        : widget.maxEventsPerDay;
    final List<CalendarEvent> visibleEvents = events
        .take(visibleCount)
        .toList();
    final int remaining = events.length - visibleEvents.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...visibleEvents.map(
          (CalendarEvent event) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child:
                widget.eventBuilder?.call(context, day, event) ??
                _buildDefaultEventChip(event),
          ),
        ),
        if (widget.showMoreEventsIndicator && remaining > 0)
          Text(
            '+$remaining more',
            style: widget.style.weekdayTextStyle.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }

  Widget _buildDefaultEventChip(CalendarEvent event) {
    final Color backgroundColor =
        event.backgroundColor ?? widget.style.defaultEventBackgroundColor;
    final Color borderColor =
        event.borderColor ?? widget.style.defaultEventBorderColor;
    final TextStyle textStyle = widget.style.eventTextStyle.copyWith(
      color: event.textColor ?? widget.style.eventTextStyle.color,
    );

    return Container(
      padding: widget.style.eventPadding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: widget.style.eventBorderRadius,
        border: Border.all(color: borderColor),
      ),
      child: Text(
        event.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textStyle,
      ),
    );
  }
}
