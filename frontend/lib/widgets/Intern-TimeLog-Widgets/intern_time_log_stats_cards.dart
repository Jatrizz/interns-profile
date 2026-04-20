import 'package:flutter/material.dart';

class InternTimeLogStatsCards extends StatelessWidget {
  final bool isDarkMode;
  final int totalHours;
  final int remainingHours;
  final int lateArrivals;
  final int absences;

  const InternTimeLogStatsCards({
    super.key,
    required this.isDarkMode,
    required this.totalHours,
    required this.remainingHours,
    required this.lateArrivals,
    required this.absences,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      {'label': 'Total Hours', 'value': totalHours},
      {'label': 'Remaining Hours', 'value': remainingHours},
      {'label': 'Late Arrivals', 'value': lateArrivals},
      {'label': 'Number of Absences', 'value': absences},
    ];

    return Row(
      children: cards.map((card) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF2C2C2C)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card['label'] as String,
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${card['value']}',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
