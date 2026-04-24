import 'package:core/features/taskhub/domain/entities/task_comment_entity.dart';

class TaskCommentModel extends TaskCommentEntity {
  const TaskCommentModel({
    required super.id,
    required super.taskId,
    required super.userId,
    required super.userName,
    required super.content,
    super.createdAt,
  });

  factory TaskCommentModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final name = user == null
        ? ''
        : '${(user['firstName'] ?? '').toString()} ${(user['lastName'] ?? '').toString()}'
            .trim();
    return TaskCommentModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      taskId: (json['taskId'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] ?? '').toString(),
      userName: name.isEmpty ? (user?['email'] ?? '').toString() : name,
      content: (json['content'] ?? '').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}

