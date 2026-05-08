import 'dart:io';

import 'package:core/core/dependency_injection/injection_container.dart';
import 'package:core/core/theme/app_colors.dart';
import 'package:core/core/utils/utils.dart';
import 'package:core/core/widgets/custom_video_player.dart';
import 'package:core/core/widgets/document_viewer.dart';
import 'package:core/features/taskhub/domain/entities/sprint_entity.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:core/features/projects/domain/entities/project_entity.dart';
import 'package:core/features/taskhub/domain/usecases/create_attachment_metadata_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/create_attachment_upload_url_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/create_comment_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/create_link_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/create_task_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/delete_attachment_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/delete_task_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/get_attachments_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/get_comments_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/get_links_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/get_project_assignees_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/update_task_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/upload_to_presigned_url_usecase.dart';
import 'package:core/features/taskhub/domain/usecases/delete_link_usecase.dart';
import 'package:core/features/taskhub/domain/entities/board_column_entity.dart';
import 'package:core/features/taskhub/domain/entities/task_assignee_entity.dart';
import 'package:core/features/taskhub/domain/entities/task_attachment_entity.dart';
import 'package:core/features/taskhub/domain/entities/task_comment_entity.dart';
import 'package:core/features/taskhub/domain/entities/task_entity.dart';
import 'package:core/features/taskhub/domain/entities/task_link_entity.dart';
import 'package:core/features/taskhub/domain/enums/task_board_type.dart';
import 'package:core/features/taskhub/domain/enums/task_priority.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:core/core/utils/date_time_utils.dart';
import 'package:core/core/theme/date_format_cubit.dart';
import 'package:mime/mime.dart';

enum TaskTicketType { task, bug }

extension on TaskTicketType {
  String get apiValue => this == TaskTicketType.bug ? 'bug' : 'task';
  String get label => this == TaskTicketType.bug ? 'Bug' : 'Task';
}

class TaskHubTaskDialog extends StatefulWidget {
  const TaskHubTaskDialog({
    super.key,
    required this.project,
    required this.boardType,
    required this.columns,
    required this.defaultColumnId,
    required this.allTasks,
    required this.sprints,
    this.initialSprintId,
    this.task,
  });

  final ProjectEntity project;
  final TaskBoardType boardType;
  final List<BoardColumnEntity> columns;
  final int defaultColumnId;
  final List<TaskEntity> allTasks;
  final List<SprintEntity> sprints;
  final int? initialSprintId;
  final TaskEntity? task;

  bool get isCreate => task == null;

  @override
  State<TaskHubTaskDialog> createState() => _TaskHubTaskDialogState();
}

class _TaskHubTaskDialogState extends State<TaskHubTaskDialog> {
  final _getProjectAssigneesUseCase = sl<GetProjectAssigneesUseCase>();
  final _getAttachmentsUseCase = sl<GetAttachmentsUseCase>();
  final _getLinksUseCase = sl<GetLinksUseCase>();
  final _getCommentsUseCase = sl<GetCommentsUseCase>();
  final _createAttachmentUploadUrlUseCase =
      sl<CreateAttachmentUploadUrlUseCase>();
  final _uploadToPresignedUrlUseCase = sl<UploadToPresignedUrlUseCase>();
  final _createAttachmentMetadataUseCase =
      sl<CreateAttachmentMetadataUseCase>();
  final _createTaskUseCase = sl<CreateTaskUseCase>();
  final _updateTaskUseCase = sl<UpdateTaskUseCase>();
  final _deleteTaskUseCase = sl<DeleteTaskUseCase>();
  final _createCommentUseCase = sl<CreateCommentUseCase>();
  final _deleteAttachmentUseCase = sl<DeleteAttachmentUseCase>();
  final _createLinkUseCase = sl<CreateLinkUseCase>();
  final _deleteLinkUseCase = sl<DeleteLinkUseCase>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _busy = false;
  TaskTicketType _ticketType = TaskTicketType.task;
  TaskPriority _priority = TaskPriority.medium;
  String? _assigneeId;
  DateTime? _dueDate;
  late int _columnId;
  int? _sprintId;

  List<TaskAssigneeEntity> _assignees = const [];
  List<TaskAttachmentEntity> _attachments = const [];
  List<TaskLinkEntity> _links = const [];
  List<TaskCommentEntity> _comments = const [];

  final List<PlatformFile> _stagedAttachments = [];

  int? _normalizeSprintId(int? id) {
    // In Sprint board, we use `-1` to represent backlog/no-sprint.
    if (widget.boardType == TaskBoardType.sprint) {
      final v = id ?? -1;
      if (v == -1) return -1;
      if (widget.sprints.any((s) => s.id == v)) return v;
      return -1;
    }

    // In Kanban board, keep null unless it matches an existing sprint.
    if (id == null) return null;
    if (id == -1) return -1;
    if (widget.sprints.any((s) => s.id == id)) return id;
    return null;
  }

