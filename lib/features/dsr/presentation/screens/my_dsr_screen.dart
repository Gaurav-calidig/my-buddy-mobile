import 'package:core/core/theme/app_colors.dart';
import 'package:core/core/widgets/custom_app_bar.dart';
import 'package:core/core/widgets/template_feature_drawer.dart';
import 'package:core/features/dsr/domain/entities/dsr_entry_entity.dart';
import 'package:core/features/dsr/presentation/bloc/dsr_bloc.dart';
import 'package:core/features/dsr/presentation/bloc/dsr_event.dart';
import 'package:core/features/dsr/presentation/bloc/dsr_state.dart';
import 'package:core/features/dsr/presentation/widgets/dsr_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/core/utils/date_time_utils.dart';
import 'package:core/core/theme/date_format_cubit.dart';

class MyDsrScreen extends StatefulWidget {
  const MyDsrScreen({super.key});

  @override
  State<MyDsrScreen> createState() => _MyDsrScreenState();
}

enum _DsrTab { add, history }

class _MyDsrScreenState extends State<MyDsrScreen> {
  static const List<String> _statuses = <String>['In Progress', 'Completed', 'Blocked'];

  final TextEditingController _descriptionController = TextEditingController();

  _DsrTab _activeTab = _DsrTab.add;
  String? _selectedProject;
  String? _selectedHours;
  String _selectedStatus = 'Completed';

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  List<String> get _hoursOptions => List<String>.generate(19, (int index) {
        final double value = index * 0.5;
        return '${value.toStringAsFixed(1)}h';
      });

  DateTime get _todayKey => _dayKey(DateTime.now());

  DateTime _dayKey(DateTime date) => DateTime(date.year, date.month, date.day);

  String _formatDate(DateTime date, String format) {
    return DateTimeUtils.formatDate(date, format);
  }

