import 'package:core/core/theme/app_colors.dart';
import 'package:core/core/dependency_injection/injection_container.dart';
import 'package:core/features/taskhub/domain/entities/sprint_entity.dart';
import 'package:core/features/taskhub/domain/usecases/sprint_usecases.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:core/core/utils/date_time_utils.dart';
import 'package:core/core/theme/date_format_cubit.dart';

class ManageSprintsDialog extends StatefulWidget {
  final int projectId;

  const ManageSprintsDialog({super.key, required this.projectId});

  @override
  State<ManageSprintsDialog> createState() => _ManageSprintsDialogState();
}

class _ManageSprintsDialogState extends State<ManageSprintsDialog> {
  final _getSprintsUseCase = sl<GetSprintsUseCase>();
  final _createSprintUseCase = sl<CreateSprintUseCase>();
  final _updateSprintUseCase = sl<UpdateSprintUseCase>();
  final _deleteSprintUseCase = sl<DeleteSprintUseCase>();

  List<SprintEntity> _sprints = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSprints();
  }

  Future<void> _loadSprints() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final results = await _getSprintsUseCase(widget.projectId);
      if (!mounted) return;
      setState(() {
        _sprints = results;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading sprints: $e')));
      }
    }
  }

  Future<void> _showAddEditDialog([SprintEntity? sprint]) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final nameController = TextEditingController(text: sprint?.name ?? '');
    final goalController = TextEditingController(text: sprint?.goal ?? '');
    DateTime? startDate = sprint?.startDate;
    DateTime? endDate = sprint?.endDate;
    String status = (sprint?.status ?? 'planned') == 'planning'
        ? 'planned'
        : (sprint?.status ?? 'planned');
    if (status != 'planned' && status != 'active' && status != 'completed') {
      status = 'planned';
    }

    final currentFormat = context.read<DateFormatCubit>().state;

    final startController = TextEditingController(
      text: DateTimeUtils.formatDate(startDate, currentFormat),
    );
    final endController = TextEditingController(
      text: DateTimeUtils.formatDate(endDate, currentFormat),
    );

    bool? result;
    try {
      result = await showDialog<bool>(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setLocalState) {
            final dialogBg = isDark ? AppColors.kcDarkSurface : AppColors.kcLightPage;
            final textColor = isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle;
            final secondaryTextColor = isDark ? AppColors.kcDarkTextSecondary : AppColors.kcLightTextSecondary;
            final mutedColor = isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextMuted;
            final inputBg = isDark ? AppColors.kcDarkInputAlt : AppColors.kcLightInput;
            final borderColor = isDark ? AppColors.kcDarkBorderSoft : AppColors.kcLightBorder;

            Widget label(String text) {
              return Text(
                text,
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              );
            }

            InputDecoration decoration({
              required String hintText,
              Widget? suffixIcon,
            }) {
              return InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: mutedColor),
                filled: true,
                fillColor: inputBg,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: borderColor.withValues(alpha: 0.55),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: isDark ? AppColors.kcDarkPrimary : AppColors.kcPrimaryColor),
                ),
                suffixIcon: suffixIcon,
              );
            }

            Widget field({
              required String labelText,
              required TextEditingController controller,
              required String hintText,
              int? minLines,
              int? maxLines = 1,
              bool readOnly = false,
              VoidCallback? onTap,
              Widget? suffixIcon,
            }) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  label(labelText),
                  const SizedBox(height: 6),
                  TextField(
                    controller: controller,
                    readOnly: readOnly,
                    onTap: onTap,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
                    minLines: minLines,
                    maxLines: maxLines,
                    decoration: decoration(
                      hintText: hintText,
                      suffixIcon: suffixIcon,
                    ),
                  ),
                ],
              );
            }

            Future<void> pickDate({
              required DateTime? initial,
              required ValueChanged<DateTime> onPicked,
              DateTime? firstDate,
            }) async {
              DateTime initialDate = initial ?? DateTime.now();
              if (firstDate != null && initialDate.isBefore(firstDate)) {
                initialDate = firstDate;
              }
              final picked = await showDatePicker(
                context: ctx,
                initialDate: initialDate,
                firstDate: firstDate ?? DateTime(2000),
                lastDate: DateTime(2100),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: isDark
                          ? const ColorScheme.dark(
                              primary: AppColors.kcDarkPrimary,
                              surface: AppColors.kcDarkCard,
                            )
                          : const ColorScheme.light(
                              primary: AppColors.kcPrimaryColor,
                              surface: Colors.white,
                            ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) onPicked(picked);
            }

            return Dialog(
              backgroundColor: dialogBg,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 40,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Manage Sprints',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color: mutedColor,
                              ),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                        Divider(
                          color: borderColor,
                          height: 1,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          sprint == null ? 'New Sprint' : 'Edit Sprint',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        field(
                          labelText: 'Name',
                          controller: nameController,
                          hintText: 'Sprint name',
                        ),
                        const SizedBox(height: 12),
                        field(
                          labelText: 'Goal (optional)',
                          controller: goalController,
                          hintText: 'Sprint goal',
                          minLines: 3,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        BlocBuilder<DateFormatCubit, String>(
                          builder: (context, format) {
                            return Row(
                              children: [
                                Expanded(
                                  child: field(
                                    labelText: 'Start Date',
                                    controller: startController,
                                    hintText: format.toLowerCase(),
                                    readOnly: true,
                                    suffixIcon: Icon(
                                      Icons.calendar_today_rounded,
                                      size: 18,
                                      color: mutedColor,
                                    ),
                                    onTap: () => pickDate(
                                      initial: startDate,
                                      onPicked: (d) {
                                        setLocalState(() {
                                          startDate = d;
                                          startController.text = DateTimeUtils.formatDate(
                                            d,
                                            format,
                                          );
                                          if (endDate != null && d.isAfter(endDate!)) {
                                            endDate = null;
                                            endController.clear();
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: field(
                                    labelText: 'End Date',
                                    controller: endController,
                                    hintText: format.toLowerCase(),
                                    readOnly: true,
                                    suffixIcon: Icon(
                                      Icons.calendar_today_rounded,
                                      size: 18,
                                      color: mutedColor,
                                    ),
                                    onTap: () => pickDate(
                                      initial: endDate,
                                      firstDate: startDate,
                                      onPicked: (d) {
                                        setLocalState(() {
                                          endDate = d;
                                          endController.text = DateTimeUtils.formatDate(
                                            d,
                                            format,
                                          );
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            label('Status'),
                            const SizedBox(height: 6),
                            Container(
                              height: 44,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                color: inputBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: borderColor
                                      .withValues(alpha: 0.55),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: status,
                                  dropdownColor: isDark ? AppColors.kcDarkCard : AppColors.kcLightCard,
                                  iconEnabledColor: mutedColor,
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'planned',
                                      child: Text('Planning'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'active',
                                      child: Text('Active'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'completed',
                                      child: Text('Completed'),
                                    ),
                                  ],
                                  onChanged: (v) {
                                    if (v == null) return;
                                    setLocalState(() => status = v);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            ValueListenableBuilder<TextEditingValue>(
                              valueListenable: nameController,
                              builder: (context, nameValue, child) {
                                final name = nameValue.text.trim();
                                final isValid = name.isNotEmpty &&
                                    startDate != null &&
                                    endDate != null &&
                                    !endDate!.isBefore(startDate!);
                                return ElevatedButton(
                                  onPressed: isValid
                                      ? () => Navigator.pop(ctx, true)
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDark ? AppColors.kcDarkPrimary : AppColors.kcPrimaryColor,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: (isDark ? AppColors.kcDarkPrimary : AppColors.kcPrimaryColor).withValues(alpha: 0.5),
                                    disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    sprint == null ? 'Create' : 'Update',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 10),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: TextButton.styleFrom(
                                foregroundColor: secondaryTextColor,
                              ),
                              child: const Text('Cancel'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    } finally {
      Future.delayed(const Duration(milliseconds: 300), () {
        nameController.dispose();
        goalController.dispose();
        startController.dispose();
        endController.dispose();
      });
    }

    if (result == true) {
      try {
        if (sprint == null) {
          await _createSprintUseCase(
            projectId: widget.projectId,
            name: nameController.text,
            startDate: startDate ?? DateTime.now(),
            endDate: endDate ?? DateTime.now().add(const Duration(days: 7)),
            goal: goalController.text,
            status: status,
          );
        } else {
          await _updateSprintUseCase(
            projectId: widget.projectId,
            sprintId: sprint.id,
            name: nameController.text,
            startDate: startDate ?? DateTime.now(),
            endDate: endDate ?? DateTime.now().add(const Duration(days: 7)),
            goal: goalController.text,
            status: status,
          );
        }
        if (!mounted) return;
        _loadSprints();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error saving sprint: $e')));
        }
      }
    }
  }

  Future<void> _deleteSprint(SprintEntity sprint) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.kcDarkCard : AppColors.kcLightCard,
        title: Text(
          'Delete Sprint',
          style: TextStyle(color: isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle),
        ),
        content: Text('Are you sure you want to delete ${sprint.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _deleteSprintUseCase(
          projectId: widget.projectId,
          sprintId: sprint.id,
        );
        if (!mounted) return;
        _loadSprints();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting sprint: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dialogBg = isDark ? AppColors.kcDarkSurface : AppColors.kcLightPage;
    final textColor = isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle;
    final mutedColor = isDark ? AppColors.kcDarkTextMuted : AppColors.kcLightTextMuted;
    final borderColor = isDark ? AppColors.kcDarkBorderSoft : AppColors.kcLightBorder;

    return Dialog(
      backgroundColor: dialogBg,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Manage Sprints',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: mutedColor,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_loading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator(color: isDark ? AppColors.kcDarkPrimary : AppColors.kcPrimaryColor)),
                )
              else if (_sprints.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      'No sprints found',
                      style: TextStyle(color: mutedColor),
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _sprints.length,
                    separatorBuilder: (context, index) =>
                        Divider(color: borderColor),
                    itemBuilder: (context, index) {
                      final sprint = _sprints[index];
                      return ListTile(
                        title: Text(
                          sprint.name,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${DateFormat('MMM d').format(sprint.startDate)} - ${DateFormat('MMM d').format(sprint.endDate)}\nGoal: ${sprint.goal}',
                          style: TextStyle(
                            color: mutedColor,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                size: 18,
                                color: isDark ? AppColors.kcDarkPrimary : AppColors.kcPrimaryColor,
                              ),
                              onPressed: () => _showAddEditDialog(sprint),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                size: 18,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => _deleteSprint(sprint),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddEditDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Create New Sprint'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.kcDarkPrimary : AppColors.kcPrimaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
