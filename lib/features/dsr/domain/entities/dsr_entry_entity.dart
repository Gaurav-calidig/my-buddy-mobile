class DsrEntryEntity {
  const DsrEntryEntity({
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

  DsrEntryEntity copyWith({
    String? project,
    double? hours,
    String? status,
    String? description,
    DateTime? date,
  }) {
    return DsrEntryEntity(
      project: project ?? this.project,
      hours: hours ?? this.hours,
      status: status ?? this.status,
      description: description ?? this.description,
      date: date ?? this.date,
    );
  }
}

