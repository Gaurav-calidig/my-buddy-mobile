import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/features/projects/domain/entities/project_asset_entity.dart';
import 'package:core/features/projects/presentation/bloc/project_detail_bloc.dart';
import 'package:core/features/projects/presentation/bloc/project_detail_event.dart';
import 'project_detail_constants.dart';
import 'project_detail_common.dart';

class AssetCard extends StatelessWidget {
  final int projectId;
  final ProjectAssetEntity asset;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  const AssetCard({
    super.key,
    required this.projectId,
    required this.asset,
    required this.isExpanded,
    required this.onToggle,
    required this.onEdit,
  });

  bool get _isUrl => asset.type == 'url';

  Future<void> _launch() async {
    final uri = Uri.tryParse(asset.value);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _showDeleteConfirmation(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: ProjectTheme.getPanel(context),
        title: Text('Delete Asset', style: TextStyle(color: ProjectTheme.getTextPrimary(context))),
        content: Text(
          'Are you sure you want to delete this asset?',
          style: TextStyle(color: ProjectTheme.getTextMuted(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: TextStyle(color: ProjectTheme.getTextMuted(context))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ProjectDetailBloc>().add(
                    DeleteProjectAsset(projectId: projectId, assetId: asset.id),
                  );
            },
            child: const Text('Delete', style: TextStyle(color: kDanger)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final panelColor = ProjectTheme.getPanel(context);
    final borderColor = ProjectTheme.getBorder(context);
    final textPrimary = ProjectTheme.getTextPrimary(context);
    final textMuted = ProjectTheme.getTextMuted(context);
    final accentColor = ProjectTheme.getAccent(context);
    final panelLightColor = ProjectTheme.getPanelLight(context);

    return Container(
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // Header Row
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                spacing: 5,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_right,
                        color: textMuted,
                        size: 18,
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _isUrl
                              ? const Color(0xFF0F2A52)
                              : const Color(0xFF1A2A52),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          _isUrl ? Icons.link_rounded : Icons.description_outlined,
                          color: _isUrl ? accentColor : const Color(0xFFAB8BF5),
                          size: 14,
                        ),
                      ),
                      Text(
                        asset.name,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TypeBadge(type: asset.type),
                      EnvBadge(env: asset.environment),
                      if (_isUrl)
                        GestureDetector(
                          onTap: _launch,
                          child: Icon(
                            Icons.open_in_new_rounded,
                            color: textMuted,
                            size: 14,
                          ),
                        ),
                   
                    ],
                  ),
                Row(
                  spacing: 5,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                       IconAction(
                        icon: Icons.copy_rounded,
                        
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: asset.value));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Copied to clipboard'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                      IconAction(
                        icon: Icons.edit_outlined,
                        onTap: onEdit,
                      ),
                      IconAction(
                        icon: Icons.delete_outline_rounded,
                        onTap: () => _showDeleteConfirmation(context),
                        color: kDanger,
                      ),
                  ],
                )
                ],
              ),
            ),
          ),
          // Expanded Content
          if (isExpanded)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: panelLightColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor.withValues(alpha: 0.5)),
              ),
              child: _isUrl
                  ? GestureDetector(
                      onTap: _launch,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              asset.value,
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                                decorationColor: accentColor,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.open_in_new_rounded,
                            color: accentColor,
                            size: 14,
                          ),
                        ],
                      ),
                    )
                  : Text(
                      asset.value,
                      style: TextStyle(
                        color: ProjectTheme.getTextSecondary(context),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}