  @override
  void initState() {
    super.initState();
    _columnId = widget.defaultColumnId;
    if (widget.boardType == TaskBoardType.sprint) {
      _sprintId = widget.initialSprintId ?? -1;
    } else {
      _sprintId = widget.initialSprintId;
    }

    final existing = widget.task;
    if (existing != null) {
      _columnId = existing.columnId;
      _titleController.text = existing.title;
      _descriptionController.text = (existing.descriptionHtml ?? '')
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .trim();
      _priority = existing.priority;
      _ticketType = existing.ticketType == 'bug'
          ? TaskTicketType.bug
          : TaskTicketType.task;
      _dueDate = existing.dueDate;
      _assigneeId = (existing.assigneeId ?? '').trim().isEmpty
          ? null
          : existing.assigneeId;
      if (widget.boardType == TaskBoardType.sprint) {
        _sprintId = existing.sprintId ?? -1;
      } else {
        _sprintId = existing.sprintId;
      }
    }

    _loadAssignees();
    if (!widget.isCreate) {
      _reloadDetails();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAssignees() async {
    try {
      final a = await _getProjectAssigneesUseCase(projectId: widget.project.id);
      if (!mounted) return;
      setState(() => _assignees = a);
    } catch (_) {
      // best-effort
    }
  }

  Future<void> _reloadDetails() async {
    final task = widget.task;
    if (task == null) return;

    try {
      final results = await Future.wait([
        _getAttachmentsUseCase(projectId: widget.project.id, taskId: task.id),
        _getLinksUseCase(projectId: widget.project.id, taskId: task.id),
        _getCommentsUseCase(projectId: widget.project.id, taskId: task.id),
      ]);

      if (!mounted) return;
      setState(() {
        _attachments = results[0] as List<TaskAttachmentEntity>;
        _links = results[1] as List<TaskLinkEntity>;
        _comments = results[2] as List<TaskCommentEntity>;
      });
    } catch (_) {
      // best-effort
    }
  }

  Future<void> _pickAttachments() async {
    final res = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (!mounted || res == null) return;
    setState(() => _stagedAttachments.addAll(res.files));
  }

  Future<void> _uploadStagedAttachments({required int taskId}) async {
    if (_stagedAttachments.isEmpty) return;

    for (final f in List<PlatformFile>.from(_stagedAttachments)) {
      final path = f.path;
      if (path == null) continue;
      final file = File(path);
      final bytes = await file.readAsBytes();
      final contentType = lookupMimeType(path) ?? 'application/octet-stream';
      final fileName = f.name;
      final fileSize = bytes.length;

      final uploadInfo = await _createAttachmentUploadUrlUseCase(
        projectId: widget.project.id,
        taskId: taskId,
        contentType: contentType,
        fileName: fileName,
        fileSize: fileSize,
      );
      final uploadUrl = uploadInfo['uploadURL'] ?? '';
      final objectPath = uploadInfo['objectPath'] ?? '';

      if (uploadUrl.isEmpty || objectPath.isEmpty) {
        continue;
      }

      await _uploadToPresignedUrlUseCase(
        uploadUrl: uploadUrl,
        bytes: bytes,
        contentType: contentType,
      );

      await _createAttachmentMetadataUseCase(
        projectId: widget.project.id,
        taskId: taskId,
        contentType: contentType,
        fileName: fileName,
        filePath: objectPath,
        fileSize: fileSize,
      );
    }
    _stagedAttachments.clear();
  }

  Future<void> _createOrSave() async {
    if (_busy) return;
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _busy = true);
    try {
      if (widget.isCreate) {
        final descriptionText = _descriptionController.text.trim();
        final descriptionHtml = descriptionText.isEmpty
            ? null
            : '<p>$descriptionText</p>';

        final created = await _createTaskUseCase(
          projectId: widget.project.id,
          boardType: widget.boardType,
          columnId: _columnId,
          title: title,
          descriptionHtml: descriptionHtml,
          assigneeId: _assigneeId,
          priority: _priority.name,
          ticketType: _ticketType.apiValue,
          position: 0,
          dueDateIso: _dueDate?.toUtc().toIso8601String(),
          sprintId: _sprintId,
        );

        try {
          await _uploadStagedAttachments(taskId: created.id);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Task created, but attachment upload failed. You can attach again from the task.\n$e',
                ),
              ),
            );
          }
        }

