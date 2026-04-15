import 'package:flutter/material.dart';

class InternWeeklyChart extends StatelessWidget {
  final bool isDarkMode;
  // Map of day label to hours worked, e.g. {'Mon': 8.0, 'Tue': 3.0, ...}
  final Map<String, double> weeklyData;

  const InternWeeklyChart({
    super.key,
    required this.isDarkMode,
    required this.weeklyData,
  });

  @override
  Widget build(BuildContext context) {
    final days = ['Mon', 'Tue', 'Wed', 'Thurs', 'Fri'];
    final maxHours = weeklyData.values.fold(0.0, (a, b) => a > b ? a : b);
    final chartMax = maxHours < 8 ? 8.0 : (maxHours * 1.2).ceilToDouble();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF242424) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Hours',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black87,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Y-axis labels
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (i) {
                    final val = (chartMax - i * (chartMax / 4)).round();
                    return Text(
                      '$val',
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                        fontSize: 11,
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 8),
                // Bars
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: days.map((day) {
                      final hours = weeklyData[day] ?? 0.0;
                      final fraction = chartMax > 0 ? hours / chartMax : 0.0;
                      return _Bar(
                        isDarkMode: isDarkMode,
                        fraction: fraction,
                        label: day,
                        hours: hours,
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final bool isDarkMode;
  final double fraction;
  final String label;
  final double hours;

  const _Bar({
    required this.isDarkMode,
    required this.fraction,
    required this.label,
    required this.hours,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Tooltip on hover via Tooltip widget
        Tooltip(
          message: '${hours.toStringAsFixed(1)} hrs',
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            width: 32,
            height: 140 * fraction,
            decoration: BoxDecoration(
              color: const Color(0xFF00BFFF),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
