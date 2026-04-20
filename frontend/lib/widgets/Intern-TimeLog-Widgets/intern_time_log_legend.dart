import 'package:flutter/material.dart';

class InternTimeLogLegend extends StatelessWidget {
  final bool isDarkMode;

  const InternTimeLogLegend({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final legends = [
      {'label': 'Present', 'color': const Color(0xFF4CAF50)},
      {'label': 'Late', 'color': const Color(0xFFFFA726)},
      {'label': 'Absent', 'color': const Color(0xFFEF5350)},
      {'label': 'Half Day', 'color': const Color(0xFF42A5F5)},
      {'label': 'Weekend/Holiday', 'color': const Color(0xFFAB47BC)},
    ];

    return Row(
      children: [
        Text(
          'Legend:',
          style: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        ...legends.map((item) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: item['color'] as Color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item['label'] as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