  String _toDisplayStatus(String raw) {
    final String normalized = raw.trim().replaceAll('_', ' ').toLowerCase();
    if (normalized.isEmpty) return 'Completed';
    return normalized
        .split(RegExp(r'\s+'))
        .where((String word) => word.isNotEmpty)
        .map((String word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  void _addEntry(DsrState state, DateTime selectedDate) {
    final String projectName = (_selectedProject ?? '').trim();
    final String selectedHours = (_selectedHours ?? '').trim();
    if (projectName.isEmpty || selectedHours.isEmpty) return;

    final int projectIndex = state.projects.indexWhere((p) => p.name == projectName);
    if (projectIndex == -1) return;
    final project = state.projects[projectIndex];

    final String normalizedHours = selectedHours.replaceAll('h', '').trim();
    final String description = _descriptionController.text.trim();
    final String status = _selectedStatus.trim().toLowerCase().replaceAll(' ', '_');

    context.read<DsrBloc>().add(
          DsrCreateRequested(
            projectId: project.id,
            date: selectedDate,
            description: description,
            hours: normalizedHours,
            status: status,
          ),
        );

    setState(() {
      _selectedHours = null;
      _selectedStatus = 'Completed';
      _descriptionController.clear();
    });
  }

  Future<void> _deleteEntry(DateTime date, int index) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final DateTime dateKey = _dayKey(date);
    final List<DsrEntryEntity> entries = context.read<DsrBloc>().state.entriesByDate[dateKey] ?? <DsrEntryEntity>[];
    if (index < 0 || index >= entries.length) return;
    final String dsrId = entries[index].id.trim();
    if (dsrId.isEmpty) return;

    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.kcBackgroundColorDark : AppColors.kcLightCard,
          title: Text(
            'Delete DSR Entry',
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.kcLightTitle,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this entry?',
            style: TextStyle(
              color: isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTextSecondary,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) return;
    context.read<DsrBloc>().add(DsrDeleteRequested(dsrId: dsrId, date: dateKey));
  }

  Future<void> _editEntry({
    required DsrState state,
    required DateTime date,
    required int index,
    required DsrEntryEntity current,
  }) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final List<String> projectNames = state.projects.map((p) => p.name).toList(growable: false);
    String? selectedProject = projectNames.contains(current.project) ? current.project : (projectNames.isNotEmpty ? projectNames.first : null);
    final String currentStatusLabel = _toDisplayStatus(current.status);
    String selectedStatus = _statuses.firstWhere((String item) => item.toLowerCase() == currentStatusLabel.toLowerCase(), orElse: () => 'Completed');
    String? selectedHours = '${current.hours.toStringAsFixed(1)}h';
    String description = current.description;

    final bool? shouldSave = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? AppColors.kcBackgroundColorDark : AppColors.kcLightCard,
              title: Text(
                'Edit DSR Entry',
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.kcLightTitle,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 340,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const DsrLabel('Project'),
                      DsrDropdownField<String>(value: selectedProject, hintText: 'Select project', items: projectNames, onChanged: (String? v) => setDialogState(() => selectedProject = v)),
                      const SizedBox(height: 10),
                      const DsrLabel('Hours'),
                      DsrDropdownField<String>(value: selectedHours, hintText: 'Select hours', items: _hoursOptions, onChanged: (String? v) => setDialogState(() => selectedHours = v)),
                      const SizedBox(height: 10),
                      const DsrLabel('Status'),
                      DsrDropdownField<String>(
                        value: selectedStatus,
                        hintText: 'Select status',
                        items: _statuses,
                        onChanged: (String? v) {
                          if (v == null) return;
                          setDialogState(() => selectedStatus = v);
                        },
                      ),
                      const SizedBox(height: 10),
                      const DsrLabel('Description'),
                      TextFormField(
                        initialValue: description,
                        maxLines: 4,
                        style: TextStyle(color: isDark ? AppColors.kcDarkTextPrimary : AppColors.kcLightTitle),
                        decoration: dsrFieldDecoration('What did you work on?', isDark: isDark),
                        onChanged: (String value) => description = value,
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Save')),
              ],
            );
          },
        );
      },
    );

    if (shouldSave != true || selectedHours == null) return;
    final String dsrId = current.id.trim();
    if (dsrId.isEmpty || !mounted) return;

    final String normalizedHours = selectedHours!.replaceAll('h', '').trim();
    final String normalizedDescription = description.trim();
    final String normalizedStatus = selectedStatus.trim().toLowerCase().replaceAll(' ', '_');
    context.read<DsrBloc>().add(
          DsrUpdateRequested(
            dsrId: dsrId,
            date: _dayKey(date),
            description: normalizedDescription,
            hours: normalizedHours,
            status: normalizedStatus,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      drawer: const TemplateFeatureDrawer(),
      appBar: const CustomAppBar(title: 'DSR'),
      body: BlocBuilder<DsrBloc, DsrState>(
        builder: (BuildContext context, DsrState state) {
          final DateTime selectedDate = state.selectedDate ?? _todayKey;
          final bool showTabLoader = state.isLoading;
          final List<String> projectNames = state.projects.map((p) => p.name).toList(growable: false);
          if (_selectedProject == null && projectNames.isNotEmpty) {
            _selectedProject = projectNames.first;
          }

          final DateTime dateKey = _dayKey(selectedDate);
          final List<DsrEntryEntity> addTabEntries = state.entriesByDate[dateKey] ?? <DsrEntryEntity>[];
          final double addTabTotalHours = addTabEntries.fold<double>(0, (double sum, DsrEntryEntity entry) => sum + entry.hours);

          final DateTime today = _todayKey;
          final DateTime yesterday = today.subtract(const Duration(days: 1));
          final List<MapEntry<DateTime, List<DsrEntryEntity>>> historyGroups = state.entriesByDate.entries.toList()..sort((a, b) => b.key.compareTo(a.key));

          final titleColor = isDark ? Colors.white : AppColors.kcLightTitle;
          final subTitleColor = isDark ? AppColors.kcDarkTextSecondary : AppColors.kcLightTextSecondary;

          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: isDark
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[AppColors.kcDarkGradientTop, AppColors.kcDarkGradientBottom],
                        )
                      : LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            AppColors.kcLightPage,
                            AppColors.kcLightPage.withValues(alpha: 0.95),
                          ],
                        ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(8, 10, 8, 20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          'Daily Status Report',
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Log your daily work activity and hours',
                          style: TextStyle(
                            color: subTitleColor,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        DsrTabStripWidget(
                          isAddSelected: _activeTab == _DsrTab.add,
                          onAddTap: () => setState(() => _activeTab = _DsrTab.add),
                          onHistoryTap: () {
                            setState(() => _activeTab = _DsrTab.history);
                            context.read<DsrBloc>().add(const DsrHistoryLoadRequested());
                          },
                        ),
                        const SizedBox(height: 10),
                        if (state.errorMessage != null) ...<Widget>[
                          Text(
                            state.errorMessage!,
                            style: TextStyle(
                              color: isDark ? AppColors.kcDarkErrorText : AppColors.kcErrorColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        if (showTabLoader)
                          Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: isDark ? Colors.white : AppColors.kcPrimaryColor,
                              ),
                            ),
                          )
                        else if (_activeTab == _DsrTab.add)
                          BlocBuilder<DateFormatCubit, String>(
                            builder: (context, format) {
                              return DsrAddTabWidget(
                                selectedDate: selectedDate,
                                today: today,
                                yesterday: yesterday,
                                totalHours: addTabTotalHours,
                                projectNames: projectNames,
                                selectedProject: _selectedProject,
                                selectedHours: _selectedHours,
                                selectedStatus: _selectedStatus,
                                descriptionController: _descriptionController,
                                entries: addTabEntries,
                                formatDate: (date) => _formatDate(date, format),
                                onDateChanged: (DateTime value) => context.read<DsrBloc>().add(DsrDateChangedRequested(value)),
                                onProjectChanged: (String? value) => setState(() => _selectedProject = value),
                                onHoursChanged: (String? value) => setState(() => _selectedHours = value),
                                onStatusChanged: (String? value) {
                                  if (value != null) setState(() => _selectedStatus = value);
                                },
                                onAdd: () => _addEntry(state, selectedDate),
                                onEdit: (int index, DsrEntryEntity entry) => _editEntry(state: state, date: selectedDate, index: index, current: entry),
                                onDelete: (int index) => _deleteEntry(selectedDate, index),
                                statuses: _statuses,
                                hoursOptions: _hoursOptions,
                              );
                            },
                          )
                        else
                          BlocBuilder<DateFormatCubit, String>(
                            builder: (context, format) {
                              return DsrHistoryTabWidget(
                                historyGroups: historyGroups,
                                today: today,
                                yesterday: yesterday,
                                formatDate: (date) => _formatDate(date, format),
                                onEdit: (DateTime date, int index, DsrEntryEntity entry) =>
                                    _editEntry(state: state, date: date, index: index, current: entry),
                                onDelete: (DateTime date, int index) => _deleteEntry(date, index),
                              );
                            },
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
}
