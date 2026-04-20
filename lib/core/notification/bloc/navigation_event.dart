import 'package:equatable/equatable.dart';

/// Base class for all notification navigation events.
abstract class NotificationNavigationEvent extends Equatable {
  const NotificationNavigationEvent();

  @override
  List<Object?> get props => [];
}

/// Event for processing a notification payload.
class SetNavigationFromPayload extends NotificationNavigationEvent {
  final Map<String, dynamic> data;

  const SetNavigationFromPayload(this.data);

  @override
  List<Object?> get props => [data];
}

/// Event for marking navigation as handled.
class MarkNavigationHandled extends NotificationNavigationEvent {
  const MarkNavigationHandled();
}
