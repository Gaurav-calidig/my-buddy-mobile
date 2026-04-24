import 'package:equatable/equatable.dart';

class TaskAssigneeEntity extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;

  const TaskAssigneeEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  String get displayName {
    final name = '${firstName.trim()} ${lastName.trim()}'.trim();
    return name.isEmpty ? email : name;
  }

  @override
  List<Object?> get props => [id, firstName, lastName, email];
}

