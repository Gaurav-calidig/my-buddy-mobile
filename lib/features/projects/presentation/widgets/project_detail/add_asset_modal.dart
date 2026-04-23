import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/features/projects/domain/entities/project_asset_entity.dart';
import 'package:core/features/projects/domain/entities/project_member_entity.dart';
import 'package:core/features/projects/presentation/bloc/project_detail_bloc.dart';
import 'package:core/features/projects/presentation/bloc/project_detail_event.dart';
import 'project_detail_constants.dart';

class AddAssetModal extends StatefulWidget {
  final int projectId;
  final List<ProjectMemberEntity> members;
  final ProjectAssetEntity? asset;

  const AddAssetModal({
    super.key,
    required this.projectId,
    required this.members,
    this.asset,
  });

  @override
  State<AddAssetModal> createState() => _AddAssetModalState();
}

class _AddAssetModalState extends State<AddAssetModal> {
  final _nameController = TextEditingController();
  final _valueController = TextEditingController();
  String _selectedType = 'url';
  String _selectedEnv = 'Production';
  
  final List<String> _selectedRoles = ['admin', 'project_lead'];
  final List<String> _selectedUserIds = [];

  final List<String> _allRoles = [
    'admin',
    'project_lead',
    'client',
    'developer',
    'designer',
    'mobility_dev',
    'bd',
    'qa',
    'hr'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.asset != null) {
      _nameController.text = widget.asset!.name;
      _valueController.text = widget.asset!.value;
      _selectedType = widget.asset!.type;
      _selectedEnv = widget.asset!.environment;
      
      if (widget.asset!.allowedRoles.isNotEmpty) {
        _selectedRoles.clear();
        _selectedRoles.addAll(widget.asset!.allowedRoles.split(','));
      }
      
      if (widget.asset!.allowedUserIds.isNotEmpty) {
        _selectedUserIds.addAll(widget.asset!.allowedUserIds.split(','));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_nameController.text.isEmpty || _valueController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (widget.asset != null) {
      context.read<ProjectDetailBloc>().add(
            UpdateProjectAsset(
              projectId: widget.projectId,
              assetId: widget.asset!.id,
              name: _nameController.text,
              type: _selectedType,
              environment: _selectedEnv,
              value: _valueController.text,
              allowedRoles: _selectedRoles.join(','),
              allowedUserIds: _selectedUserIds.join(','),
            ),
          );
    } else {
      context.read<ProjectDetailBloc>().add(
            AddProjectAsset(
              projectId: widget.projectId,
              name: _nameController.text,
              type: _selectedType,
              environment: _selectedEnv,
              value: _valueController.text,
              allowedRoles: _selectedRoles.join(','),
              allowedUserIds: _selectedUserIds.join(','),
            ),
          );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: kPanel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorder),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.asset != null ? 'Edit Asset' : 'Add New Asset',
                      style: const TextStyle(
                        color: kTextPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: kTextMuted, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Securely store credentials, links, or files for this project.',
                  style: TextStyle(color: kTextMuted, fontSize: 13),
                ),
                const SizedBox(height: 20),
                _buildLabel('Asset Name'),
                _buildTextField(
                  controller: _nameController,
                  hint: 'e.g. AWS Production Keys',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Type'),
                          _buildDropdown(
                            value: _selectedType,
                            items: ['url', 'Credential/Secret', 'File'],
                            onChanged: (v) => setState(() => _selectedType = v!),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Environment'),
                          _buildDropdown(
                            value: _selectedEnv,
                            items: ['Production', 'Staging', 'Dev'],
                            onChanged: (v) => setState(() => _selectedEnv = v!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildLabel('Value'),
                _buildTextField(
                  controller: _valueController,
                  hint: 'Paste your secret, URL, or content here...',
                  maxLines: 4,
                ),
                const SizedBox(height: 20),
                _buildLabel('Role Access'),
                const Text(
                  'Roles that can see this asset by default.',
                  style: TextStyle(color: kTextMuted, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: _allRoles.map((role) {
                    final isSelected = _selectedRoles.contains(role);
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedRoles.remove(role);
                          } else {
                            _selectedRoles.add(role);
                          }
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: isSelected ? kAccent : Colors.transparent,
                              border: Border.all(
                                color: isSelected ? kAccent : kBorder,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white, size: 12)
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            role.replaceAll('_', ' ').split(' ').map((s) => s[0].toUpperCase() + s.substring(1)).join(' '),
                            style: const TextStyle(color: kTextPrimary, fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                _buildLabel('Specific User Access'),
                const Text(
                  'Grant access to specific developers regardless of their role.',
                  style: TextStyle(color: kTextMuted, fontSize: 12),
                ),
                const SizedBox(height: 8),
                if (widget.members.isEmpty)
                  const Text('No members found', style: TextStyle(color: kTextMuted, fontSize: 12))
                else
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kPanelLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: kBorder),
                    ),
                    child: Column(
                      children: widget.members.take(5).map((member) {
                        final user = member.user;
                        final isSelected = _selectedUserIds.contains(user.id);
                        return InkWell(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedUserIds.remove(user.id);
                              } else {
                                _selectedUserIds.add(user.id);
                              }
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: isSelected ? kAccent : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected ? kAccent : kBorder,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: isSelected
                                      ? const Icon(Icons.check, color: Colors.white, size: 12)
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${user.fullName} (${member.role})',
                                  style: const TextStyle(color: kTextPrimary, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      widget.asset != null ? 'Update Asset' : 'Save Asset',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: kTextPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: kTextPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: kTextMuted, fontSize: 13),
        filled: true,
        fillColor: kPanelLight.withValues(alpha: 0.3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kAccent),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: kPanelLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: kPanel,
          icon: const Icon(Icons.keyboard_arrow_down, color: kTextMuted, size: 18),
          items: items.map((i) => DropdownMenuItem(
            value: i,
            child: Text(i, style: const TextStyle(color: kTextPrimary, fontSize: 13)),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
