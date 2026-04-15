import 'package:flutter/material.dart';

class InternStatsCards extends StatelessWidget {
  final bool isDarkMode;
  final double totalHoursRendered;
  final double remainingHours;
  final String todayStatus; // e.g. "On-time", "Late", "Absent"

  const InternStatsCards({
    super.key,
    required this.isDarkMode,
    required this.totalHoursRendered,
    required this.remainingHours,
    required this.todayStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            isDarkMode: isDarkMode,
            label: 'Total Hours Rendered',
            value: totalHoursRendered.toStringAsFixed(0),
            isLarge: false,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            isDarkMode: isDarkMode,
            label: 'Remaining Hours',
            value: remainingHours.toStringAsFixed(0),
            isLarge: false,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            isDarkMode: isDarkMode,
            label: "Today's Status",
            value: todayStatus,
            isLarge: true,
            statusColor: _statusColor(todayStatus),
          ),
        ),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'on-time':
        return Colors.white;
      case 'late':
        return Colors.orangeAccent;
      case 'absent':
        return Colors.redAccent;
      default:
        return Colors.white70;
    }
  }
}

class _StatCard extends StatelessWidget {
  final bool isDarkMode;
  final String label;
  final String value;
  final bool isLarge;
  final Color? statusColor;

  const _StatCard({
    required this.isDarkMode,
    required this.label,
    required this.value,
    required this.isLarge,
    this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2E2E2E) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color:
                  statusColor ?? (isDarkMode ? Colors.white : Colors.black87),
              fontSize: isLarge ? 28 : 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
