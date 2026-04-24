import 'dart:async';
import 'dart:math';

import 'package:core/core/theme/app_colors.dart';
import 'package:core/core/dependency_injection/injection_container.dart';
import 'package:core/features/projects/domain/entities/project_entity.dart';
import 'package:core/features/taskhub/domain/entities/board_column_entity.dart';
import 'package:core/features/taskhub/domain/entities/task_entity.dart';
import 'package:core/features/taskhub/domain/enums/task_board_type.dart';
import 'package:core/features/taskhub/presentation/bloc/task_hub_cubit.dart';
import 'package:core/features/taskhub/presentation/bloc/task_hub_state.dart';
import 'package:core/features/taskhub/presentation/widgets/task_status_column.dart';
import 'package:core/features/taskhub/presentation/widgets/task_hub_task_dialog.dart';
import 'package:core/features/taskhub/presentation/widgets/manage_states_dialog.dart';
import 'package:core/features/taskhub/presentation/widgets/manage_sprints_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

    const edge = 80.0; // Increased edge sensitivity for smoother start
    const maxStep = 14.0; // Reduced step for smoother, more controlled scroll

    double delta = 0;
    if (local.dx < edge) {
      final strength = (edge - local.dx).clamp(0, edge) / edge;
      delta = -maxStep * pow(strength, 2); // Exponential speed for better feel
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
    _dragGlobalPosition.dispose();
    super.dispose();
  }

  void _onSettings() {
    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: context.read<TaskHubCubit>(),
        child: const ManageStatesDialog(),
      ),
    );
  }

  void _onManageSprints() async {
    await showDialog(
      context: context,
      builder: (ctx) => ManageSprintsDialog(projectId: widget.project.id),
    );
    if (!mounted) return;
    context.read<TaskHubCubit>().load(boardType: context.read<TaskHubCubit>().state.boardType);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          TaskHubCubit(
        project: widget.project,
        getBoardColumnsUseCase: sl(),
        getTasksUseCase: sl(),
        getProjectAssigneesUseCase: sl(),
        updateTaskUseCase: sl(),
        reorderBoardColumnsUseCase: sl(),
        createBoardColumnUseCase: sl(),
        deleteBoardColumnUseCase: sl(),
        moveTaskUseCase: sl(),
      ),
      child: BlocBuilder<TaskHubCubit, TaskHubState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.kcDarkPage,
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.kcDarkGradientTop,
                    AppColors.kcDarkGradientBottom,
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
                      onBack: () => Navigator.of(context).pop(),
                      onSearchChanged: (_) => setState(() {}),
                      onFilterChanged: (v) => setState(() => _taskFilter = v),
                      onBoardTypeChanged: (t) =>
                          context.read<TaskHubCubit>().load(boardType: t),
                      onExport: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Export not implemented yet.'),
                          ),
                        );
                      },
                      onSettings: _onSettings,
                      onManageSprints: _onManageSprints,
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
                              state.status == TaskHubLoadStatus.idle) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.kcDarkPrimary,
                              ),
                            );
                          }

                          if (state.status == TaskHubLoadStatus.error) {
                            return _ErrorState(
                              message:
                                  state.errorMessage ?? 'Failed to load tasks.',
                              onRetry: () => context.read<TaskHubCubit>().load(
                                boardType: state.boardType,
                              ),
                            );
                          }

                          final columns = state.columns
                              .map(
                                (col) => _buildStatusColumn(
                                  context: context,
                                  column: col,
                                  tasks:
                                      state.tasksByColumnId[col.id] ?? const [],
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
                                  WidgetsBinding.instance.addPostFrameCallback(
                                    (_) => _maybeAutoScrollHorizontal(dragPos),
                                  );
                                }
                                return child!;
                              },
                              child: SingleChildScrollView(
                                key: _boardKey,
                                controller: _horizontalController,
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    for (
                                      int i = 0;
                                      i < columns.length;
                                      i++
                                    ) ...[
                                      SizedBox(
                                        width: columnWidth,
                                        child: columns[i],
                                      ),
                                      if (i != columns.length - 1)
                                        const SizedBox(width: 16),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusColumn({
    required BuildContext context,
    required BoardColumnEntity column,
    required List<TaskEntity> tasks,
  }) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? tasks
        : tasks
              .where((t) {
                final ticket =
                    '${(widget.project.prefix.trim().isEmpty ? 'PRJ' : widget.project.prefix.trim())}-${t.taskNumber}';
                return ticket.toLowerCase().contains(query) ||
                    t.title.toLowerCase().contains(query) ||
                    (t.assignee ?? '').toLowerCase().contains(query);
              })
              .toList(growable: false);

    return TaskStatusColumn(
      column: column,
      tasks: filtered,
      projectPrefix: widget.project.prefix.trim().isEmpty
          ? 'PRJ'
          : widget.project.prefix.trim(),
      assigneeById: context.read<TaskHubCubit>().state.assigneeById,
      onDragPositionChanged: _handleDragPosition,
      onAddPressed: () async {
        final cubit = context.read<TaskHubCubit>();
        final allTasks = cubit.state.tasksByColumnId.values.expand((e) => e).toList();
        final created = await showDialog<TaskEntity>(
          context: context,
          builder: (ctx) => TaskHubTaskDialog(
            project: widget.project,
            boardType: cubit.state.boardType,
            columns: cubit.state.columns,
            defaultColumnId: column.id,
            allTasks: allTasks,
          ),
        );
        if (!mounted || created == null) return;
        cubit.load(boardType: cubit.state.boardType);
      },
      onTaskDropped: (task, position) {
        context.read<TaskHubCubit>().moveTask(
          taskId: task.id,
          columnId: column.id,
          position: position,
        );
      },
      onTaskTapped: (task) async {
        final cubit = context.read<TaskHubCubit>();
        final allTasks = cubit.state.tasksByColumnId.values.expand((e) => e).toList();
        final result = await showDialog<dynamic>(
          context: context,
          builder: (ctx) => TaskHubTaskDialog(
            project: widget.project,
            boardType: cubit.state.boardType,
            columns: cubit.state.columns,
            defaultColumnId: column.id,
            allTasks: allTasks,
            task: task,
          ),
        );
        if (!mounted) return;
        if (result != null) {
          context.read<TaskHubCubit>().load(
            boardType: context.read<TaskHubCubit>().state.boardType,
          );
        }
      },
    );
  }
}

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({
    required this.projectName,
    required this.searchController,
    required this.filterValue,
    required this.boardType,
    required this.onBack,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onBoardTypeChanged,
    required this.onExport,
    required this.onSettings,
    required this.onManageSprints,
  });

  final String projectName;
  final TextEditingController searchController;
  final String filterValue;
  final TaskBoardType boardType;
  final VoidCallback onBack;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<TaskBoardType> onBoardTypeChanged;
  final VoidCallback onExport;
  final VoidCallback onSettings;
  final VoidCallback onManageSprints;

  @override
  Widget build(BuildContext context) {
    const border = AppColors.kcDarkBorderSoft;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 720;

        final titleRow = Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.kcDarkTextPrimary,
                size: 18,
              ),
              splashRadius: 18,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                projectName,
                style: const TextStyle(
                  color: AppColors.kcDarkTitle,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Outfit',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _IconSquareButton(
              icon: Icons.settings_outlined,
              onPressed: onSettings,
            ),
          ],
        );

        final search = SizedBox(
          height: 42,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.kcDarkInputAlt,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: border.withValues(alpha: 0.5)),
            ),
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              style: const TextStyle(
                color: AppColors.kcDarkTextPrimary,
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.search,
                  size: 18,
                  color: AppColors.kcDarkTextMuted,
                ),
                hintText: 'Search tasks...',
                hintStyle: TextStyle(
                  color: AppColors.kcDarkTextMuted,
                  fontSize: 14,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
          ),
        );

        final controls = Wrap(
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
              _DarkButton(
                label: 'Manage Sprints',
                icon: Icons.date_range,
                onPressed: onManageSprints,
              ),
            _BoardTypeDropdown(value: boardType, onChanged: onBoardTypeChanged),
          ],
        );

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
              IconButton(
                onPressed: onBack,
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.kcDarkTextPrimary,
                  size: 18,
                ),
                splashRadius: 18,
              ),
              const SizedBox(width: 6),
              Text(
                projectName,
                style: const TextStyle(
                  color: AppColors.kcDarkTitle,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Outfit',
                ),
              ),
              const Spacer(),
              SizedBox(width: 420, child: search),
              const SizedBox(width: 12),
              controls,
              const SizedBox(width: 12),
              _IconSquareButton(
                icon: Icons.settings_outlined,
                onPressed: onSettings,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BoardTypeDropdown extends StatelessWidget {
  const _BoardTypeDropdown({required this.value, required this.onChanged});

  final TaskBoardType value;
  final ValueChanged<TaskBoardType> onChanged;

  @override
  Widget build(BuildContext context) {
    const border = AppColors.kcDarkBorderSoft;
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.kcDarkInputAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border.withValues(alpha: 0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TaskBoardType>(
          value: value,
          dropdownColor: AppColors.kcDarkCard,
          iconEnabledColor: AppColors.kcDarkTextMuted,
          style: const TextStyle(
            color: AppColors.kcDarkTextPrimary,
            fontWeight: FontWeight.w600,
          ),
          items: TaskBoardType.values
              .map(
                (e) => DropdownMenuItem<TaskBoardType>(
                  value: e,
                  child: Text(e.label),
                ),
              )
              .toList(growable: false),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: AppColors.kcDarkTextSecondary,
              size: 30,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.kcDarkTextSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kcDarkPrimary,
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
    const border = AppColors.kcDarkBorderSoft;

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.kcDarkInputAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border.withValues(alpha: 0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: AppColors.kcDarkCard,
          iconEnabledColor: AppColors.kcDarkTextMuted,
          style: const TextStyle(
            color: AppColors.kcDarkTextPrimary,
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
    return SizedBox(
      height: 42,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.kcDarkInputAlt,
          foregroundColor: AppColors.kcDarkTextPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: AppColors.kcDarkBorderSoft.withValues(alpha: 0.55),
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
    return SizedBox(
      width: 42,
      height: 42,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.kcDarkTextPrimary,
          side: BorderSide(
            color: AppColors.kcDarkBorderSoft.withValues(alpha: 0.55),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}
