import 'package:core/features/taskhub/domain/entities/sprint_entity.dart';

class SprintModel extends SprintEntity {
  const SprintModel({
    required super.id,
    required super.projectId,
    required super.name,
    required super.startDate,
    required super.endDate,
    required super.goal,
    required super.status,
  });

  factory SprintModel.fromJson(Map<String, dynamic> json) {
    return SprintModel(
      id: json['id'] as int,
      projectId: json['projectId'] as int,
      name: json['name'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      goal: (json['goal'] as String?) ?? '',
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'name': name,
      'startDate': startDate.toIso8601String().split('T')[0],
      'endDate': endDate.toIso8601String().split('T')[0],
      'goal': goal,
      'status': status,
    };
  }
}
