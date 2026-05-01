import 'dart:async';
import 'dart:math';

import 'package:core/core/theme/app_colors.dart';
import 'package:core/core/dependency_injection/injection_container.dart';
import 'package:core/features/projects/domain/entities/project_entity.dart';
import 'package:core/features/taskhub/domain/entities/board_column_entity.dart';
import 'package:core/features/taskhub/domain/entities/sprint_entity.dart';
import 'package:core/features/taskhub/domain/entities/task_entity.dart';
import 'package:core/features/taskhub/domain/enums/task_board_type.dart';
import 'package:core/features/taskhub/presentation/bloc/task_hub_cubit.dart';
import 'package:core/features/taskhub/presentation/bloc/task_hub_state.dart';
import 'package:core/features/taskhub/presentation/widgets/task_status_column.dart';
import 'package:core/features/taskhub/presentation/widgets/task_hub_task_dialog.dart';
import 'package:core/features/taskhub/presentation/widgets/manage_states_dialog.dart';
import 'package:core/features/taskhub/presentation/widgets/manage_sprints_dialog.dart';
import 'package:core/features/taskhub/presentation/widgets/export_tasks_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:core/core/utils/date_time_utils.dart';
import 'package:core/core/theme/date_format_cubit.dart';

class TaskHubScreen extends StatefulWidget {
  const TaskHubScreen({super.key, required this.project});

  final ProjectEntity project;

  @override
  State<TaskHubScreen> createState() => _TaskHubScreenState();
}

