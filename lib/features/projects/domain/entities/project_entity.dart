import 'package:equatable/equatable.dart';

class ProjectEntity extends Equatable {
  final int id;
  final String name;
  final String description;
  final String prefix;
  final bool isArchived;
  final bool isBillable;
  final String taskMode;
  final DateTime createdAt;
  final int memberCount;
  final int assetCount;

  const ProjectEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.prefix,
    required this.isArchived,
    required this.isBillable,
    required this.taskMode,
    required this.createdAt,
    required this.memberCount,
    required this.assetCount,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    prefix,
    isArchived,
    isBillable,
    taskMode,
    createdAt,
    memberCount,
    assetCount,
  ];
}
