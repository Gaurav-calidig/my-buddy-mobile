import 'package:equatable/equatable.dart';

class SprintEntity extends Equatable {
  final int id;
  final int projectId;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String goal;
  final String status;

  const SprintEntity({
    required this.id,
    required this.projectId,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.goal,
    required this.status,
  });

  @override
  List<Object?> get props => [id, projectId, name, startDate, endDate, goal, status];

  SprintEntity copyWith({
    int? id,
    int? projectId,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    String? goal,
    String? status,
  }) {
    return SprintEntity(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      goal: goal ?? this.goal,
      status: status ?? this.status,
    );
  }
}