class _TaskHubScreenState extends State<TaskHubScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _horizontalController = ScrollController();
  final GlobalKey _boardKey = GlobalKey();
  final ValueNotifier<Offset?> _dragGlobalPosition = ValueNotifier(null);
  String _taskFilter = 'All Tasks';
  Timer? _scrollTimer;

  void _handleDragPosition(Offset? globalPosition) {
    _dragGlobalPosition.value = globalPosition;
    if (globalPosition != null) {
      _startScrollTimer();
    } else {
      _stopScrollTimer();
    }
  }

  void _startScrollTimer() {
    if (_scrollTimer != null) return;
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      final pos = _dragGlobalPosition.value;
      if (pos != null) {
        _maybeAutoScrollHorizontal(pos);
      } else {
        _stopScrollTimer();
      }
    });
  }

  void _stopScrollTimer() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
  }

  void _maybeAutoScrollHorizontal(Offset globalPosition) {
    if (!_horizontalController.hasClients) return;
    final ctx = _boardKey.currentContext;
    if (ctx == null) return;
    final renderObject = ctx.findRenderObject();
    if (renderObject is! RenderBox) return;

    final local = renderObject.globalToLocal(globalPosition);
    final width = renderObject.size.width;

    const edge = 80.0;
    const maxStep = 14.0;

    double delta = 0;
    if (local.dx < edge) {
      final strength = (edge - local.dx).clamp(0, edge) / edge;
      delta = -maxStep * pow(strength, 2);
    } else if (local.dx > width - edge) {
      final strength = (local.dx - (width - edge)).clamp(0, edge) / edge;
      delta = maxStep * pow(strength, 2);
    }

    if (delta == 0) return;

    final next = (_horizontalController.offset + delta).clamp(
      _horizontalController.position.minScrollExtent,
      _horizontalController.position.maxScrollExtent,
    );
    _horizontalController.jumpTo(next);
  }

  @override
  void dispose() {
    _stopScrollTimer();
    _searchController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider(
      create: (_) => TaskHubCubit(
        project: widget.project,
        getBoardColumnsUseCase: sl(),
        getTasksUseCase: sl(),
        getProjectAssigneesUseCase: sl(),
        updateTaskUseCase: sl(),
        reorderBoardColumnsUseCase: sl(),
        createBoardColumnUseCase: sl(),
        deleteBoardColumnUseCase: sl(),
        moveTaskUseCase: sl(),
        getSprintsUseCase: sl(),
      )..load(boardType: TaskBoardType.kanban),
      child: Builder(
        builder: (context) {
          return BlocBuilder<TaskHubCubit, TaskHubState>(
            builder: (context, state) {
              return Scaffold(
                backgroundColor: isDark ? AppColors.kcDarkPage : AppColors.kcLightPage,
                body: Container(
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.kcDarkGradientTop,
                              AppColors.kcDarkGradientBottom,
                            ],
                          )
                        : LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.kcLightPage,
                              AppColors.kcLightPage.withValues(alpha: 0.95),
                            ],
                          ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        _HeaderBar(
                          projectName: widget.project.name,
                          searchController: _searchController,
                          filterValue: _taskFilter,
                          boardType: state.boardType,
                          sprints: state.sprints,
                          selectedSprintId: state.selectedSprintId,
                          onBack: () => Navigator.of(context).pop(),
                          onSearchChanged: (_) => setState(() {}),
                          onFilterChanged: (v) =>
                              setState(() => _taskFilter = v),
                          onBoardTypeChanged: (t) =>
                              context.read<TaskHubCubit>().load(boardType: t),
                          onSprintChanged: (id) => context
                              .read<TaskHubCubit>()
                              .setSelectedSprintId(id),
                          onExport: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => ExportTasksDialog(
                                columns: state.columns,
                                tasksByColumnId: state.tasksByColumnId,
                                project: widget.project,
                                sprints: state.sprints,
                                assigneeById: state.assigneeById,
                              ),
                            );
                          },
                          onSettings: () => _onSettings(context),
                          onManageSprints: () => _onManageSprints(context),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final isMobile = constraints.maxWidth < 720;
                              final columnWidth = isMobile
                                  ? max(
                                      260.0,
                                      min(320.0, constraints.maxWidth - 56),
                                    )
                                  : 360.0;

                              if (state.status == TaskHubLoadStatus.loading ||
                                  state.status == TaskHubLoadStatus.initial) {
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: isDark ? AppColors.kcDarkPrimary : AppColors.kcPrimaryColor,
                                  ),
                                );
                              }

                              if (state.status == TaskHubLoadStatus.error) {
                                return _ErrorState(
                                  message:
                                      state.errorMessage ??
                                      'Failed to load tasks.',
                                  onRetry: () => context
                                      .read<TaskHubCubit>()
                                      .load(boardType: state.boardType),
                                );
                              }

                              final columns = state.columns
                                  .map(
                                    (col) => _buildStatusColumn(
                                      context: context,
                                      column: col,
                                      tasks:
                                          state.tasksByColumnId[col.id] ??
                                          const [],
                                      assigneeById: state.assigneeById,
                                    ),
                                  )
                                  .toList(growable: false);

                              return Scrollbar(
                                thumbVisibility: true,
                                controller: _horizontalController,
                                child: ValueListenableBuilder<Offset?>(
                                  valueListenable: _dragGlobalPosition,
                                  builder: (context, dragPos, child) {
                                    if (dragPos != null) {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback(
                                            (_) => _maybeAutoScrollHorizontal(
                                              dragPos,
                                            ),
                                          );
                                    }
                                    return child!;
                                  },
                                  child: ListView.separated(
                                    key: _boardKey,
                                    controller: _horizontalController,
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    itemCount: columns.length + 1,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(width: 16),
                                    itemBuilder: (context, index) {
                                      if (index < columns.length) {
                                        return SizedBox(
                                          width: columnWidth,
                                          child: columns[index],
                                        );
                                      }
                                      return _AddColumnButton(
                                        width: columnWidth,
                                        onAdd: () => _onAddColumn(context),
                                        onManage: () =>
                                            _onManageColumns(context),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusColumn({
    required BuildContext context,
    required BoardColumnEntity column,
    required List<TaskEntity> tasks,
    required Map<String, String> assigneeById,
  }) {
    final filtered = tasks.where((t) {
      final q = _searchController.text.trim().toLowerCase();
      if (q.isNotEmpty) {
        if (!t.title.toLowerCase().contains(q) &&
            !t.taskNumber.toString().contains(q)) {
          return false;
        }
      }
      if (_taskFilter == 'Assigned to me') {
        // Mocking user id for demonstration
        const myId = 'd8230625-f192-43ba-8e20-0111074a34f8';
        if (t.assigneeId != myId) return false;
      }
      return true;
    }).toList();

    return TaskStatusColumn(
      column: column,
      tasks: filtered,
      onTaskTap: (task) => _onTaskTap(context, task),
      onAddTask: () => _onAddTask(context, column),
      onMoveTask: (taskId, toColumnId, toPosition) {
        context.read<TaskHubCubit>().moveTask(
          taskId: taskId,
          columnId: toColumnId,
          position: toPosition,
        );
      },
      onDragPositionChanged: _handleDragPosition,
      projectPrefix: widget.project.name,
      assigneeById: assigneeById,
    );
  }

  void _onTaskTap(BuildContext context, TaskEntity task) async {
    final cubit = context.read<TaskHubCubit>();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: cubit,
        child: TaskHubTaskDialog(
          task: task,
          project: widget.project,
          boardType: cubit.state.boardType,
          columns: cubit.state.columns,
          defaultColumnId: task.columnId,
          allTasks: cubit.state.tasksByColumnId.values.expand((x) => x).toList(),
          sprints: cubit.state.sprints,
          initialSprintId: task.sprintId,
        ),
      ),
    );
    if (result == true) {
      cubit.load(boardType: cubit.state.boardType);
    }
  }

  void _onAddTask(BuildContext context, BoardColumnEntity column) async {
    final cubit = context.read<TaskHubCubit>();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: cubit,
        child: TaskHubTaskDialog(
          project: widget.project,
          boardType: cubit.state.boardType,
          columns: cubit.state.columns,
          defaultColumnId: column.id,
          allTasks: cubit.state.tasksByColumnId.values.expand((x) => x).toList(),
          sprints: cubit.state.sprints,
          initialSprintId: cubit.state.selectedSprintId == -1
              ? null
              : cubit.state.selectedSprintId,
        ),
      ),
    );
    if (result == true) {
      cubit.load(boardType: cubit.state.boardType);
    }
  }

  void _onAddColumn(BuildContext context) async {
    final nameController = TextEditingController();
    final cubit = context.read<TaskHubCubit>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.kcDarkCard : AppColors.kcLightCard,
        title: Text(
          'Add Column',
          style: TextStyle(color: isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle),
        ),
        content: TextField(
          controller: nameController,
          style: TextStyle(color: isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle),
          decoration: InputDecoration(
            hintText: 'Column Name',
            hintStyle: TextStyle(color: isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextMuted),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: isDark ? AppColors.kcDarkBorderSoft : AppColors.kcLightBorder),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: isDark ? AppColors.kcDarkPrimary : AppColors.kcPrimaryColor),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              foregroundColor: isDark ? AppColors.kcDarkTextSecondary : AppColors.kcLightTextSecondary,
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.kcDarkPrimary : AppColors.kcPrimaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.trim().isNotEmpty) {
      cubit.createColumn(nameController.text.trim());
    }
  }

  void _onManageColumns(BuildContext context) async {
    final cubit = context.read<TaskHubCubit>();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: cubit,
        child: const ManageStatesDialog(),
      ),
    );
    if (result == true) {
      cubit.load(boardType: cubit.state.boardType);
    }
  }

  void _onManageSprints(BuildContext context) async {
    final cubit = context.read<TaskHubCubit>();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: cubit,
        child: ManageSprintsDialog(projectId: widget.project.id),
      ),
    );
    if (result == true) {
      cubit.load(boardType: TaskBoardType.sprint);
    }
  }

  void _onSettings(BuildContext context) {}
}

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({
    required this.projectName,
    required this.searchController,
    required this.filterValue,
    required this.boardType,
    required this.sprints,
    required this.selectedSprintId,
    required this.onBack,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onBoardTypeChanged,
    required this.onSprintChanged,
    required this.onExport,
    required this.onSettings,
    required this.onManageSprints,
  });

  final String projectName;
  final TextEditingController searchController;
  final String filterValue;
  final TaskBoardType boardType;
  final List<SprintEntity> sprints;
  final int? selectedSprintId;
  final VoidCallback onBack;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<TaskBoardType> onBoardTypeChanged;
  final ValueChanged<int?> onSprintChanged;
  final VoidCallback onExport;
  final VoidCallback onSettings;
  final VoidCallback onManageSprints;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 720;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleColor = isDark ? Colors.white : AppColors.kcLightTitle;
    final iconColor = isDark ? Colors.white : AppColors.kcLightTitle;
    final inputBg = isDark ? AppColors.kcDarkInput : AppColors.kcLightInput;
    final hintColor = isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextMuted;
    final borderColor = isDark ? AppColors.kcDarkBorderSoft : AppColors.kcLightBorder;

    final titleRow = Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: iconColor),
          onPressed: onBack,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            projectName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: titleColor,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              fontFamily: 'Outfit',
            ),
          ),
        ),
        _IconSquareButton(
          icon: Icons.more_vert_rounded,
          onPressed: onSettings,
        ),
      ],
    );

    final search = Container(
      height: 42,
      decoration: BoxDecoration(
        color: inputBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor.withValues(alpha: 0.5)),
      ),
      child: TextField(
        controller: searchController,
        onChanged: onSearchChanged,
        style: TextStyle(color: titleColor, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search tasks...',
          hintStyle: TextStyle(color: hintColor, fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, size: 18, color: hintColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );

    final selectedSprint = selectedSprintId != null && selectedSprintId! > 0
        ? sprints.firstWhere((s) => s.id == selectedSprintId)
        : null;

    Widget controls;
    if (isMobile) {
      controls = Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _DarkDropdown(
                  value: filterValue,
                  items: const ['All Tasks', 'Assigned to me'],
                  onChanged: onFilterChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DarkButton(
                  label: 'Export XLSX',
                  icon: Icons.download,
                  onPressed: onExport,
                ),
              ),
            ],
          ),
          if (boardType == TaskBoardType.sprint) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SprintDropdown(
                    selectedId: selectedSprintId,
                    sprints: sprints,
                    onChanged: onSprintChanged,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DarkButton(
                    label: 'Manage Sprints',
                    icon: Icons.settings,
                    onPressed: onManageSprints,
                  ),
                ),
              ],
            ),
            if (selectedSprint != null) ...[
              const SizedBox(height: 12),
              _SelectedSprintDetails(sprint: selectedSprint),
            ],
          ],
          const SizedBox(height: 12),
          _BoardTypeDropdown(
            value: boardType,
            onChanged: onBoardTypeChanged,
          ),
        ],
      );
    } else {
      controls = Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _DarkDropdown(
            value: filterValue,
            items: const ['All Tasks', 'Assigned to me'],
            onChanged: onFilterChanged,
          ),
          _DarkButton(
            label: 'Export XLSX',
            icon: Icons.download,
            onPressed: onExport,
          ),
          if (boardType == TaskBoardType.sprint)
            _SprintControls(
              selectedId: selectedSprintId,
              sprints: sprints,
              selectedSprint: selectedSprint,
              onSprintChanged: onSprintChanged,
              onManageSprints: onManageSprints,
            ),
          _BoardTypeDropdown(
            value: boardType,
            onChanged: onBoardTypeChanged,
          ),
        ],
      );
    }

    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 12, 8),
        child: Column(
          children: [
            titleRow,
            const SizedBox(height: 12),
            search,
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerLeft, child: controls),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 12, 8),
      child: Row(
        children: [
          Expanded(child: titleRow),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: search),
          const SizedBox(width: 16),
          controls,
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: isDark ? Colors.red.shade300 : AppColors.kcErrorColor),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.kcDarkTextSecondary : AppColors.kcLightTextSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kcPrimaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SprintDropdown extends StatelessWidget {
  const _SprintDropdown({
    required this.selectedId,
    required this.sprints,
    required this.onChanged,
  });

  final int? selectedId;
  final List<SprintEntity> sprints;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.kcDarkBorderSoft : AppColors.kcLightBorder;

    final bool hasSelectedSprint =
        selectedId == null ||
        selectedId == -1 ||
        sprints.any((s) => s.id == selectedId);
    final int? effectiveSelectedId = hasSelectedSprint ? selectedId : null;

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.kcDarkInputAlt : AppColors.kcLightInput,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor.withValues(alpha: 0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: effectiveSelectedId,
          dropdownColor: isDark ? AppColors.kcDarkCard : AppColors.kcLightCard,
          iconEnabledColor: isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextMuted,
          style: TextStyle(
            color: isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('All Sprints'),
            ),
            const DropdownMenuItem<int?>(value: -1, child: Text('Backlog')),
            ...sprints.map(
              (s) => DropdownMenuItem<int?>(value: s.id, child: Text(s.name)),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _SelectedSprintDetails extends StatelessWidget {
  const _SelectedSprintDetails({required this.sprint});

  final SprintEntity sprint;

  String get _status {
    final raw = sprint.status == 'planning' ? 'planned' : sprint.status;
    if (raw != 'planned' && raw != 'active' && raw != 'completed') {
      return 'planned';
    }
    return raw;
  }

  String _getDateRange(String format) {
    final start = DateTimeUtils.formatDate(sprint.startDate, format);
    final end = DateTimeUtils.formatDate(sprint.endDate, format);
    return '$start - $end';
  }

  (Color bg, Color fg, Color border) get _statusStyle {
    switch (_status) {
      case 'active':
        return (Colors.green.shade600, Colors.white, Colors.green.shade600);
      case 'completed':
        return (Colors.blue.shade600, Colors.white, Colors.blue.shade600);
      default:
        return (Colors.orange.shade600, Colors.white, Colors.orange.shade600);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final style = _statusStyle;
    final titleColor = isDark ? Colors.white : AppColors.kcLightTitle;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.kcDarkCard : AppColors.kcLightCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.kcDarkBorderSoft : AppColors.kcLightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: style.$1.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: style.$3.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _status.toUpperCase(),
                  style: TextStyle(
                    color: style.$1,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  sprint.name,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          BlocBuilder<DateFormatCubit, String>(
            builder: (context, format) {
              return Text(
                _getDateRange(format),
                style: TextStyle(
                  color: isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SprintControls extends StatelessWidget {
  const _SprintControls({
    required this.selectedId,
    required this.sprints,
    required this.selectedSprint,
    required this.onSprintChanged,
    required this.onManageSprints,
  });

  final int? selectedId;
  final List<SprintEntity> sprints;
  final SprintEntity? selectedSprint;
  final ValueChanged<int?> onSprintChanged;
  final VoidCallback onManageSprints;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SprintDropdown(
          selectedId: selectedId,
          sprints: sprints,
          onChanged: onSprintChanged,
        ),
        const SizedBox(width: 12),
        _DarkButton(
          label: 'Manage Sprints',
          icon: Icons.settings,
          onPressed: onManageSprints,
        ),
        if (selectedSprint != null) ...[
          const SizedBox(width: 12),
          _SelectedSprintDetails(sprint: selectedSprint!),
        ],
      ],
    );
  }
}

class _BoardTypeDropdown extends StatelessWidget {
  const _BoardTypeDropdown({required this.value, required this.onChanged});

  final TaskBoardType value;
  final ValueChanged<TaskBoardType> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.kcDarkBorderSoft : AppColors.kcLightBorder;

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.kcDarkInputAlt : AppColors.kcLightInput,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor.withValues(alpha: 0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TaskBoardType>(
          value: value,
          dropdownColor: isDark ? AppColors.kcDarkCard : AppColors.kcLightCard,
          iconEnabledColor: isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextMuted,
          style: TextStyle(
            color: isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          items: TaskBoardType.values
              .map(
                (e) => DropdownMenuItem<TaskBoardType>(
                  value: e,
                  child: Text(e.name.toUpperCase()),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _DarkDropdown extends StatelessWidget {
  const _DarkDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.kcDarkBorderSoft : AppColors.kcLightBorder;

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.kcDarkInputAlt : AppColors.kcLightInput,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor.withValues(alpha: 0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: isDark ? AppColors.kcDarkCard : AppColors.kcLightCard,
          iconEnabledColor: isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextMuted,
          style: TextStyle(
            color: isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle,
            fontWeight: FontWeight.w600,
          ),
          items: items
              .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
              .toList(growable: false),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _DarkButton extends StatelessWidget {
  const _DarkButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.kcDarkBorderSoft : AppColors.kcLightBorder;

    return SizedBox(
      height: 42,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? AppColors.kcDarkInputAlt : AppColors.kcLightInput,
          foregroundColor: isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: borderColor.withValues(alpha: 0.55),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconSquareButton extends StatelessWidget {
  const _IconSquareButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.kcDarkBorderSoft : AppColors.kcLightBorder;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isDark ? AppColors.kcDarkInputAlt : AppColors.kcLightInput,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor.withValues(alpha: 0.5)),
        ),
        child: Icon(icon, size: 20, color: isDark ? Colors.white : AppColors.kcLightTitle),
      ),
    );
  }
}

class _AddColumnButton extends StatelessWidget {
  const _AddColumnButton({
    required this.width,
    required this.onAdd,
    required this.onManage,
  });

  final double width;
  final VoidCallback onAdd;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.kcDarkBorderSoft : AppColors.kcLightBorder;

    return SizedBox(
      width: width,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.kcDarkCard : AppColors.kcLightCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'ADD COLUMN',
                    style: TextStyle(
                      color: isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onManage,
                  icon: Icon(Icons.settings_rounded, size: 20, color: isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextSecondary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.kcDarkInput.withValues(alpha: 0.3) : AppColors.kcLightInput.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: borderColor.withValues(alpha: 0.5),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.kcPrimaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: AppColors.kcPrimaryColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Add new state',
                      style: TextStyle(
                        color: isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
