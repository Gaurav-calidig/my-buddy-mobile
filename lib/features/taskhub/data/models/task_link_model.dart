import 'package:core/features/taskhub/domain/entities/task_link_entity.dart';

class TaskLinkModel extends TaskLinkEntity {
  const TaskLinkModel({
    required super.id,
    required super.parentTaskId,
    required super.childTaskId,
    required super.linkedTaskDisplayId,
    required super.linkedTaskTitle,
  });

  factory TaskLinkModel.fromJson(Map<String, dynamic> json) {
    final linkedTask = json['linkedTask'] as Map<String, dynamic>? ?? const {};
    return TaskLinkModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      parentTaskId: (json['parentTaskId'] as num?)?.toInt() ?? 0,
      childTaskId: (json['childTaskId'] as num?)?.toInt() ?? 0,
      linkedTaskDisplayId: (json['linkedTaskDisplayId'] ?? '').toString(),
      linkedTaskTitle: (linkedTask['title'] ?? '').toString(),
    );
  }
}

