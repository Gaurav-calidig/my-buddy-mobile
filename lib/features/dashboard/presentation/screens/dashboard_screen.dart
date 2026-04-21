import 'package:core/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: textColor,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 24),
          // Top Row: My Projects, My Assets
          Row(
            children: [
              Expanded(child: _buildSummaryCard('My Projects', '4', Icons.folder_open, cardColor, borderColor, textColor)),
              const SizedBox(width: 16),
              Expanded(child: _buildSummaryCard('My Assets', '5', Icons.devices, cardColor, borderColor, textColor)),
            ],
          ),
          const SizedBox(height: 24),

          // Attendance Section
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month, size: 20, color: AppColors.kcPrimaryColor),
                      const SizedBox(width: 8),
                      Text('Attendance — Upcoming Leaves', style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 16)),
                      const Spacer(),
                      Text('View AMS ->', style: TextStyle(color: textColor, fontSize: 14)),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text('Leave Calendar Grid Placeholder', style: TextStyle(color: Colors.grey.shade500)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // My Daily Status Section
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.assignment, size: 20, color: AppColors.kcPrimaryColor),
                      const SizedBox(width: 8),
                      Text('My Daily Status', style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 16)),
                      const Spacer(),
                      Text('View DSR ->', style: TextStyle(color: textColor, fontSize: 14)),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(child: _buildStatusDsrNode('Today', '0 hrs', cardColor, borderColor, textColor)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatusDsrNode('This Week', '0 hrs', cardColor, borderColor, textColor)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatusDsrNode('Blocked', '0', cardColor, borderColor, textColor)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.access_time, color: Colors.grey, size: 20),
                        const SizedBox(height: 8),
                        Text('No entries this week yet', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String count, IconData icon, Color bgColor, Color borderColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.kcPrimaryColor),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Text(count, style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatusDsrNode(String label, String value, Color bgColor, Color borderColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
