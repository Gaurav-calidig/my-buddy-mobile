import 'package:equatable/equatable.dart';
import 'package:core/features/taskhub/domain/enums/task_board_type.dart';

class BoardColumnEntity extends Equatable {
  final int id;
  final int projectId;
  final String name;
  final int position;
  final TaskBoardType boardType;

  const BoardColumnEntity({
    required this.id,
    required this.projectId,
    required this.name,
    required this.position,
    required this.boardType,
  });

  @override
  List<Object?> get props => [id, projectId, name, position, boardType];
}

