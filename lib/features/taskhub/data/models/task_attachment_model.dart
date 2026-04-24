import 'package:core/core/network/api_routes.dart';
import 'package:core/features/taskhub/domain/entities/task_attachment_entity.dart';

class TaskAttachmentModel extends TaskAttachmentEntity {
  const TaskAttachmentModel({
    required super.id,
    required super.taskId,
    required super.fileName,
    required super.filePath,
    required super.fileSize,
    required super.contentType,
    super.uploadedByName,
    super.createdAt,
  });

  factory TaskAttachmentModel.fromJson(Map<String, dynamic> json) {
    final uploadedBy = json['uploadedBy'] as Map<String, dynamic>?;
    final uploadedByName = uploadedBy == null
        ? null
        : '${(uploadedBy['firstName'] ?? '').toString()} ${(uploadedBy['lastName'] ?? '').toString()}'
            .trim();

    return TaskAttachmentModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      taskId: (json['taskId'] as num?)?.toInt() ?? 0,
      fileName: (json['fileName'] ?? '').toString(),
      filePath: (json['filePath'] ?? '').toString().startsWith('http')
          ? (json['filePath'] ?? '').toString()
          : '${ApiRoutes.base}${(json['filePath'] ?? '').toString()}',
      fileSize: (json['fileSize'] as num?)?.toInt() ?? 0,
      contentType: (json['contentType'] ?? '').toString(),
      uploadedByName: uploadedByName?.isEmpty == true ? null : uploadedByName,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}

