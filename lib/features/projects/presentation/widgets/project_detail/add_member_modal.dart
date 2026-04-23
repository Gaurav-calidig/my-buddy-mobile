import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/features/auth/domain/entities/user_entity.dart';
import 'package:core/features/projects/presentation/bloc/project_detail_bloc.dart';
import 'package:core/features/projects/presentation/bloc/project_detail_event.dart';
import 'package:core/features/projects/presentation/bloc/project_detail_state.dart';
import 'project_detail_constants.dart';

class AddMemberModal extends StatefulWidget {
  final int projectId;
  final List<String> existingMemberEmails;

  const AddMemberModal({
    super.key,
    required this.projectId,
    this.existingMemberEmails = const [],
  });

  @override
  State<AddMemberModal> createState() => _AddMemberModalState();
}

class _AddMemberModalState extends State<AddMemberModal> {
  final _searchController = TextEditingController();
  String _selectedRole = 'developer';
  UserEntity? _selectedUser;
  String _searchQuery = '';

  final List<String> _roles = [
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
    // Trigger user fetching when modal opens
    context.read<ProjectDetailBloc>().add(const FetchUsers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_selectedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a user')),
      );
      return;
    }

    context.read<ProjectDetailBloc>().add(
          AddProjectMember(
            projectId: widget.projectId,
            username: _selectedUser!.email,
            role: _selectedRole,
          ),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 450),
        decoration: BoxDecoration(
          color: kPanel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorder),
        ),
        child: BlocBuilder<ProjectDetailBloc, ProjectDetailState>(
          builder: (context, state) {
            List<UserEntity> users = [];
            if (state is ProjectDetailLoaded) {
              users = state.users;
            }

            final filteredUsers = users.where((u) {
              // Filter out existing members
              if (widget.existingMemberEmails.contains(u.email)) {
                return false;
              }
              
              final query = _searchQuery.toLowerCase();
              return u.fullName.toLowerCase().contains(query) ||
                  u.email.toLowerCase().contains(query);
            }).toList();

            return Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Add Team Member',
                          style: TextStyle(
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
                      'Select a user and assign them a role in this project.',
                      style: TextStyle(color: kTextMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('User'),
                    _buildSearchField(),
                    const SizedBox(height: 12),
                    if (_searchQuery.isNotEmpty || _selectedUser != null)
                      _selectedUser != null && _searchQuery.isEmpty
                          ? _buildUserTile(_selectedUser!, isSelected: true)
                          : Container(
                              constraints: const BoxConstraints(maxHeight: 200),
                              decoration: BoxDecoration(
                                color: kPanelLight.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: kBorder),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredUsers.length,
                                itemBuilder: (context, index) {
                                  return _buildUserTile(filteredUsers[index]);
                                },
                              ),
                            ),
                    const SizedBox(height: 20),
                    _buildLabel('Role'),
                    _buildRoleDropdown(),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _onSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Add Member',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (v) => setState(() {
        _searchQuery = v;
        if (v.isNotEmpty) _selectedUser = null;
      }),
      style: const TextStyle(color: kTextPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Search users...',
        hintStyle: const TextStyle(color: kTextMuted, fontSize: 13),
        prefixIcon: const Icon(Icons.search, color: kTextMuted, size: 18),
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

  Widget _buildUserTile(UserEntity user, {bool isSelected = false}) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedUser = user;
          _searchQuery = '';
          _searchController.text = user.fullName;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? kAccent.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: isSelected ? BorderRadius.circular(8) : null,
          border: isSelected 
            ? Border.all(color: kBorder)
            : Border(
                bottom: BorderSide(color: kBorder.withValues(alpha: 0.5), width: 0.5),
              ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: kAccent.withValues(alpha: 0.2),
              child: Text(
                user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                style: const TextStyle(color: kAccent, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: const TextStyle(color: kTextPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    user.email,
                    style: const TextStyle(color: kTextMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: kAccent, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: kPanelLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRole,
          isExpanded: true,
          dropdownColor: kPanel,
          icon: const Icon(Icons.keyboard_arrow_down, color: kTextMuted, size: 18),
          items: _roles.map((role) {
            return DropdownMenuItem(
              value: role,
              child: Text(
                role.replaceAll('_', ' ').split(' ').map((s) => s[0].toUpperCase() + s.substring(1)).join(' '),
                style: const TextStyle(color: kTextPrimary, fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: (v) => setState(() => _selectedRole = v!),
        ),
      ),
    );
  }
}
