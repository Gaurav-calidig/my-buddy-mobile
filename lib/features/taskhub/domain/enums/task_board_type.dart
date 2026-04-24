enum TaskBoardType {
  kanban,
  sprint,
}

extension TaskBoardTypeX on TaskBoardType {
  String get apiValue {
    switch (this) {
      case TaskBoardType.kanban:
        return 'kanban';
      case TaskBoardType.sprint:
        return 'sprint';
    }
  }

  String get label {
    switch (this) {
      case TaskBoardType.kanban:
        return 'Kanban';
      case TaskBoardType.sprint:
        return 'Sprint';
    }
  }
}

