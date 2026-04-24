import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/features/dsr/domain/entities/dsr_create_request_entity.dart';
import 'package:core/features/dsr/domain/entities/dsr_entry_entity.dart';
import 'package:core/features/dsr/domain/usecases/create_dsr_usecase.dart';
import 'package:core/features/dsr/domain/usecases/delete_dsr_usecase.dart';
import 'package:core/features/dsr/domain/usecases/get_dsr_by_date_usecase.dart';
import 'package:core/features/dsr/domain/usecases/get_dsr_projects_usecase.dart';
import 'package:core/features/dsr/domain/usecases/get_my_dsr_usecase.dart';
import 'package:core/features/dsr/domain/usecases/update_dsr_usecase.dart';

import 'dsr_event.dart';
import 'dsr_state.dart';

class DsrBloc extends Bloc<DsrEvent, DsrState> {
  DsrBloc({
    required this.getDsrProjectsUseCase,
    required this.getDsrByDateUseCase,
    required this.getMyDsrUseCase,
    required this.createDsrUseCase,
    required this.updateDsrUseCase,
    required this.deleteDsrUseCase,
  }) : super(const DsrState()) {
    on<DsrInitialLoadRequested>(_onInitialLoad);
    on<DsrDateChangedRequested>(_onDateChanged);
    on<DsrHistoryLoadRequested>(_onHistoryLoadRequested);
    on<DsrCreateRequested>(_onCreateRequested);
    on<DsrUpdateRequested>(_onUpdateRequested);
    on<DsrDeleteRequested>(_onDeleteRequested);
  }

  final GetDsrProjectsUseCase getDsrProjectsUseCase;
  final GetDsrByDateUseCase getDsrByDateUseCase;
  final GetMyDsrUseCase getMyDsrUseCase;
  final CreateDsrUseCase createDsrUseCase;
  final UpdateDsrUseCase updateDsrUseCase;
  final DeleteDsrUseCase deleteDsrUseCase;

  Future<void> _onInitialLoad(
    DsrInitialLoadRequested event,
    Emitter<DsrState> emit,
  ) async {
    final DateTime today = _dayKey(DateTime.now());
    emit(state.copyWith(isLoading: true, selectedDate: today, clearError: true));
    try {
      final projects = await getDsrProjectsUseCase();
      final todayEntries = await getDsrByDateUseCase(today);

      final Map<DateTime, List<DsrEntryEntity>> grouped = <DateTime, List<DsrEntryEntity>>{};
      grouped[today] = List<DsrEntryEntity>.from(todayEntries, growable: true);

      emit(
        state.copyWith(
          isLoading: false,
          projects: projects,
          entriesByDate: grouped,
          selectedDate: today,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onHistoryLoadRequested(
    DsrHistoryLoadRequested event,
    Emitter<DsrState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final myDsr = await getMyDsrUseCase();
      final Map<DateTime, List<DsrEntryEntity>> grouped = <DateTime, List<DsrEntryEntity>>{};
      for (final entry in myDsr) {
        final DateTime key = _dayKey(entry.date);
        grouped.putIfAbsent(key, () => <DsrEntryEntity>[]).add(entry);
      }

      final DateTime? selected = state.selectedDate;
      if (selected != null && state.entriesByDate[selected] != null) {
        grouped[selected] = List<DsrEntryEntity>.from(
          state.entriesByDate[selected]!,
          growable: true,
        );
      }

      emit(state.copyWith(isLoading: false, entriesByDate: grouped));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onDateChanged(
    DsrDateChangedRequested event,
    Emitter<DsrState> emit,
  ) async {
    final DateTime selected = _dayKey(event.date);
    emit(state.copyWith(isLoading: true, selectedDate: selected, clearError: true));
    try {
      final entries = await getDsrByDateUseCase(selected);
      final Map<DateTime, List<DsrEntryEntity>> updated = Map<DateTime, List<DsrEntryEntity>>.from(
        state.entriesByDate,
      );
      updated[selected] = List<DsrEntryEntity>.from(entries, growable: true);
      emit(state.copyWith(isLoading: false, entriesByDate: updated, selectedDate: selected));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    DsrCreateRequested event,
    Emitter<DsrState> emit,
  ) async {
    final DateTime selected = _dayKey(event.date);
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final created = await createDsrUseCase(
        DsrCreateRequestEntity(
          projectId: event.projectId,
          date: selected,
          description: event.description,
          hours: event.hours,
          status: event.status,
        ),
      );

      final Map<DateTime, List<DsrEntryEntity>> updated = Map<DateTime, List<DsrEntryEntity>>.from(
        state.entriesByDate,
      );
      final List<DsrEntryEntity> existing = List<DsrEntryEntity>.from(
        updated[selected] ?? <DsrEntryEntity>[],
        growable: true,
      );
      existing.add(created);
      updated[selected] = existing;

      emit(
        state.copyWith(
          isLoading: false,
          entriesByDate: updated,
          selectedDate: selected,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    DsrUpdateRequested event,
    Emitter<DsrState> emit,
  ) async {
    final DateTime selected = _dayKey(event.date);
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final updatedEntry = await updateDsrUseCase(
        dsrId: event.dsrId,
        description: event.description,
        hours: event.hours,
        status: event.status,
      );

      final Map<DateTime, List<DsrEntryEntity>> updated = <DateTime, List<DsrEntryEntity>>{};
      bool replaced = false;
      for (final entry in state.entriesByDate.entries) {
        final List<DsrEntryEntity> next = List<DsrEntryEntity>.from(entry.value, growable: true);
        final int idx = next.indexWhere((item) => item.id == event.dsrId);
        if (idx != -1) {
          next[idx] = updatedEntry;
          replaced = true;
        }
        updated[entry.key] = next;
      }
      if (!replaced) {
        final List<DsrEntryEntity> fallback = List<DsrEntryEntity>.from(
          updated[selected] ?? <DsrEntryEntity>[],
          growable: true,
        );
        fallback.add(updatedEntry);
        updated[selected] = fallback;
      }

      emit(
        state.copyWith(
          isLoading: false,
          entriesByDate: updated,
          selectedDate: selected,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    DsrDeleteRequested event,
    Emitter<DsrState> emit,
  ) async {
    final DateTime selected = _dayKey(event.date);
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await deleteDsrUseCase(event.dsrId);
      final Map<DateTime, List<DsrEntryEntity>> updated = <DateTime, List<DsrEntryEntity>>{};
      for (final entry in state.entriesByDate.entries) {
        final List<DsrEntryEntity> next = List<DsrEntryEntity>.from(entry.value, growable: true);
        next.removeWhere((item) => item.id == event.dsrId);
        updated[entry.key] = next;
      }

      emit(
        state.copyWith(
          isLoading: false,
          entriesByDate: updated,
          selectedDate: selected,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  DateTime _dayKey(DateTime date) => DateTime(date.year, date.month, date.day);
}
