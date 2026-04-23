abstract class DsrEvent {
  const DsrEvent();
}

class DsrInitialLoadRequested extends DsrEvent {
  const DsrInitialLoadRequested();
}

class DsrDateChangedRequested extends DsrEvent {
  const DsrDateChangedRequested(this.date);

  final DateTime date;
}

class DsrHistoryLoadRequested extends DsrEvent {
  const DsrHistoryLoadRequested();
}

class DsrCreateRequested extends DsrEvent {
  const DsrCreateRequested({
    required this.projectId,
    required this.date,
    required this.description,
    required this.hours,
    required this.status,
  });

  final int projectId;
  final DateTime date;
  final String description;
  final String hours;
  final String status;
}
