import 'package:core/features/taskhub/domain/entities/board_column_entity.dart';
import 'package:core/features/taskhub/domain/entities/task_assignee_entity.dart';
import 'package:core/features/taskhub/domain/entities/task_attachment_entity.dart';
import 'package:core/features/taskhub/domain/entities/sprint_entity.dart';
import 'package:core/features/taskhub/domain/entities/task_comment_entity.dart';
import 'package:core/features/taskhub/domain/entities/task_entity.dart';
import 'package:core/features/taskhub/domain/entities/task_link_entity.dart';
import 'package:core/features/taskhub/domain/enums/task_board_type.dart';

abstract class TaskHubRepository {
  Future<List<TaskEntity>> getTasks({
    required int projectId,
    required TaskBoardType boardType,
    int? sprintId,
  });

  Future<List<BoardColumnEntity>> getBoardColumns({
    required int projectId,
    required TaskBoardType boardType,
  });

  Future<List<TaskAssigneeEntity>> getProjectAssignees({required int projectId});

  Future<TaskEntity> createTask({
    required int projectId,
    required TaskBoardType boardType,
    required int columnId,
    required String title,
    required String? descriptionHtml,
    required String? assigneeId,
    required String priority,
    required String ticketType,
    required int position,
    String? dueDateIso,
    int? sprintId,
  });

  Future<List<TaskAttachmentEntity>> getAttachments({
    required int projectId,
    required int taskId,
  });

  Future<Map<String, String>> createAttachmentUploadUrl({
    required int projectId,
    required int taskId,
    required String contentType,
    required String fileName,
    required int fileSize,
  });

  Future<void> uploadToPresignedUrl({
    required String uploadUrl,
    required List<int> bytes,
    required String contentType,
  });

  Future<void> createAttachmentMetadata({
    required int projectId,
    required int taskId,
    required String contentType,
    required String fileName,
    required String filePath,
    required int fileSize,
  });

  Future<List<TaskLinkEntity>> getLinks({
    required int projectId,
    required int taskId,
  });

  Future<void> createLink({
    required int projectId,
    required int taskId,
    required int linkedTaskId,
  });

  Future<List<TaskCommentEntity>> getComments({
    required int projectId,
    required int taskId,
  });

  Future<void> createComment({
    required int projectId,
    required int taskId,
    required String content,
  });

  Future<void> deleteTask({required int projectId, required int taskId});

  Future<TaskEntity> updateTask({
    required int projectId,
    required int taskId,
    String? assigneeId,
    int? columnId,
    String? description,
    String? dueDate,
    String? priority,
    String? ticketType,
    String? title,
    int? sprintId,
  });

  Future<void> deleteAttachment({
    required int projectId,
    required int taskId,
    required int attachmentId,
  });

  Future<List<BoardColumnEntity>> reorderBoardColumns({
    required int projectId,
    required List<int> columnIds,
  });

  Future<BoardColumnEntity> createBoardColumn({
    required int projectId,
    required String name,
    required TaskBoardType boardType,
  });

  Future<void> deleteBoardColumn({
    required int projectId,
    required int columnId,
  });

  Future<void> moveTask({
    required int projectId,
    required int taskId,
    required int columnId,
    required int position,
  });

  Future<void> deleteLink({
    required int projectId,
    required int taskId,
    required int linkId,
  });

  Future<List<SprintEntity>> getSprints(int projectId);

  Future<SprintEntity> createSprint({
    required int projectId,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required String goal,
    required String status,
  });

  Future<SprintEntity> updateSprint({
    required int projectId,
    required int sprintId,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    String? goal,
    String? status,
  });

  Future<void> deleteSprint({
    required int projectId,
    required int sprintId,
  });
}
