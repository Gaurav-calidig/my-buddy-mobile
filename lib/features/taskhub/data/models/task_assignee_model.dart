import 'package:core/features/taskhub/domain/entities/task_assignee_entity.dart';

class TaskAssigneeModel extends TaskAssigneeEntity {
  const TaskAssigneeModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
  });

  factory TaskAssigneeModel.fromProjectMemberJson(Map<String, dynamic> json) {
    final user = (json['user'] as Map<String, dynamic>?) ?? const {};
    return TaskAssigneeModel(
      id: (user['id'] ?? '').toString(),
      firstName: (user['firstName'] ?? '').toString(),
      lastName: (user['lastName'] ?? '').toString(),
      email: (user['email'] ?? '').toString(),
    );
  }
}

