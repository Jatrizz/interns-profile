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
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCard('Total Interns', totalInterns),
              const SizedBox(width: 12),
              _buildCard('Present Today', presentToday),
            ],
          ),
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCard('Late Today', lateToday),
              const SizedBox(width: 12),
              _buildCard('Absent Today', absentToday),
            ],
          ),
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$value',
              textAlign: TextAlign.center,
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
