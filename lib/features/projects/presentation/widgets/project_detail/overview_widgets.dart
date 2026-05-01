import 'package:flutter/material.dart';
import 'project_detail_constants.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final List<Widget>? rows;
  final Widget? child;
  const InfoCard({super.key, required this.title, this.rows, this.child});

  @override
  Widget build(BuildContext context) {
    final borderColor = ProjectTheme.getBorder(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ProjectTheme.getPanel(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: ProjectTheme.getTextPrimary(context),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: borderColor, height: 1),
          const SizedBox(height: 12),
          if (rows != null)
            ...rows!.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: r,
                )),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const InfoRow({super.key, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(color: ProjectTheme.getTextMuted(context), fontSize: 13),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? ProjectTheme.getTextPrimary(context),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
