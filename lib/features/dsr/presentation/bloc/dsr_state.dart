import 'package:equatable/equatable.dart';
import 'package:core/features/dsr/domain/entities/dsr_entry_entity.dart';
import 'package:core/features/dsr/domain/entities/dsr_project_entity.dart';

class DsrState extends Equatable {
  const DsrState({
    this.isLoading = false,
    this.projects = const <DsrProjectEntity>[],
    this.entriesByDate = const <DateTime, List<DsrEntryEntity>>{},
    this.selectedDate,
    this.errorMessage,
  });

  final bool isLoading;
  final List<DsrProjectEntity> projects;
  final Map<DateTime, List<DsrEntryEntity>> entriesByDate;
  final DateTime? selectedDate;
  final String? errorMessage;

  @override
  List<Object?> get props => [
        isLoading,
        projects,
        entriesByDate,
        selectedDate,
        errorMessage,
      ];

  DsrState copyWith({
    bool? isLoading,
    List<DsrProjectEntity>? projects,
    Map<DateTime, List<DsrEntryEntity>>? entriesByDate,
    DateTime? selectedDate,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DsrState(
      isLoading: isLoading ?? this.isLoading,
      projects: projects ?? this.projects,
      entriesByDate: entriesByDate ?? this.entriesByDate,
      selectedDate: selectedDate ?? this.selectedDate,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
