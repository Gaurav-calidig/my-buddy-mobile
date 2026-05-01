import 'dart:io';
import 'package:core/core/theme/app_colors.dart';
import 'package:core/features/taskhub/domain/entities/board_column_entity.dart';
import 'package:core/features/taskhub/domain/entities/task_entity.dart';
import 'package:core/features/taskhub/domain/enums/task_board_type.dart';
import 'package:core/features/projects/domain/entities/project_entity.dart';
import 'package:core/features/taskhub/domain/entities/sprint_entity.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';

class ExportTasksDialog extends StatefulWidget {
  const ExportTasksDialog({
    super.key,
    required this.columns,
    required this.tasksByColumnId,
    required this.project,
    required this.sprints,
    required this.assigneeById,
  });

  final List<BoardColumnEntity> columns;
  final Map<int, List<TaskEntity>> tasksByColumnId;
  final ProjectEntity project;
  final List<SprintEntity> sprints;
  final Map<String, String> assigneeById;

  @override
  State<ExportTasksDialog> createState() => _ExportTasksDialogState();
}

class _ExportTasksDialogState extends State<ExportTasksDialog> {
  final Set<int> _selectedColumnIds = {};
  bool _selectAll = true;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    for (final col in widget.columns) {
      _selectedColumnIds.add(col.id);
    }
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      _selectAll = value ?? false;
      if (_selectAll) {
        for (final col in widget.columns) {
          _selectedColumnIds.add(col.id);
        }
      } else {
        _selectedColumnIds.clear();
      }
    });
  }

  void _toggleColumn(int id, bool? value) {
    setState(() {
      if (value == true) {
        _selectedColumnIds.add(id);
      } else {
        _selectedColumnIds.remove(id);
      }
      _selectAll = _selectedColumnIds.length == widget.columns.length;
    });
  }

  String _stripHtml(String? html) {
    if (html == null) return '';
    return html.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ').trim();
  }

  Future<void> _onExport() async {
    if (_selectedColumnIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one state.')),
      );
      return;
    }

    setState(() => _isExporting = true);

    try {
      final excel = Excel.createExcel();
      final sheet = excel['Tasks'];
      excel.delete('Sheet1');

      final headers = [
        'Task',
        'Title',
        'Ticket Type',
        'Status',
        'Priority',
        'Assignee',
        'Due Date',
        'Description',
        'Sprint',
        'Created At',
      ];

      final headerStyle = CellStyle(
        bold: true,
        fontFamily: getFontFamily(FontFamily.Arial),
        backgroundColorHex: ExcelColor.fromHexString('#F2F2F2'),
        fontColorHex: ExcelColor.fromHexString('#000000'),
        horizontalAlign: HorizontalAlign.Center,
      );

      for (var i = 0; i < headers.length; i++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = headerStyle;
      }

      int rowIndex = 1;
      final prefix = widget.project.prefix.trim().isEmpty ? 'PRJ' : widget.project.prefix.trim();

      for (final colId in _selectedColumnIds) {
        final tasks = widget.tasksByColumnId[colId] ?? [];
        final colName = widget.columns.firstWhere((c) => c.id == colId).name;

        for (final task in tasks) {
          // Task (ID)
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex)).value = TextCellValue('$prefix-${task.taskNumber}');

          // Title
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex)).value = TextCellValue(task.title);

          // Ticket Type
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex)).value = TextCellValue(task.ticketType.toUpperCase());

          // Status
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex)).value = TextCellValue(colName);

          // Priority
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex)).value = TextCellValue(task.priority.name.toUpperCase());

          // Assignee
          final assigneeName = widget.assigneeById[task.assignee] ?? task.assignee ?? 'Unassigned';
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex)).value = TextCellValue(assigneeName);

          // Due Date
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex)).value = TextCellValue(task.dueDate != null ? DateFormat('dd-MM-yyyy').format(task.dueDate!) : '-');

          // Description
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex)).value = TextCellValue(_stripHtml(task.descriptionHtml));

          // Sprint
          String sprintName = '-';
          if (task.sprintId != null) {
            try {
              sprintName = widget.sprints.firstWhere((s) => s.id == task.sprintId).name;
            } catch (_) {}
          } else if (task.boardType == TaskBoardType.sprint) {
            sprintName = 'Backlog';
          }
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex)).value = TextCellValue(sprintName);

          // Created At
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIndex)).value = TextCellValue(task.createdAt != null ? DateFormat('dd-MM-yyyy').format(task.createdAt!) : '-');
          rowIndex++;
        }
      }

      final fileBytes = excel.save();
      if (fileBytes == null) throw Exception('Failed to generate Excel file');

      // 1. Save to a temporary file (safe and fast for sharing/opening)
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'Tasks_${widget.project.name.replaceAll(' ', '_')}_$timestamp.xlsx';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(fileBytes);

      if (mounted) {
        // 2. Open Share Sheet immediately (Best for Android visibility and iOS "Save to Files")
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Task Export - ${widget.project.name}',
        );

        if (!mounted) return;

        // 3. Show Snackbar with "Open" action as a shortcut
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File exported: $fileName'),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () async {
                try {
                  final result = await OpenFilex.open(file.path);
                  // If no app found to open the file, or error occurs, trigger share sheet as fallback
                  if (result.type == ResultType.noAppToOpen || result.type == ResultType.error) {
                    await Share.shareXFiles([XFile(file.path)]);
                  }
                } catch (_) {
                  await Share.shareXFiles([XFile(file.path)]);
                }
              },
            ),
            duration: const Duration(seconds: 8),
          ),
        );

        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final width = mq.size.width < 500 ? mq.size.width - 32 : 440.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: width,
        constraints: const BoxConstraints(maxHeight: 560),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1D39),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.kcDarkBorderSoft.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Export Tasks',
                      style: TextStyle(
                        color: AppColors.kcDarkTitle,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.kcDarkTextMuted),
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CheckboxListTile(
                value: _selectAll,
                onChanged: _toggleSelectAll,
                title: const Text(
                  'Select All',
                  style: TextStyle(
                    color: AppColors.kcDarkTextPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                activeColor: AppColors.kcDarkPrimary,
                checkColor: Colors.white,
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Divider(color: AppColors.kcDarkBorderSoft, height: 1),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: widget.columns.length,
                itemBuilder: (context, index) {
                  final col = widget.columns[index];
                  final isSelected = _selectedColumnIds.contains(col.id);
                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (v) => _toggleColumn(col.id, v),
                    title: Text(
                      col.name,
                      style: const TextStyle(
                        color: AppColors.kcDarkTextPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    activeColor: AppColors.kcDarkPrimary,
                    checkColor: Colors.white,
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: _isExporting ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.kcDarkBorderSoft),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          foregroundColor: AppColors.kcDarkTextPrimary,
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isExporting ? null : _onExport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.kcDarkPrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: _isExporting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.download_rounded, size: 20),
                                  SizedBox(width: 8),
                                  Text('Export', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                                ],
                              ),
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
  }
}
