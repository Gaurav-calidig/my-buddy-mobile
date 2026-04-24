import 'package:equatable/equatable.dart';

class TaskAttachmentEntity extends Equatable {
  final int id;
  final int taskId;
  final String fileName;
  final String filePath;
  final int fileSize;
  final String contentType;
  final String? uploadedByName;
  final DateTime? createdAt;

  const TaskAttachmentEntity({
    required this.id,
    required this.taskId,
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.contentType,
    this.uploadedByName,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        taskId,
        fileName,
        filePath,
        fileSize,
        contentType,
        uploadedByName,
        createdAt,
      ];
}

