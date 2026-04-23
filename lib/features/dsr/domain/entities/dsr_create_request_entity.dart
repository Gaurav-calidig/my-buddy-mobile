class DsrCreateRequestEntity {
  const DsrCreateRequestEntity({
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

