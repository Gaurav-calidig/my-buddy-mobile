import 'package:core/core/network/api_routes.dart';
import 'package:core/core/network/api_service.dart';
import 'package:core/features/taskhub/data/models/board_column_model.dart';
import 'package:core/features/taskhub/data/models/task_assignee_model.dart';
import 'package:core/features/taskhub/data/models/task_attachment_model.dart';
import 'package:core/features/taskhub/data/models/task_comment_model.dart';
import 'package:core/features/taskhub/data/models/task_link_model.dart';
import 'package:core/features/taskhub/data/models/sprint_model.dart';
import 'package:core/features/taskhub/data/models/task_model.dart';
import 'package:core/features/taskhub/domain/enums/task_board_type.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

abstract class TaskHubRemoteDataSource {
  Future<List<TaskModel>> getTasks({
    required int projectId,
    required TaskBoardType boardType,
  });

  Future<List<BoardColumnModel>> getBoardColumns({
    required int projectId,
    required TaskBoardType boardType,
  });

  Future<List<TaskAssigneeModel>> getProjectAssignees({required int projectId});

  Future<TaskModel> createTask({
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
  });

  Future<List<TaskAttachmentModel>> getAttachments({
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

  Future<List<TaskLinkModel>> getLinks({
    required int projectId,
    required int taskId,
  });

  Future<void> createLink({
    required int projectId,
    required int taskId,
    required int linkedTaskId,
  });

  Future<List<TaskCommentModel>> getComments({
    required int projectId,
    required int taskId,
  });

  Future<void> createComment({
    required int projectId,
    required int taskId,
    required String content,
  });

  Future<void> deleteTask({required int projectId, required int taskId});

  Future<TaskModel> updateTask({
    required int projectId,
    required int taskId,
    String? assigneeId,
    int? columnId,
    String? description,
    String? dueDate,
    String? priority,
    String? ticketType,
    String? title,
  });

  Future<void> deleteAttachment({
    required int projectId,
    required int taskId,
    required int attachmentId,
  });

  Future<List<BoardColumnModel>> reorderBoardColumns({
    required int projectId,
    required List<int> columnIds,
  });

  Future<BoardColumnModel> createBoardColumn({
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

  Future<List<SprintModel>> getSprints(int projectId);
  
  Future<SprintModel> createSprint({
    required int projectId,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required String goal,
    required String status,
  });

  Future<SprintModel> updateSprint({
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

class TaskHubRemoteDataSourceImpl implements TaskHubRemoteDataSource {
  TaskHubRemoteDataSourceImpl({required this.apiService, required this.logger});

  final ApiService apiService;
  final Logger logger;
  final Dio _rawDio = Dio();

  void _configureRawDioOnce() {
    final adapter = _rawDio.httpClientAdapter;
    if (adapter is IOHttpClientAdapter) {
      // Keep defaults; just ensure we don't reject non-200 by default later.
    }
  }

  @override
  Future<List<TaskModel>> getTasks({
    required int projectId,
    required TaskBoardType boardType,
  }) async {
    try {
      final response = await apiService.get(
        ApiRoutes.projectTasks(projectId),
        query: {'boardType': boardType.apiValue},
      );

      if (response.data != null && response.data is List) {
        final List<dynamic> data = response.data;
        return data
            .whereType<Map>()
            .map((e) => TaskModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(growable: false);
      }

      throw Exception('Failed to parse tasks');
    } catch (e) {
      logger.e('Error fetching tasks', error: e);
      rethrow;
    }
  }

  @override
  Future<List<BoardColumnModel>> getBoardColumns({
    required int projectId,
    required TaskBoardType boardType,
  }) async {
    try {
      final response = await apiService.get(
        ApiRoutes.projectBoardColumns(projectId),
        query: {'boardType': boardType.apiValue},
      );

      if (response.data != null && response.data is List) {
        final List<dynamic> data = response.data;
        return data
            .whereType<Map>()
            .map((e) => BoardColumnModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(growable: false);
      }

      throw Exception('Failed to parse board columns');
    } catch (e) {
      logger.e('Error fetching board columns', error: e);
      rethrow;
    }
  }

  @override
  Future<List<TaskAssigneeModel>> getProjectAssignees({
    required int projectId,
  }) async {
    try {
      final response = await apiService.get(
        ApiRoutes.projectMembers(projectId),
      );
      if (response.data != null && response.data is List) {
        final List<dynamic> data = response.data;
        return data
            .whereType<Map>()
            .map(
              (e) => TaskAssigneeModel.fromProjectMemberJson(
                Map<String, dynamic>.from(e),
              ),
            )
            .where((a) => a.id.isNotEmpty)
            .toList(growable: false);
      }
      throw Exception('Failed to parse project members');
    } catch (e) {
      logger.e('Error fetching project members for assignees', error: e);
      rethrow;
    }
  }

  @override
  Future<TaskModel> createTask({
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
  }) async {
    try {
      final payload = <String, dynamic>{
        'title': title,
        'description': descriptionHtml,
        'assigneeId': assigneeId,
        'boardType': boardType.apiValue,
        'columnId': columnId,
        'position': position,
        'priority': priority,
        'ticketType': ticketType,
        if (dueDateIso != null && dueDateIso.trim().isNotEmpty)
          'dueDate': dueDateIso,
      };

      final response = await apiService.post(
        ApiRoutes.projectTasks(projectId),
        payload,
      );

      if (response.data != null && response.data is Map) {
        return TaskModel.fromJson(Map<String, dynamic>.from(response.data));
      }

      // Some backends may not return the created entity. If so, we rethrow so the UI can reload.
      throw Exception('Create task failed: unexpected response');
    } catch (e) {
      logger.e('Error creating task', error: e);
      rethrow;
    }
  }

  @override
  Future<List<TaskAttachmentModel>> getAttachments({
    required int projectId,
    required int taskId,
  }) async {
    try {
      final response = await apiService.get(
        ApiRoutes.taskAttachments(projectId, taskId),
      );
      if (response.data != null && response.data is List) {
        final List<dynamic> data = response.data;
        return data
            .whereType<Map>()
            .map(
              (e) => TaskAttachmentModel.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList(growable: false);
      }
      throw Exception('Failed to parse attachments');
    } catch (e) {
      logger.e('Error fetching attachments', error: e);
      rethrow;
    }
  }

  @override
  Future<Map<String, String>> createAttachmentUploadUrl({
    required int projectId,
    required int taskId,
    required String contentType,
    required String fileName,
    required int fileSize,
  }) async {
    try {
      final response = await apiService.post(
        ApiRoutes.taskAttachmentUploadUrl(projectId, taskId),
        {
          'contentType': contentType,
          'fileName': fileName,
          'fileSize': fileSize,
        },
      );

      if (response.data != null && response.data is Map) {
        final map = Map<String, dynamic>.from(response.data);
        return {
          'uploadURL': (map['uploadURL'] ?? '').toString(),
          'objectPath': (map['objectPath'] ?? '').toString(),
        };
      }

      throw Exception('Failed to get upload URL');
    } catch (e) {
      logger.e('Error creating attachment upload URL', error: e);
      rethrow;
    }
  }

  @override
  Future<void> uploadToPresignedUrl({
    required String uploadUrl,
    required List<int> bytes,
    required String contentType,
  }) async {
    try {
      _configureRawDioOnce();
      final body = Uint8List.fromList(bytes);
      await _rawDio.put(
        uploadUrl,
        data: body,
        options: Options(
          headers: {'Content-Type': contentType, 'Content-Length': body.length},
          responseType: ResponseType.plain,
          validateStatus: (status) =>
              status != null && status >= 200 && status < 300,
        ),
      );
    } catch (e) {
      logger.e('Error uploading to presigned URL', error: e);
      rethrow;
    }
  }

  @override
  Future<void> createAttachmentMetadata({
    required int projectId,
    required int taskId,
    required String contentType,
    required String fileName,
    required String filePath,
    required int fileSize,
  }) async {
    try {
      await apiService.post(ApiRoutes.taskAttachments(projectId, taskId), {
        'contentType': contentType,
        'fileName': fileName,
        'filePath': filePath,
        'fileSize': fileSize,
      });
    } catch (e) {
      logger.e('Error creating attachment metadata', error: e);
      rethrow;
    }
  }

  @override
  Future<List<TaskLinkModel>> getLinks({
    required int projectId,
    required int taskId,
  }) async {
    try {
      final response = await apiService.get(
        ApiRoutes.taskLinks(projectId, taskId),
      );
      if (response.data != null && response.data is List) {
        final List<dynamic> data = response.data;
        return data
            .whereType<Map>()
            .map((e) => TaskLinkModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(growable: false);
      }
      throw Exception('Failed to parse task links');
    } catch (e) {
      logger.e('Error fetching task links', error: e);
      rethrow;
    }
  }

  @override
  Future<void> createLink({
    required int projectId,
    required int taskId,
    required int linkedTaskId,
  }) async {
    try {
      await apiService.post(ApiRoutes.taskLinks(projectId, taskId), {
        'linkedTaskId': linkedTaskId,
      });
    } catch (e) {
      logger.e('Error linking task', error: e);
      rethrow;
    }
  }

  @override
  Future<List<TaskCommentModel>> getComments({
    required int projectId,
    required int taskId,
  }) async {
    try {
      final response = await apiService.get(
        ApiRoutes.taskComments(projectId, taskId),
      );
      if (response.data != null && response.data is List) {
        final List<dynamic> data = response.data;
        return data
            .whereType<Map>()
            .map((e) => TaskCommentModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(growable: false);
      }
      throw Exception('Failed to parse comments');
    } catch (e) {
      logger.e('Error fetching comments', error: e);
      rethrow;
    }
  }

  @override
  Future<void> createComment({
    required int projectId,
    required int taskId,
    required String content,
  }) async {
    try {
      await apiService.post(ApiRoutes.taskComments(projectId, taskId), {
        'content': content,
      });
    } catch (e) {
      logger.e('Error posting comment', error: e);
      rethrow;
    }
  }

  @override
  Future<void> deleteTask({required int projectId, required int taskId}) async {
    try {
      await apiService.delete(ApiRoutes.projectTask(projectId, taskId));
    } catch (e) {
      logger.e('Error deleting task', error: e);
      rethrow;
    }
  }

  @override
  Future<TaskModel> updateTask({
    required int projectId,
    required int taskId,
    String? assigneeId,
    int? columnId,
    String? description,
    String? dueDate,
    String? priority,
    String? ticketType,
    String? title,
  }) async {
    try {
      final payload = <String, dynamic>{
        if (assigneeId != null) 'assigneeId': assigneeId,
        if (columnId != null) 'columnId': columnId,
        if (description != null) 'description': description,
        'dueDate': dueDate, // Always send if provided, user said null is possible
        if (priority != null) 'priority': priority,
        if (ticketType != null) 'ticketType': ticketType,
        if (title != null) 'title': title,
      };

      final response = await apiService.patch(
        ApiRoutes.projectTask(projectId, taskId),
        payload,
      );

      if (response.data != null && response.data is Map) {
        return TaskModel.fromJson(Map<String, dynamic>.from(response.data));
      }

      throw Exception('Update task failed: unexpected response');
    } catch (e) {
      logger.e('Error updating task', error: e);
      rethrow;
    }
  }

  @override
  Future<void> deleteAttachment({
    required int projectId,
    required int taskId,
    required int attachmentId,
  }) async {
    try {
      await apiService.delete(
        '${ApiRoutes.taskAttachments(projectId, taskId)}/$attachmentId',
      );
    } catch (e) {
      logger.e('Error deleting attachment', error: e);
      rethrow;
    }
  }

  @override
  Future<List<BoardColumnModel>> reorderBoardColumns({
    required int projectId,
    required List<int> columnIds,
  }) async {
    try {
      final response = await apiService.patch(
        ApiRoutes.reorderBoardColumns(projectId),
        {'columnIds': columnIds},
      );

      if (response.data != null && response.data is List) {
        final List<dynamic> data = response.data;
        return data
            .whereType<Map>()
            .map((e) => BoardColumnModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(growable: false);
      }

      throw Exception('Reorder columns failed');
    } catch (e) {
      logger.e('Error reordering columns', error: e);
      rethrow;
    }
  }

  @override
  Future<BoardColumnModel> createBoardColumn({
    required int projectId,
    required String name,
    required TaskBoardType boardType,
  }) async {
    try {
      final response = await apiService.post(
        ApiRoutes.projectBoardColumns(projectId),
        {
          'name': name,
          'boardType': boardType.apiValue,
        },
      );

      if (response.data != null && response.data is Map) {
        return BoardColumnModel.fromJson(Map<String, dynamic>.from(response.data));
      }

      throw Exception('Create board column failed');
    } catch (e) {
      logger.e('Error creating board column', error: e);
      rethrow;
    }
  }

  @override
  Future<void> deleteBoardColumn({
    required int projectId,
    required int columnId,
  }) async {
    try {
      await apiService.delete(ApiRoutes.projectBoardColumn(projectId, columnId));
    } catch (e) {
      logger.e('Error deleting board column', error: e);
      rethrow;
    }
  }

  @override
  Future<void> moveTask({
    required int projectId,
    required int taskId,
    required int columnId,
    required int position,
  }) async {
    try {
      await apiService.patch(
        ApiRoutes.moveTask(projectId, taskId),
        {
          'columnId': columnId,
          'position': position,
        },
      );
    } catch (e) {
      logger.e('Error moving task', error: e);
      rethrow;
    }
  }

  @override
  Future<void> deleteLink({
    required int projectId,
    required int taskId,
    required int linkId,
  }) async {
    try {
      await apiService.delete(ApiRoutes.taskLinkDetail(projectId, taskId, linkId));
    } catch (e) {
      logger.e('Error deleting task link', error: e);
      rethrow;
    }
  }

  @override
  Future<List<SprintModel>> getSprints(int projectId) async {
    try {
      final response = await apiService.get(ApiRoutes.projectSprints(projectId));
      final data = response.data as List;
      return data.map((json) => SprintModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      logger.e('Error fetching sprints', error: e);
      rethrow;
    }
  }

  @override
  Future<SprintModel> createSprint({
    required int projectId,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required String goal,
    required String status,
  }) async {
    try {
      final response = await apiService.post(
        ApiRoutes.projectSprints(projectId),
        {
          'name': name,
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
          'goal': goal,
          'status': status,
        },
      );
      return SprintModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      logger.e('Error creating sprint', error: e);
      rethrow;
    }
  }

  @override
  Future<SprintModel> updateSprint({
    required int projectId,
    required int sprintId,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    String? goal,
    String? status,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (startDate != null) data['startDate'] = startDate.toIso8601String().split('T')[0];
      if (endDate != null) data['endDate'] = endDate.toIso8601String().split('T')[0];
      if (goal != null) data['goal'] = goal;
      if (status != null) data['status'] = status;

      final response = await apiService.patch(
        ApiRoutes.projectSprintDetail(projectId, sprintId),
        data,
      );
      return SprintModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      logger.e('Error updating sprint', error: e);
      rethrow;
    }
  }

  @override
  Future<void> deleteSprint({
    required int projectId,
    required int sprintId,
  }) async {
    try {
      await apiService.delete(ApiRoutes.projectSprintDetail(projectId, sprintId));
    } catch (e) {
      logger.e('Error deleting sprint', error: e);
      rethrow;
    }
  }
}
