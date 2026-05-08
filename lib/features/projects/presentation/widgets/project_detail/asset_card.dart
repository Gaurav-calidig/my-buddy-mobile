import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/features/projects/domain/entities/project_asset_entity.dart';
import 'package:core/features/projects/presentation/bloc/project_detail_bloc.dart';
import 'package:core/features/projects/presentation/bloc/project_detail_event.dart';
import 'project_detail_constants.dart';
import 'project_detail_common.dart';

class AssetCard extends StatefulWidget {
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

  @override
  State<AssetCard> createState() => _AssetCardState();
}

class _AssetCardState extends State<AssetCard> {
  bool _isObscured = true;

  bool get _isUrl => widget.asset.type == 'url';
  bool get _isSecret => widget.asset.type == 'Credential/Secret';

  Future<void> _launch() async {
    String url = widget.asset.value;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    final uri = Uri.tryParse(url);
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
                    DeleteProjectAsset(projectId: widget.projectId, assetId: widget.asset.id),
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
            onTap: widget.onToggle,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Icon(
                      widget.isExpanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_right,
                      color: textMuted,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _isUrl
                          ? (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0F2A52) : accentColor.withValues(alpha: 0.1))
                          : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A2A52) : Colors.deepPurple.withValues(alpha: 0.1)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      _isUrl ? Icons.link_rounded : Icons.description_outlined,
                      color: _isUrl 
                          ? accentColor 
                          : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFFAB8BF5) : Colors.deepPurple),
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.asset.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (_isUrl) ...[
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: _launch,
                                child: Icon(
                                  Icons.open_in_new_rounded,
                                  color: textMuted,
                                  size: 14,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            TypeBadge(type: widget.asset.type),
                            EnvBadge(env: widget.asset.environment),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Row(
                    spacing: 5,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconAction(
                        icon: Icons.copy_rounded,
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: widget.asset.value));
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
                        onTap: widget.onEdit,
                      ),
                      IconAction(
                        icon: Icons.delete_outline_rounded,
                        onTap: () => _showDeleteConfirmation(context),
                        color: kDanger,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Expanded Content
          if (widget.isExpanded)
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
                              widget.asset.value,
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
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            _isSecret && _isObscured 
                                ? '•' * widget.asset.value.length 
                                : widget.asset.value,
                            style: TextStyle(
                              color: ProjectTheme.getTextSecondary(context),
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ),
                        if (_isSecret)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isObscured = !_isObscured;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Icon(
                                _isObscured ? Icons.visibility_off : Icons.visibility,
                                color: textMuted,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
        ],
      ),
    );
  }
}
