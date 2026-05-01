import 'package:core/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:core/features/projects/domain/entities/tech_stack_entity.dart';
import 'project_detail_constants.dart';

class TechGroupCard extends StatelessWidget {
  final String groupName;
  final List<ProjectTechStackEntity> items;
  const TechGroupCard({super.key, required this.groupName, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ProjectTheme.getPanel(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ProjectTheme.getBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: ProjectTheme.getAccent(context),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                groupName,
                style: TextStyle(
                  color: ProjectTheme.getTextSecondary(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map((ts) => TechChip(name: ts.techStack.name))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class TechChip extends StatelessWidget {
  final String name;
  const TechChip({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = ProjectTheme.getAccent(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1E42) : AppColors.kcLightPage,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.4)),
      ),
      child: Text(
        name,
        style: TextStyle(
          color: ProjectTheme.getTextPrimary(context),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
