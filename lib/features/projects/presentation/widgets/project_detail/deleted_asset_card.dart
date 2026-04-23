import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/features/projects/domain/entities/project_asset_entity.dart';
import 'package:core/features/projects/presentation/bloc/project_detail_bloc.dart';
import 'package:core/features/projects/presentation/bloc/project_detail_event.dart';
import 'project_detail_constants.dart';
import 'project_detail_common.dart';

class DeletedAssetCard extends StatelessWidget {
  final int projectId;
  final ProjectAssetEntity asset;
  const DeletedAssetCard({super.key, required this.projectId, required this.asset});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kDangerBg.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kDanger.withValues(alpha: 0.25)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: kDangerBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: kDanger,
              size: 14,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                asset.name,
                style: const TextStyle(
                  color: kTextSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: kTextMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                asset.value,
                style: const TextStyle(color: kTextMuted, fontSize: 11),
              ),
            ],
          ),
          TypeBadge(type: asset.type),
          if (asset.deletedAt != null)
            Text(
              _fmt(asset.deletedAt!),
              style: const TextStyle(color: kDanger, fontSize: 10),
            ),
          IconAction(
            icon: Icons.restore_rounded,
            onTap: () {
              context.read<ProjectDetailBloc>().add(
                    RestoreProjectAsset(projectId: projectId, assetId: asset.id),
                  );
            },
            color: kAccent,
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}
