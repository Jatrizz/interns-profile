import 'package:flutter/material.dart';

class TimeLogsOverviewCards extends StatelessWidget {
  final bool isDarkMode;
  final int totalInterns;
  final int presentToday;
  final int lateToday;
  final int absentToday;

  const TimeLogsOverviewCards({
    super.key,
    required this.isDarkMode,
    required this.totalInterns,
    required this.presentToday,
    required this.lateToday,
    required this.absentToday,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildCard('Total Interns', totalInterns),
            const SizedBox(width: 12),
            _buildCard('Present Today', presentToday),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildCard('Late Today', lateToday),
            const SizedBox(width: 12),
            _buildCard('Absent Today', absentToday),
          ],
        ),
      ],
    );
  }

  Widget _buildCard(String label, int value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$value',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
