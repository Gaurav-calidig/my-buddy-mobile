import 'package:equatable/equatable.dart';

class TaskLinkEntity extends Equatable {
  final int id;
  final int parentTaskId;
  final int childTaskId;
  final String linkedTaskDisplayId;
  final String linkedTaskTitle;

  const TaskLinkEntity({
    required this.id,
    required this.parentTaskId,
    required this.childTaskId,
    required this.linkedTaskDisplayId,
    required this.linkedTaskTitle,
  });

  @override
  List<Object?> get props => [
        id,
        parentTaskId,
        childTaskId,
        linkedTaskDisplayId,
        linkedTaskTitle,
      ];
}

