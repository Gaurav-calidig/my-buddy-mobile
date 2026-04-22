import 'package:core/features/dsr/domain/entities/dsr_project_entity.dart';

class DsrProjectModel extends DsrProjectEntity {
  const DsrProjectModel({
    required super.id,
    required super.name,
  });

  factory DsrProjectModel.fromJson(Map<String, dynamic> json) {
    return DsrProjectModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String? ?? '').trim(),
    );
  }
}

