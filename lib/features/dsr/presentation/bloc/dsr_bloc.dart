import 'package:flutter_bloc/flutter_bloc.dart';

import 'dsr_event.dart';
import 'dsr_state.dart';

class DsrBloc extends Bloc<DsrEvent, DsrState> {
  DsrBloc() : super(const DsrState()) {
    on<DsrInitialLoadRequested>(_onInitialLoad);
  }

  Future<void> _onInitialLoad(
    DsrInitialLoadRequested event,
    Emitter<DsrState> emit,
  ) async {
    emit(state.copyWith(isLoading: false));
  }
}
