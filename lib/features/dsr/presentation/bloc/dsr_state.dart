import 'package:equatable/equatable.dart';

class DsrState extends Equatable {
  const DsrState({this.isLoading = false});

  final bool isLoading;

  DsrState copyWith({bool? isLoading}) {
    return DsrState(isLoading: isLoading ?? this.isLoading);
  }

  @override
  List<Object?> get props => [isLoading];
}
