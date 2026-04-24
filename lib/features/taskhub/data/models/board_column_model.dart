import 'package:core/features/taskhub/domain/entities/board_column_entity.dart';
import 'package:core/features/taskhub/domain/enums/task_board_type.dart';

class BoardColumnModel extends BoardColumnEntity {
  const BoardColumnModel({
    required super.id,
    required super.projectId,
    required super.name,
    required super.position,
    required super.boardType,
  });

  factory BoardColumnModel.fromJson(Map<String, dynamic> json) {
    final raw = (json['boardType'] ?? '').toString().toLowerCase();
    final boardType = raw == 'sprint' ? TaskBoardType.sprint : TaskBoardType.kanban;
    return BoardColumnModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      projectId: (json['projectId'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      position: (json['position'] as num?)?.toInt() ?? 0,
      boardType: boardType,
    );
  }
}

