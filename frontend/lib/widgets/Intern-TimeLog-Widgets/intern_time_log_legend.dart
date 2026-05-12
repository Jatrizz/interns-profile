import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class InternTimeLogLegend extends StatelessWidget {
  final bool isDarkMode;
  const InternTimeLogLegend({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(isDarkMode);
    final legends = [
      {'label': 'On Time', 'color': const Color(0xFF4CAF50)},
      {'label': 'Late', 'color': const Color(0xFFFFA726)},
      {'label': 'Absent', 'color': const Color(0xFFEF5350)},
      {'label': 'Half Day', 'color': const Color(0xFF42A5F5)},
      {'label': 'Weekend', 'color': const Color(0xFFAB47BC)},
    ];

    // Wrap handles both mobile and desktop naturally
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Legend:',
          style: TextStyle(
            color: theme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        ...legends.map((item) {
          return Container(
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
          );
        }),
      ],
    );
  }
}
