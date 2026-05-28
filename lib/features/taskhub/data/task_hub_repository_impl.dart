import 'package:core/features/taskhub/data/datasources/task_hub_remote_data_source.dart';
import 'package:core/features/taskhub/domain/entities/board_column_entity.dart';
import 'package:core/features/taskhub/domain/entities/sprint_entity.dart';
import 'package:core/features/taskhub/domain/entities/task_assignee_entity.dart';
import 'package:core/features/taskhub/domain/entities/task_attachment_entity.dart';
import 'package:core/features/taskhub/domain/entities/task_comment_entity.dart';
import 'package:core/features/taskhub/domain/entities/task_entity.dart';
import 'package:core/features/taskhub/domain/entities/task_link_entity.dart';
import 'package:core/features/taskhub/domain/enums/task_board_type.dart';
import 'package:core/features/taskhub/domain/repositories/task_hub_repository.dart';

class TaskHubRepositoryImpl implements TaskHubRepository {
  final TaskHubRemoteDataSource remoteDataSource;

  TaskHubRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<TaskEntity>> getTasks({
    required int projectId,
    required TaskBoardType boardType,
    int? sprintId,
  }) => remoteDataSource.getTasks(
    projectId: projectId,
    boardType: boardType,
    sprintId: sprintId,
  );

  @override
  Future<List<BoardColumnEntity>> getBoardColumns({
    required int projectId,
    required TaskBoardType boardType,
  }) => remoteDataSource.getBoardColumns(
    projectId: projectId,
    boardType: boardType,
  );

  @override
  Future<List<TaskAssigneeEntity>> getProjectAssignees({
    required int projectId,
  }) => remoteDataSource.getProjectAssignees(projectId: projectId);

  @override
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
  }) => remoteDataSource.createTask(
    projectId: projectId,
    boardType: boardType,
    columnId: columnId,
    title: title,
    descriptionHtml: descriptionHtml,
    assigneeId: assigneeId,
    priority: priority,
    ticketType: ticketType,
    position: position,
    dueDateIso: dueDateIso,
    sprintId: sprintId,
  );

  @override
  Future<List<TaskAttachmentEntity>> getAttachments({
    required int projectId,
    required int taskId,
  }) => remoteDataSource.getAttachments(projectId: projectId, taskId: taskId);

  @override
  Future<Map<String, String>> createAttachmentUploadUrl({
    required int projectId,
    required int taskId,
    required String contentType,
    required String fileName,
    required int fileSize,
  }) => remoteDataSource.createAttachmentUploadUrl(
    projectId: projectId,
    taskId: taskId,
    contentType: contentType,
    fileName: fileName,
    fileSize: fileSize,
  );

  @override
  Future<void> uploadToPresignedUrl({
    required String uploadUrl,
    required List<int> bytes,
    required String contentType,
  }) => remoteDataSource.uploadToPresignedUrl(
    uploadUrl: uploadUrl,
    bytes: bytes,
    contentType: contentType,
  );

  @override
  Future<void> createAttachmentMetadata({
    required int projectId,
    required int taskId,
    required String contentType,
    required String fileName,
    required String filePath,
    required int fileSize,
  }) => remoteDataSource.createAttachmentMetadata(
    projectId: projectId,
    taskId: taskId,
    contentType: contentType,
    fileName: fileName,
    filePath: filePath,
    fileSize: fileSize,
  );

  @override
  Future<List<TaskLinkEntity>> getLinks({
    required int projectId,
    required int taskId,
  }) => remoteDataSource.getLinks(projectId: projectId, taskId: taskId);

  @override
  Future<void> createLink({
    required int projectId,
    required int taskId,
    required int linkedTaskId,
  }) => remoteDataSource.createLink(
    projectId: projectId,
    taskId: taskId,
    linkedTaskId: linkedTaskId,
  );

  @override
  Future<List<TaskCommentEntity>> getComments({
    required int projectId,
    required int taskId,
  }) => remoteDataSource.getComments(projectId: projectId, taskId: taskId);

  @override
  Future<void> createComment({
    required int projectId,
    required int taskId,
    required String content,
  }) => remoteDataSource.createComment(
    projectId: projectId,
    taskId: taskId,
    content: content,
  );

  @override
  Future<void> updateComment({
    required int projectId,
    required int taskId,
    required int commentId,
    required String content,
  }) => remoteDataSource.updateComment(
    projectId: projectId,
    taskId: taskId,
    commentId: commentId,
    content: content,
  );

  @override
  Future<void> deleteComment({
    required int projectId,
    required int taskId,
    required int commentId,
  }) => remoteDataSource.deleteComment(
    projectId: projectId,
    taskId: taskId,
    commentId: commentId,
  );

  @override
  Future<void> deleteTask({required int projectId, required int taskId}) =>
      remoteDataSource.deleteTask(projectId: projectId, taskId: taskId);

  @override
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
  }) => remoteDataSource.updateTask(
    projectId: projectId,
    taskId: taskId,
    assigneeId: assigneeId,
    columnId: columnId,
    description: description,
    dueDate: dueDate,
    priority: priority,
    ticketType: ticketType,
    title: title,
    sprintId: sprintId,
  );

  @override
  Future<void> deleteAttachment({
    required int projectId,
    required int taskId,
    required int attachmentId,
  }) => remoteDataSource.deleteAttachment(
    projectId: projectId,
    taskId: taskId,
    attachmentId: attachmentId,
  );

  @override
  Future<List<BoardColumnEntity>> reorderBoardColumns({
    required int projectId,
    required List<int> columnIds,
  }) => remoteDataSource.reorderBoardColumns(
    projectId: projectId,
    columnIds: columnIds,
  );

  @override
  Future<BoardColumnEntity> createBoardColumn({
    required int projectId,
    required String name,
    required TaskBoardType boardType,
  }) => remoteDataSource.createBoardColumn(
    projectId: projectId,
    name: name,
    boardType: boardType,
  );

  @override
  Future<void> deleteBoardColumn({
    required int projectId,
    required int columnId,
  }) => remoteDataSource.deleteBoardColumn(
    projectId: projectId,
    columnId: columnId,
  );

  @override
  Future<void> moveTask({
    required int projectId,
    required int taskId,
    required int columnId,
    required int position,
  }) => remoteDataSource.moveTask(
    projectId: projectId,
    taskId: taskId,
    columnId: columnId,
    position: position,
  );

  @override
  Future<void> deleteLink({
    required int projectId,
    required int taskId,
    required int linkId,
  }) => remoteDataSource.deleteLink(
    projectId: projectId,
    taskId: taskId,
    linkId: linkId,
  );

  @override
  Future<List<SprintEntity>> getSprints(int projectId) =>
      remoteDataSource.getSprints(projectId);

  @override
  Future<SprintEntity> createSprint({
    required int projectId,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required String goal,
    required String status,
  }) => remoteDataSource.createSprint(
    projectId: projectId,
    name: name,
    startDate: startDate,
    endDate: endDate,
    goal: goal,
    status: status,
  );

  @override
  Future<SprintEntity> updateSprint({
    required int projectId,
    required int sprintId,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    String? goal,
    String? status,
  }) => remoteDataSource.updateSprint(
    projectId: projectId,
    sprintId: sprintId,
    name: name,
    startDate: startDate,
    endDate: endDate,
    goal: goal,
    status: status,
  );

  @override
  Future<void> deleteSprint({required int projectId, required int sprintId}) =>
      remoteDataSource.deleteSprint(projectId: projectId, sprintId: sprintId);
}