        if (!mounted) return;
        Navigator.of(context).pop<TaskEntity>(created);
      } else {
        final descriptionText = _descriptionController.text.trim();
        final descriptionHtml = descriptionText.isEmpty
            ? null
            : '<p>$descriptionText</p>';

        final updated = await _updateTaskUseCase(
          projectId: widget.project.id,
          taskId: widget.task!.id,
          title: title,
          description: descriptionHtml,
          assigneeId: _assigneeId,
          priority: _priority.name,
          ticketType: _ticketType.apiValue,
          columnId: _columnId,
          dueDate: _dueDate?.toUtc().toIso8601String(),
          sprintId: _sprintId,
        );

        try {
          await _uploadStagedAttachments(taskId: updated.id);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Task updated, but attachment upload failed: $e'),
              ),
            );
          }
        }

        if (!mounted) return;
        Navigator.of(context).pop<TaskEntity>(updated);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteTask() async {
    final task = widget.task;
    if (task == null || _busy) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.kcDarkCard,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Delete task?',
          style: TextStyle(
            color: AppColors.kcDarkTextPrimary,
            fontWeight: FontWeight.w800,
            fontFamily: 'Outfit',
          ),
        ),
        content: Text(
          'This will permanently delete “${task.title}”.',
          style: const TextStyle(
            color: AppColors.kcDarkTextSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7D1C1C),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _busy = true);
    try {
      await _deleteTaskUseCase(projectId: widget.project.id, taskId: task.id);
      if (!mounted) return;
      Navigator.of(context).pop<bool>(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _postComment() async {
    final task = widget.task;
    if (task == null) return;
    final content = _commentController.text.trim();
    if (content.isEmpty) return;
    setState(() => _busy = true);
    try {
      await _createCommentUseCase(
        projectId: widget.project.id,
        taskId: task.id,
        content: content,
      );
      _commentController.clear();
      await _reloadDetails();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to post comment: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _downloadFile(String url, String fileName) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not download file')));
    }
  }

  Future<void> _deleteAttachment(int attachmentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.kcBackgroundColorDark,
        title: const Text(
          'Delete Attachment',
          style: TextStyle(color: AppColors.kcDarkTitle),
        ),
        content: const Text(
          'Are you sure you want to remove this attachment?',
          style: TextStyle(color: AppColors.kcDarkTextPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7D1C1C),
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _busy = true);
    try {
      await _deleteAttachmentUseCase(
        projectId: widget.project.id,
        taskId: widget.task!.id,
        attachmentId: attachmentId,
      );
      await _reloadDetails();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _linkTask() async {
    final task = widget.task;
    if (task == null) return;

    // Filter out current task and already linked tasks
    final linkedIds = _links.map((l) => l.childTaskId).toSet();
    final candidates = widget.allTasks.where((t) {
      return t.id != task.id && !linkedIds.contains(t.id);
    }).toList();

    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No other tasks available to link')),
      );
      return;
    }

    final selectedTask = await showDialog<TaskEntity>(
      context: context,
      builder: (ctx) => _SearchTaskDialog(
        tasks: candidates,
        projectPrefix: widget.project.prefix.trim().isEmpty
            ? 'PRJ'
            : widget.project.prefix.trim(),
      ),
    );

    if (selectedTask == null) return;

    setState(() => _busy = true);
    try {
      await _createLinkUseCase(
        projectId: widget.project.id,
        taskId: task.id,
        linkedTaskId: selectedTask.id,
      );
      await _reloadDetails();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to link task: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _attachToExistingTask() async {
    final task = widget.task;
    if (task == null) return;

    final res = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (!mounted || res == null) return;

    setState(() => _busy = true);
    try {
      _stagedAttachments.addAll(res.files);
      await _uploadStagedAttachments(taskId: task.id);
      await _reloadDetails();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;
    final maxHeight = MediaQuery.of(context).size.height;
    final view = View.of(context);
    final viewInsets = EdgeInsets.fromViewPadding(
      view.viewInsets,
      view.devicePixelRatio,
    );
    final dialogWidth = maxWidth < 720 ? maxWidth - 24 : 980.0;

    // Stable height that doesn't change with keyboard
    final availableHeight = (maxHeight * 0.9).clamp(300.0, 900.0);

    // Calculate how much we can push up without hitting the top
    final topMargin = (maxHeight - availableHeight) / 2;
    final pushAmount = viewInsets.bottom > 0
        ? (viewInsets.bottom - 20).clamp(0.0, topMargin - 12)
        : 0.0;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dialogBg = isDark ? const Color(0xFF0B1730) : AppColors.kcLightPage;
    final titleColor = isDark ? AppColors.kcDarkTitle : AppColors.kcLightTitle;
    final mutedColor = isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextMuted;
    final borderColor = isDark ? AppColors.kcDarkBorderSoft : AppColors.kcLightBorder;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: pushAmount),
      child: Dialog(
        insetPadding: const EdgeInsets.all(12),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: dialogWidth,
            maxHeight: availableHeight,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
            decoration: BoxDecoration(
              color: dialogBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: borderColor.withValues(alpha: 0.7),
              ),
              boxShadow: isDark ? null : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Scrollbar(
                  thumbVisibility: true,
                  controller: _scrollController,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.only(right: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.isCreate ? 'Create Task' : 'Task',
                              style: TextStyle(
                                color: titleColor,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: _busy
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              icon: Icon(
                                Icons.close,
                                color: mutedColor,
                              ),
                              splashRadius: 18,
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _label('Title', isDark),
                        const SizedBox(height: 8),
                        _input(
                          controller: _titleController,
                          hint: 'Task title',
                          autofocus: widget.isCreate,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),
                        _label('Description', isDark),
                        const SizedBox(height: 8),
                        _multiline(
                          controller: _descriptionController,
                          hint: 'Optional description',
                          minLines: 6,
                          maxLines: 10,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 18),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isMobile = constraints.maxWidth < 720;
                            final items = [
                                _dropdown<TaskTicketType>(
                                 label: 'Type',
                                 value: _ticketType,
                                 items: TaskTicketType.values,
                                 labelFor: (t) => t.label,
                                 onChanged: (v) =>
                                     setState(() => _ticketType = v),
                                 isDark: isDark,
                               ),
                               _dropdown<TaskPriority>(
                                 label: 'Priority',
                                 value: _priority,
                                 items: TaskPriority.values,
                                 labelFor: (p) =>
                                     p.name[0].toUpperCase() +
                                     p.name.substring(1),
                                 onChanged: (v) => setState(() => _priority = v),
                                 isDark: isDark,
                               ),
                              _assigneeDropdown(isDark),
                              _dueDateField(isDark),
                              _dropdown<int>(
                                label: 'State',
                                value: _columnId,
                                items: widget.columns.map((c) => c.id).toList(),
                                labelFor: (id) => widget.columns
                                    .firstWhere(
                                      (c) => c.id == id,
                                      orElse: () => widget.columns.first,
                                    )
                                    .name,
                                onChanged: (v) => setState(() => _columnId = v),
                                isDark: isDark,
                              ),
                              _dropdown<int?>(
                                label: 'Sprint',
                                value: _normalizeSprintId(_sprintId),
                                items: [-1, ...widget.sprints.map((s) => s.id)],
                                labelFor: (id) => id == -1
                                    ? 'Backlog (No Sprint)'
                                    : widget.sprints
                                          .firstWhere(
                                            (s) => s.id == id,
                                            orElse: () => widget.sprints.first,
                                          )
                                          .name,
                                onChanged: (v) => setState(() => _sprintId = v),
                                isDark: isDark,
                              ),
                            ];

                            if (isMobile) {
                              return Column(
                                children: [
                                  for (int i = 0; i < items.length; i++) ...[
                                    items[i],
                                    if (i != items.length - 1)
                                      const SizedBox(height: 14),
                                  ],
                                ],
                              );
                            }

                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: items[0]),
                                    const SizedBox(width: 12),
                                    Expanded(child: items[1]),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(child: items[2]),
                                    const SizedBox(width: 12),
                                    Expanded(child: items[3]),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(child: items[4]),
                                    const SizedBox(width: 12),
                                    Expanded(child: items[5]),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Divider(
                          color: borderColor.withValues(
                            alpha: 0.45,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _sectionHeader(
                          icon: Icons.attach_file,
                          label: 'Attachments',
                          count: widget.isCreate
                              ? _stagedAttachments.length
                              : _attachments.length,
                          actionLabel: 'Attach',
                          onAction: widget.isCreate
                              ? _pickAttachments
                              : _attachToExistingTask,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 10),
                        if (widget.isCreate)
                          _stagedAttachments.isEmpty
                              ? _muted('No attachments yet.', isDark)
                              : _attachmentsList(
                                  isDark: isDark,
                                  rows: _stagedAttachments
                                      .map(
                                        (f) => _AttachmentRow(
                                          fileName: f.name,
                                          fileSize: f.size,
                                          localPath: f.path,
                                          contentType: lookupMimeType(
                                            f.path ?? '',
                                          ),
                                          isDark: isDark,
                                          trailing: IconButton(
                                            onPressed: () => setState(
                                              () =>
                                                  _stagedAttachments.remove(f),
                                            ),
                                            icon: const Icon(
                                              Icons.close,
                                              color: AppColors.kcDarkTextMuted,
                                            ),
                                            splashRadius: 18,
                                          ),
                                        ),
                                      )
                                      .toList(growable: false),
                                )
                        else
                          _attachments.isEmpty
                              ? _muted('No attachments yet.', isDark)
                              : _attachmentsList(
                                  isDark: isDark,
                                  rows: _attachments
                                      .map(
                                        (a) => _AttachmentRow(
                                          fileName: a.fileName,
                                          fileSize: a.fileSize,
                                          url: a.filePath,
                                          contentType: a.contentType,
                                          uploadedByName: a.uploadedByName,
                                          isDark: isDark,
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                onPressed: () => _downloadFile(
                                                  a.filePath,
                                                  a.fileName,
                                                ),
                                                icon: const Icon(
                                                  Icons.download_rounded,
                                                  size: 20,
                                                ),
                                                color:
                                                    AppColors.kcDarkTextMuted,
                                                splashRadius: 18,
                                              ),
                                              IconButton(
                                                onPressed: () =>
                                                    _deleteAttachment(a.id),
                                                icon: const Icon(
                                                  Icons.close,
                                                  size: 20,
                                                ),
                                                color:
                                                    AppColors.kcDarkTextMuted,
                                                splashRadius: 18,
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(growable: false),
                                ),
                        if (!widget.isCreate) ...[
                          const SizedBox(height: 18),
                          _sectionHeader(
                            icon: Icons.link,
                            label: 'Linked Tasks',
                            count: _links.length,
                            actionLabel: 'Link Task',
                            onAction: _linkTask,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 10),
                          _links.isEmpty
                              ? _muted('No linked tasks.', isDark)
                              : Column(
                                  children: _links
                                      .map(
                                        (l) => _linkRow(
                                          displayId: l.linkedTaskDisplayId,
                                          title: l.linkedTaskTitle,
                                          linkId: l.id,
                                          isDark: isDark,
                                        ),
                                      )
                                      .toList(growable: false),
                                ),
                          const SizedBox(height: 18),
                          _sectionHeader(
                            icon: Icons.mode_comment_outlined,
                            label: 'Comments',
                            count: _comments.length,
                            actionLabel: null,
                            onAction: null,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 10),
                          _commentBox(isDark),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: _busy ? null : _postComment,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? AppColors.kcDarkPrimarySoft : AppColors.kcPrimaryColor.withValues(alpha: 0.8),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: (isDark ? AppColors.kcDarkPrimarySoft : AppColors.kcPrimaryColor)
                                    .withValues(alpha: 0.4),
                              ),
                              child: const Text('Post'),
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (_comments.isNotEmpty)
                            Column(
                              children: _comments
                                  .map(
                                    (c) => _commentRow(
                                      user: c.userName,
                                      content: c.content,
                                      createdAt: c.createdAt,
                                      isDark: isDark,
                                    ),
                                  )
                                  .toList(growable: false),
                             ),
                        ],
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            if (!widget.isCreate) ...[
                              ElevatedButton.icon(
                                onPressed: _busy ? null : _deleteTask,
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Delete'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF7D1C1C),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                            const Spacer(),
                            OutlinedButton(
                              onPressed: _busy
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle,
                                side: BorderSide(
                                  color: borderColor.withValues(
                                    alpha: 0.85,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _busy ? null : _createOrSave,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? AppColors.kcDarkPrimary : AppColors.kcPrimaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(widget.isCreate ? 'Create' : 'Save'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (_busy)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: isDark ? AppColors.kcDarkPrimary : AppColors.kcPrimaryColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        color: isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _muted(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        color: isDark ? AppColors.kcDarkTextSecondary : AppColors.kcLightTextSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    bool autofocus = false,
    required bool isDark,
  }) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      style: TextStyle(color: isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextMuted),
        filled: true,
        fillColor: isDark ? AppColors.kcDarkInputAlt : AppColors.kcLightInput,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: (isDark ? AppColors.kcDarkBorderSoft : AppColors.kcLightBorder).withValues(alpha: 0.55),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.kcDarkPrimary : AppColors.kcPrimaryColor,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _multiline({
    required TextEditingController controller,
    required String hint,
    required int minLines,
    required int maxLines,
    required bool isDark,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(color: isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle, fontSize: 16),
      keyboardType: TextInputType.multiline,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextMuted,
          fontSize: 18,
        ),
        filled: true,
        fillColor: isDark ? AppColors.kcDarkInputAlt : AppColors.kcLightInput,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: (isDark ? AppColors.kcDarkBorderSoft : AppColors.kcLightBorder).withValues(alpha: 0.55),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.kcDarkPrimary : AppColors.kcPrimaryColor,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) labelFor,
    required ValueChanged<T> onChanged,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, isDark),
        const SizedBox(height: 8),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.kcDarkInputAlt : AppColors.kcLightInput,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (isDark ? AppColors.kcDarkBorderSoft : AppColors.kcLightBorder).withValues(alpha: 0.55),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              dropdownColor: isDark ? AppColors.kcDarkCard : AppColors.kcLightCard,
              iconEnabledColor: isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextMuted,
              style: TextStyle(
                color: isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              isExpanded: true,
              items: items
                  .map(
                    (e) =>
                        DropdownMenuItem<T>(value: e, child: Text(labelFor(e))),
                  )
                  .toList(growable: false),
              onChanged: (v) {
                if (v != null || null is T) {
                  onChanged(v as T);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _assigneeDropdown(bool isDark) {
    final seenIds = <String>{};
    final uniqueAssignees = _assignees.where((a) => seenIds.add(a.id)).toList();

    final items = <DropdownMenuItem<String?>>[
      const DropdownMenuItem<String?>(value: null, child: Text('Unassigned')),
      ...uniqueAssignees.map(
        (a) =>
            DropdownMenuItem<String?>(value: a.id, child: Text(a.displayName)),
      ),
    ];

    // Safety check: ensure _assigneeId exists in items to avoid assertion error
    final bool valueExists =
        _assigneeId == null || uniqueAssignees.any((a) => a.id == _assigneeId);
    final effectiveValue = valueExists ? _assigneeId : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Assignee', isDark),
        const SizedBox(height: 8),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.kcDarkInputAlt : AppColors.kcLightInput,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (isDark ? AppColors.kcDarkBorderSoft : AppColors.kcLightBorder).withValues(alpha: 0.55),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: effectiveValue,
              dropdownColor: isDark ? AppColors.kcDarkCard : AppColors.kcLightCard,
              iconEnabledColor: isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextMuted,
              style: TextStyle(
                color: isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              isExpanded: true,
              items: items,
              onChanged: (v) => setState(() => _assigneeId = v),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dueDateField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Due Date', isDark),
        const SizedBox(height: 8),
        BlocBuilder<DateFormatCubit, String>(
          builder: (context, format) {
            final text = _dueDate == null
                ? format.toLowerCase()
                : DateTimeUtils.formatDate(_dueDate, format);

            return InkWell(
              onTap: () async {
                final now = DateTime.now();
                final selected = await showDatePicker(
                  context: context,
                  initialDate: _dueDate ?? now,
                  firstDate: DateTime(now.year - 5),
                  lastDate: DateTime(now.year + 10),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: isDark
                            ? const ColorScheme.dark(
                                primary: AppColors.kcDarkPrimary,
                                onPrimary: Colors.white,
                                surface: Color(0xFF121F3D),
                                onSurface: AppColors.kcDarkTextPrimary,
                              )
                            : ColorScheme.light(
                                primary: AppColors.kcPrimaryColor,
                                surface: Colors.white,
                              ),
                        dialogTheme: DialogThemeData(
                          backgroundColor: isDark ? const Color(0xFF121F3D) : Colors.white,
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: isDark ? AppColors.kcDarkPrimary : AppColors.kcPrimaryColor,
                          ),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (!mounted) return;
                if (selected != null) setState(() => _dueDate = selected);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 52,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.kcDarkInputAlt : AppColors.kcLightInput,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (isDark ? AppColors.kcDarkBorderSoft : AppColors.kcLightBorder)
                        .withValues(alpha: 0.55),
                  ),
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    color: _dueDate == null
                        ? (isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextMuted)
                        : (isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _sectionHeader({
    required IconData icon,
    required String label,
    required int count,
    required String? actionLabel,
    required VoidCallback? onAction,
    required bool isDark,
  }) {
    final textColor = isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle;
    final borderColor = isDark ? AppColors.kcDarkBorderSoft : AppColors.kcLightBorder;
    final surfaceColor = isDark ? AppColors.kcDarkSurface : AppColors.kcLightInput;

    return Row(
      children: [
        Icon(icon, color: textColor, size: 18),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const Spacer(),
        if (actionLabel != null && onAction != null)
          OutlinedButton.icon(
            onPressed: _busy ? null : onAction,
            icon: const Icon(Icons.attach_file, size: 18),
            label: Text(actionLabel),
            style: OutlinedButton.styleFrom(
              foregroundColor: textColor,
              side: BorderSide(
                color: borderColor.withValues(alpha: 0.85),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
      ],
    );
  }

  Widget _attachmentsList({required bool isDark, required List<Widget> rows}) {
    return Column(
      children: [
        for (int i = 0; i < rows.length; i++) ...[
          rows[i],
          if (i != rows.length - 1)
            Divider(color: (isDark ? AppColors.kcDarkBorderSoft : AppColors.kcLightBorder).withValues(alpha: 0.35)),
        ],
      ],
    );
  }

  Widget _linkRow({
    required String displayId,
    required String title,
    required int linkId,
    required bool isDark,
  }) {
    final textColor = isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle;
    final secondaryColor = isDark ? AppColors.kcDarkTextSecondary : AppColors.kcLightTextSecondary;
    final mutedColor = isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextMuted;
    final inputBg = isDark ? AppColors.kcDarkInputAlt : AppColors.kcLightInput;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: inputBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isDark ? AppColors.kcDarkBorderSoft : AppColors.kcLightBorder).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.link, size: 18, color: isDark ? AppColors.kcDarkPrimarySoft : AppColors.kcPrimaryColor),
          const SizedBox(width: 10),
          Text(
            displayId,
            style: TextStyle(
              color: secondaryColor,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFamily: 'Outfit',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: _busy ? null : () => _deleteLink(linkId),
            icon: Icon(
              Icons.close,
              size: 18,
              color: mutedColor,
            ),
            splashRadius: 18,
            tooltip: 'Remove link',
          ),
        ],
      ),
    );
  }

  Future<void> _deleteLink(int linkId) async {
    if (_busy || widget.task == null) return;
    setState(() => _busy = true);
    try {
      await _deleteLinkUseCase(
        projectId: widget.project.id,
        taskId: widget.task!.id,
        linkId: linkId,
      );
      // Re-load to refresh links
      final results = await Future.wait([
        _getAttachmentsUseCase(
          projectId: widget.project.id,
          taskId: widget.task!.id,
        ),
        _getLinksUseCase(projectId: widget.project.id, taskId: widget.task!.id),
        _getCommentsUseCase(
          projectId: widget.project.id,
          taskId: widget.task!.id,
        ),
      ]);
      if (mounted) {
        setState(() {
          _attachments = results[0] as List<TaskAttachmentEntity>;
          _links = results[1] as List<TaskLinkEntity>;
          _comments = results[2] as List<TaskCommentEntity>;
          _busy = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete link: $e')));
      }
    }
  }

  Widget _commentBox(bool isDark) {
    return TextField(
      controller: _commentController,
      style: TextStyle(
        color: isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle,
        fontSize: 16,
      ),
      minLines: 3,
      maxLines: 6,
      decoration: InputDecoration(
        hintText: 'Write a comment...',
        hintStyle: TextStyle(
          color: isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextMuted,
          fontSize: 18,
        ),
        filled: true,
        fillColor: isDark ? AppColors.kcDarkInputAlt : AppColors.kcLightInput,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: (isDark ? AppColors.kcDarkBorderSoft : AppColors.kcLightBorder)
                .withValues(alpha: 0.55),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.kcDarkPrimary : AppColors.kcPrimaryColor,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _commentRow({
    required String user,
    required String content,
    required bool isDark,
    DateTime? createdAt,
  }) {
    String timeStr = '';
    if (createdAt != null) {
      final now = DateTime.now();
      final diff = now.difference(createdAt);
      if (diff.inMinutes < 1) {
        timeStr = 'Just now';
      } else if (diff.inHours < 1) {
        timeStr = '${diff.inMinutes}m ago';
      } else if (diff.inDays < 1) {
        timeStr = '${diff.inHours}h ago';
      } else {
        timeStr = DateFormat('MMM d, h:mm a').format(createdAt);
      }
    }

    final textColor = isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle;
    final mutedColor = isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextMuted;
    final inputBg = isDark ? AppColors.kcDarkInputAlt : AppColors.kcLightInput;
    final primarySoft = isDark ? AppColors.kcDarkPrimarySoft : AppColors.kcPrimaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: primarySoft.withValues(alpha: 0.2),
            child: Text(
              user.isNotEmpty ? user[0].toUpperCase() : '?',
              style: TextStyle(
                color: primarySoft,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    if (timeStr.isNotEmpty) ...[
                      const Spacer(),
                      Text(
                        timeStr,
                        style: TextStyle(
                          color: mutedColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: inputBg.withValues(alpha: 0.6),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                      bottomRight: Radius.circular(14),
                    ),
                  ),
                  child: Text(
                    content,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Outfit',
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentRow extends StatelessWidget {
  const _AttachmentRow({
    required this.fileName,
    required this.fileSize,
    required this.trailing,
    this.url,
    this.localPath,
    this.contentType,
    this.uploadedByName,
    required this.isDark,
  });

  final String fileName;
  final int fileSize;
  final Widget trailing;
  final String? url;
  final String? localPath;
  final String? contentType;
  final String? uploadedByName;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final kb = (fileSize / 1024).round();

    // Improved detection using contentType first, then extension
    final isImage =
        (contentType?.startsWith('image/') ?? false) ||
        AppUtils.getFileTypeFromUrl(url ?? localPath ?? fileName) == 'image';
    final isVideo =
        (contentType?.startsWith('video/') ?? false) ||
        AppUtils.getFileTypeFromUrl(url ?? localPath ?? fileName) == 'video';
    final isPdf =
        (contentType == 'application/pdf') ||
        AppUtils.getFileTypeFromUrl(url ?? localPath ?? fileName) == 'pdf';

    final type = isImage
        ? 'image'
        : (isVideo ? 'video' : (isPdf ? 'pdf' : 'unknown'));

    return InkWell(
      onTap: (url == null && localPath == null)
          ? null
          : () {
              if (isImage) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      appBar: AppBar(
                        title: Text(fileName),
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      backgroundColor: Colors.black,
                      body: Center(
                        child: localPath != null
                            ? Image.file(File(localPath!))
                            : Image.network(
                                url!,
                                loadingBuilder: (_, child, progress) =>
                                    progress == null
                                    ? child
                                    : const CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.broken_image,
                                  color: Colors.white,
                                  size: 64,
                                ),
                              ),
                      ),
                    ),
                  ),
                );
              } else if (isVideo && url != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      appBar: AppBar(title: Text(fileName)),
                      backgroundColor: Colors.black,
                      body: Center(child: CustomVideoPlayer(videoUrl: url!)),
                    ),
                  ),
                );
              } else if (url != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DocumentViewerPage(url: url!),
                  ),
                );
              }
            },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          children: [
            if (isImage && url != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  url!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _typeIcon(type, isDark),
                ),
              )
            else if (isImage && localPath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(localPath!),
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _typeIcon(type, isDark),
                ),
              )
            else
              _typeIcon(type, isDark),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: TextStyle(
                      color: isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Outfit',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$kb KB',
                    style: TextStyle(
                      color: isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextMuted,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (uploadedByName != null) ...[
              const SizedBox(width: 12),
              Text(
                uploadedByName!,
                style: TextStyle(
                  color: isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(width: 10),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _typeIcon(String type, bool isDark) {
    IconData iconData = Icons.insert_drive_file_outlined;
    Color iconColor = isDark ? AppColors.kcDarkTextSecondary : AppColors.kcLightTextSecondary;

    if (type == 'pdf') {
      iconData = Icons.picture_as_pdf_outlined;
      iconColor = Colors.redAccent;
    } else if (type == 'video') {
      iconData = Icons.video_library_outlined;
      iconColor = isDark ? AppColors.kcDarkPrimary : AppColors.kcPrimaryColor;
    } else if (type == 'image') {
      iconData = Icons.image_outlined;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: iconColor),
    );
  }
}

class _SearchTaskDialog extends StatefulWidget {
  const _SearchTaskDialog({required this.tasks, required this.projectPrefix});

  final List<TaskEntity> tasks;
  final String projectPrefix;

  @override
  State<_SearchTaskDialog> createState() => _SearchTaskDialogState();
}

class _SearchTaskDialogState extends State<_SearchTaskDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<TaskEntity> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.tasks;
  }

  void _onSearch(String q) {
    final query = q.toLowerCase();
    setState(() {
      _filtered = widget.tasks.where((t) {
        final ticket = '${widget.projectPrefix}-${t.taskNumber}';
        return t.title.toLowerCase().contains(query) ||
            ticket.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.kcDarkCard : AppColors.kcLightCard,
      surfaceTintColor: Colors.transparent,
      title: Text(
        'Link Task',
        style: TextStyle(
          color: isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle,
          fontWeight: FontWeight.w800,
          fontFamily: 'Outfit',
        ),
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              onChanged: _onSearch,
              autofocus: true,
              style: TextStyle(color: isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle),
              decoration: InputDecoration(
                hintText: 'Search by title or number...',
                hintStyle: TextStyle(color: isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextMuted),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextMuted,
                ),
                filled: true,
                fillColor: isDark ? AppColors.kcDarkInputAlt : AppColors.kcLightInput,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: _filtered.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'No tasks found',
                          style: TextStyle(color: isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextMuted),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _filtered.length,
                        itemBuilder: (ctx, i) {
                          final t = _filtered[i];
                          final ticket =
                              '${widget.projectPrefix}-${t.taskNumber}';
                          return ListTile(
                            onTap: () => Navigator.of(ctx).pop(t),
                            title: Text(
                              t.title,
                              style: TextStyle(
                                color: isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              ticket,
                              style: TextStyle(
                                color: isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextMuted,
                                fontSize: 12,
                              ),
                            ),
                            trailing: Icon(
                              Icons.add_link,
                              color: isDark ? AppColors.kcDarkPrimary : AppColors.kcPrimaryColor,
                              size: 20,
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
