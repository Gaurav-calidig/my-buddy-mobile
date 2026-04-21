import 'package:core/features/dsr/presentation/models/dsr_entry.dart';
import 'package:flutter/material.dart';

class DsrTodayEntryTile extends StatelessWidget {
  const DsrTodayEntryTile({required this.entry, super.key});

  final DsrEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1A34),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF334A71)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  entry.project,
                  style: const TextStyle(color: Color(0xFFE7F0FF), fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.description.isEmpty ? 'No description provided.' : entry.description,
                  style: const TextStyle(color: Color(0xFF9CB1D8), fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                '${entry.hours.toStringAsFixed(1)}h',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                entry.status,
                style: const TextStyle(
                  color: Color(0xFF8AA5D7),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
