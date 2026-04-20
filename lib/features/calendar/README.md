# Calendar Feature

Reusable, Google-calendar-style month widget with full customization hooks.

## Included

- `CustomCalendarWidget`: month grid with day cells, events, and month navigation.
- `CalendarEvent`: event model used by default day cells.
- `CustomCalendarStyle`: colors, typography, paddings, borders, and chip styles.
- Builder hooks:
  - `headerBuilder`
  - `weekdayBuilder`
  - `dayBuilder`
  - `eventBuilder`

## Supported Customization

- Highlighted and non-highlighted date styling.
- Selected date and selected date range visuals.
- Start date / end date bounds for selectable and navigable dates.
- Custom week start day (`Sunday`/`Monday`/etc.).
- Outside-month day visibility.
- Event source from static list (`events`) or dynamic callback (`eventLoader`).

## Quick Usage

```dart
CustomCalendarWidget(
  initialMonth: DateTime.now(),
  startDate: DateTime(2026, 1, 1),
  endDate: DateTime(2026, 12, 31),
  selectedDate: DateTime.now(),
  highlightedDates: {
    DateTime(2026, 4, 10),
    DateTime(2026, 4, 13),
  },
  events: const [
    CalendarEvent(
      id: '1',
      title: 'Team Sync',
      startAt: DateTime(2026, 4, 10, 11),
      endAt: DateTime(2026, 4, 10, 12),
    ),
  ],
  style: const CustomCalendarStyle(
    selectedDayColor: Color(0xFF0F766E),
    highlightedDayColor: Color(0xFF2563EB),
  ),
  onDateSelected: (date) {
    // handle selected date
  },
)
```
