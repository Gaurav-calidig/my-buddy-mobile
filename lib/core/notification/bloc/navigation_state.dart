import 'package:equatable/equatable.dart';

abstract class NotificationNavState extends Equatable {
  const NotificationNavState();

  @override
  List<Object?> get props => [];
}

class NotificationNavInitial extends NotificationNavState {}

class NavigateToEnquiryDetails extends NotificationNavState {
  final String id;
  const NavigateToEnquiryDetails(this.id);

  @override
  List<Object?> get props => [id];
}

class NavigateToPayLaterRequests extends NotificationNavState {
  final String id;
  const NavigateToPayLaterRequests(this.id);

  @override
  List<Object?> get props => [id];
}

class NavigateToMaintenanceDetails extends NotificationNavState {
  final String id;
  const NavigateToMaintenanceDetails(this.id);

  @override
  List<Object?> get props => [id];
}

class NavigateToPayNow extends NotificationNavState {
  final String id;
  const NavigateToPayNow(this.id);

  @override
  List<Object?> get props => [id];
}

class NavigationHandled extends NotificationNavState {}
