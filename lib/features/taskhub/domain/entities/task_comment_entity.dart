import 'package:equatable/equatable.dart';

class TaskCommentEntity extends Equatable {
  final int id;
  final int taskId;
  final String userId;
  final String userName;
  final String content;
  final DateTime? createdAt;

  const TaskCommentEntity({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.userName,
    required this.content,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, taskId, userId, userName, content, createdAt];
}

