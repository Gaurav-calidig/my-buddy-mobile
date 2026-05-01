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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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

        final dialogBg = isDark ? const Color(0xFF0B1730) : AppColors.kcLightPage;
        final titleColor = isDark ? AppColors.kcDarkTitle : AppColors.kcLightTitle;
        final textColor = isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle;
        final mutedColor = isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextMuted;
        final borderColor = isDark ? AppColors.kcDarkBorderSoft : AppColors.kcLightBorder;
        final inputBg = isDark ? AppColors.kcDarkInput : AppColors.kcLightInput;
        final inputAltBg = isDark ? AppColors.kcDarkInputAlt : AppColors.kcLightInput;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: width,
            constraints: const BoxConstraints(maxHeight: 600),
            decoration: BoxDecoration(
              color: dialogBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor.withValues(alpha: 0.5),
              ),
              boxShadow: isDark ? null : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Manage States',
                              style: TextStyle(
                                color: titleColor,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Drag states to reorder them. Changes apply immediately to the board.',
                              style: TextStyle(
                                color: mutedColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close,
                            color: mutedColor),
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
                                    color: inputBg
                                        .withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: borderColor
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      ReorderableDragStartListener(
                                        index: index,
                                        child: Icon(
                                          Icons.drag_indicator,
                                          color: mutedColor,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          col.name,
                                          style: TextStyle(
                                            color: textColor,
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
                                          color: inputAltBg,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: borderColor,
                                          ),
                                        ),
                                        child: Text(
                                          '$count',
                                          style: TextStyle(
                                            color: isDark ? Colors.white : AppColors.kcLightTitle,
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
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: mutedColor,
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
                            child: Center(
                              child: CircularProgressIndicator(
                                color: isDark ? AppColors.kcDarkPrimary : AppColors.kcPrimaryColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                Divider(color: borderColor, height: 32),

                // Add Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: inputBg.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: borderColor,
                            ),
                          ),
                          child: TextField(
                            controller: _nameController,
                            enabled: !isLoading,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              hintText: 'New state name',
                              hintStyle: TextStyle(
                                color: mutedColor,
                                fontSize: 14,
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
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
                                (isDark ? AppColors.kcDarkPrimary : AppColors.kcPrimaryColor).withValues(alpha: 0.8),
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
