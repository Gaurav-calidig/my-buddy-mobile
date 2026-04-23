class AmsStatEntity {
  const AmsStatEntity({
    required this.label,
    required this.value,
    required this.caption,
  });

  final String label;
  final String value;
  final String caption;
}

class AmsLeaveSummaryEntity {
  const AmsLeaveSummaryEntity({
    required this.allocated,
    required this.used,
    required this.balance,
    required this.casual,
    required this.sick,
  });

  final int allocated;
  final int used;
  final int balance;
  final String casual;
  final String sick;
}

class AmsLeaveEventEntity {
  const AmsLeaveEventEntity({
    required this.title,
    required this.colorHex,
  });

  final String title;
  final int colorHex;
}

class AmsCalendarDayEntity {
  const AmsCalendarDayEntity({
    required this.date,
    required this.isInCurrentMonth,
    this.events = const <AmsLeaveEventEntity>[],
  });

  final DateTime date;
  final bool isInCurrentMonth;
  final List<AmsLeaveEventEntity> events;
}
