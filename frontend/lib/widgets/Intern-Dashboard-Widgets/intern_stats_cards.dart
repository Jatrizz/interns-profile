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
            value: _capitalize(todayStatus),
            isLarge: true,
            statusColor: _statusColor(todayStatus),
          ),
        ),
      ],
    );
  }

  Color _statusColor(String status) {
    final normalized = status.toLowerCase().trim();
    switch (normalized) {
      case 'on-time':
        return const Color(0xFF4CAF50);
      case 'late':
        return const Color(0xFFFFA726);
      case 'half-day':
      case 'halfday':
      case 'half day':
        return const Color(0xFF42A5F5);
      case 'absent':
        return const Color(0xFFEF5350);
      case 'weekend':
      case 'holiday':
        return const Color(0xFFAB47BC);
      default:
        return Colors.grey;
    }
  }

  String _capitalize(String text) {
  final normalized = text.toLowerCase().trim();
  if (normalized == 'on-time') return 'On Time';
  if (normalized == 'half-day' || 
      normalized == 'halfday' || 
      normalized == 'half day') return 'Half Day';
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            textAlign: TextAlign.center,
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
