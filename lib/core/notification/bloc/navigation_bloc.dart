import 'package:flutter_bloc/flutter_bloc.dart';

import 'navigation_event.dart';
import 'navigation_state.dart';

/// Bloc for managing navigation triggered by push notifications.
///
/// Listens for [NotificationNavigationEvent]s and emits [NotificationNavState]s
/// to redirect users to relevant screens based on notification payload data.
class NotificationNavigationBloc
    extends Bloc<NotificationNavigationEvent, NotificationNavState> {
  NotificationNavigationBloc() : super(NotificationNavInitial()) {
    on<SetNavigationFromPayload>(_onSetNavigationFromPayload);
    on<MarkNavigationHandled>(_onMarkNavigationHandled);
  }

  /// Handles notification payload and emits the correct navigation state.
  void _onSetNavigationFromPayload(
      SetNavigationFromPayload event,
      Emitter<NotificationNavState> emit,
      ) {
    final data = event.data;

    if (data['type'] == 'enquiry') {
      emit(NavigateToEnquiryDetails(data['id'].toString()));
    } else if (data['type']?.toString().toLowerCase() == 'paylater') {
      emit(NavigateToPayLaterRequests(data['id'].toString()));
    } else if (data['type'] == 'maintenance') {
      emit(NavigateToMaintenanceDetails(data['id'].toString()));
    } else if (data['type'] == 'payment-reminder') {
      emit(NavigateToPayNow(data['id'].toString()));
    }
  }

  /// Marks navigation as handled and resets state.
  void _onMarkNavigationHandled(
      MarkNavigationHandled event,
      Emitter<NotificationNavState> emit,
      ) {
    emit(NavigationHandled());
  }
}
