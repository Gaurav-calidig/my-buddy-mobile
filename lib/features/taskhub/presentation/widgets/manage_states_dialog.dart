import 'package:core/core/theme/app_colors.dart';
import 'package:core/features/taskhub/domain/entities/board_column_entity.dart';
import 'package:core/features/taskhub/presentation/bloc/task_hub_cubit.dart';
import 'package:core/features/taskhub/presentation/bloc/task_hub_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ManageStatesDialog extends StatefulWidget {
  const ManageStatesDialog({super.key});

  @override
  State<ManageStatesDialog> createState() => _ManageStatesDialogState();
}

class _ManageStatesDialogState extends State<ManageStatesDialog> {
  List<BoardColumnEntity>? _localColumns;
  final TextEditingController _nameController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _nameController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleReorder(int oldIndex, int newIndex) {
    if (_localColumns == null) return;
    if (newIndex > oldIndex) newIndex -= 1;
    setState(() {
      final item = _localColumns!.removeAt(oldIndex);
      _localColumns!.insert(newIndex, item);
    });

    final ids = _localColumns!.map((c) => c.id).toList();
    context.read<TaskHubCubit>().reorderColumns(ids);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskHubCubit, TaskHubState>(
      builder: (context, state) {
        // Initialize or update local columns if state changed and we are not dragging
        final incoming = state.columns;
        if (_localColumns == null || !listEquals(_localColumns, incoming)) {
          _localColumns = List.from(incoming);
        }

        final counts = {
          for (var col in state.columns)
            col.id: state.tasksByColumnId[col.id]?.length ?? 0
        };

        final mq = MediaQuery.of(context);
        final width = mq.size.width < 500 ? mq.size.width - 32 : 480.0;
        final isLoading = state.status == TaskHubLoadStatus.loading;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: width,
            constraints: const BoxConstraints(maxHeight: 600),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1730),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.kcDarkBorderSoft.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 16, 8),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Manage States',
                              style: TextStyle(
                                color: AppColors.kcDarkTitle,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Drag states to reorder them. Changes apply immediately to the board.',
                              style: TextStyle(
                                color: AppColors.kcDarkTextMuted,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close,
                            color: AppColors.kcDarkTextMuted),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // List
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Theme(
                          data: ThemeData(canvasColor: Colors.transparent),
                          child: ReorderableListView.builder(
                            scrollController: _scrollController,
                            shrinkWrap: true,
                            itemCount: _localColumns?.length ?? 0,
                            onReorder: _handleReorder,
                            proxyDecorator: (child, index, animation) {
                              return Material(
                                color: Colors.transparent,
                                child: child,
                              );
                            },
                            itemBuilder: (context, index) {
                              final col = _localColumns![index];
                              final count = counts[col.id] ?? 0;
                              return Padding(
                                key: ValueKey(col.id),
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.kcDarkInput
                                        .withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppColors.kcDarkBorderSoft
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      ReorderableDragStartListener(
                                        index: index,
                                        child: const Icon(
                                          Icons.drag_indicator,
                                          color: AppColors.kcDarkTextMuted,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          col.name,
                                          style: const TextStyle(
                                            color: AppColors.kcDarkTextPrimary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.kcDarkInputAlt,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: AppColors.kcDarkBorderSoft,
                                          ),
                                        ),
                                        child: Text(
                                          '$count',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      IconButton(
                                        onPressed: isLoading
                                            ? null
                                            : () => context
                                                .read<TaskHubCubit>()
                                                .deleteColumn(col.id),
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: AppColors.kcDarkTextMuted,
                                          size: 20,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        splashRadius: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        if (isLoading)
                          Container(
                            color: Colors.black12,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.kcDarkPrimary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const Divider(color: AppColors.kcDarkBorderSoft, height: 32),

                // Add Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.kcDarkInput.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.kcDarkBorderSoft,
                            ),
                          ),
                          child: TextField(
                            controller: _nameController,
                            enabled: !isLoading,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'New state name',
                              hintStyle: TextStyle(
                                color: AppColors.kcDarkTextMuted,
                                fontSize: 14,
                              ),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 16),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  final name = _nameController.text.trim();
                                  if (name.isNotEmpty) {
                                    context
                                        .read<TaskHubCubit>()
                                        .createColumn(name);
                                    _nameController.clear();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColors.kcPrimaryColor.withValues(alpha: 0.8),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            elevation: 0,
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.add, size: 20),
                              SizedBox(width: 4),
                              Text(
                                'Add',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
