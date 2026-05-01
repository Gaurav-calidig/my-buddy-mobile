import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/core/utils/date_time_utils.dart';
import 'package:core/core/theme/date_format_cubit.dart';
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
    final textMuted = ProjectTheme.getTextMuted(context);
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
                style: TextStyle(
                  color: ProjectTheme.getTextSecondary(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                asset.value,
                style: TextStyle(color: textMuted, fontSize: 11),
              ),
            ],
          ),
          TypeBadge(type: asset.type),
          if (asset.deletedAt != null)
            BlocBuilder<DateFormatCubit, String>(
              builder: (context, format) {
                return Text(
                  _fmt(asset.deletedAt!, format),
                  style: const TextStyle(color: kDanger, fontSize: 10),
                );
              },
            ),
          IconAction(
            icon: Icons.restore_rounded,
            onTap: () {
              context.read<ProjectDetailBloc>().add(
                    RestoreProjectAsset(projectId: projectId, assetId: asset.id),
                  );
            },
            color: ProjectTheme.getAccent(context),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime dt, String format) =>
      DateTimeUtils.formatDate(dt, format);
}
