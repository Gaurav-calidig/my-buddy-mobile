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
        color: kPanel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: kAccent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                groupName,
                style: const TextStyle(
                  color: kTextSecondary,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1E42),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kAccent.withValues(alpha: 0.4)),
      ),
      child: Text(
        name,
        style: const TextStyle(
          color: kTextPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
