import 'package:flutter/material.dart';
import 'package:core/features/projects/domain/entities/project_entity.dart';
import 'package:core/features/projects/presentation/widgets/project_detail/project_detail_constants.dart';

class ProjectModal extends StatefulWidget {
  final ProjectEntity? project;
  final Function(String name, String description, bool isBillable) onSave;

  const ProjectModal({
    super.key,
    this.project,
    required this.onSave,
  });

  @override
  State<ProjectModal> createState() => _ProjectModalState();
}

class _ProjectModalState extends State<ProjectModal> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late bool _isBillable;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.project?.description ?? '');
    _isBillable = widget.project?.isBillable ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.project != null;
    final Color bg = ProjectTheme.getPanel(context);
    final Color inputBg = ProjectTheme.getPanelLight(context);
    final Color border = ProjectTheme.getBorder(context);
    final Color textMuted = ProjectTheme.getTextMuted(context);
    final Color textPrimary = ProjectTheme.getTextPrimary(context);

    return Dialog(
      backgroundColor: bg,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Project' : 'Create New Project',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: textMuted, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                isEditing
                    ? 'Update project details in your workspace.'
                    : 'Add a new project to your workspace. You will be assigned as the Admin.',
                style: TextStyle(color: textMuted, fontSize: 13),
              ),
              const SizedBox(height: 24),
              _buildLabel('Project Name', textPrimary),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameController,
                hint: 'e.g. Website Redesign',
                inputBg: inputBg,
                border: border,
                textColor: textPrimary,
                hintColor: textMuted,
              ),
              const SizedBox(height: 20),
              _buildLabel('Description', textPrimary),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _descriptionController,
                hint: 'Brief description of the project...',
                inputBg: inputBg,
                border: border,
                textColor: textPrimary,
                hintColor: textMuted,
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Billable Project',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Mark this project as billable for tracking purposes',
                            style: TextStyle(color: textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isBillable,
                      onChanged: (val) => setState(() => _isBillable = val),
                      activeColor: const Color(0xFF2D75FF),
                      activeTrackColor: const Color(0xFF173A74),
                      inactiveThumbColor: textMuted,
                      inactiveTrackColor: border,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.isNotEmpty) {
                      widget.onSave(
                        _nameController.text,
                        _descriptionController.text,
                        _isBillable,
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D75FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    isEditing ? 'Save Changes' : 'Create Project',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label, Color color) {
    return Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required Color inputBg,
    required Color border,
    required Color textColor,
    required Color hintColor,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: inputBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(color: textColor, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: hintColor, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(12),
        ),
      ),
    );
  }
}
