import 'package:flutter/material.dart';

class BarChart extends StatelessWidget {
  final bool isDarkMode;
  final List<Map<String, dynamic>> yearlyStats;

  const BarChart({
    super.key,
    required this.isDarkMode,
    required this.yearlyStats,
  });

  @override
  Widget build(BuildContext context) {
    final schools = ['PLSP', 'CMDI', 'LSPU', 'OTHERS'];
    final schoolColors = [
      const Color(0xFF00BFFF),
      const Color(0xFF7B61FF),
      const Color(0xFF00D084),
      const Color(0xFFFF6B6B),
    ];

    if (yearlyStats.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2E2E2E) : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    int maxCount = 0;
    for (var year in yearlyStats) {
      for (var school in schools) {
        final val = (year[school] as int?) ?? 0;
        if (val > maxCount) maxCount = val;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2E2E2E) : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Interns per Year by School",
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 5),
          Wrap(
            spacing: 15,
            children: List.generate(schools.length, (i) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: schoolColors[i],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    schools[i],
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 220,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    6,
                    (i) => Text(
                      "${((maxCount / 5) * (5 - i)).round()}",
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey : Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: yearlyStats.map((yearData) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(schools.length, (si) {
                              final count =
                                  (yearData[schools[si]] as int?) ?? 0;
                              final barHeight = maxCount > 0
                                  ? (count / maxCount) * 170.0
                                  : 0.0;
                              return Container(
                                width: 12,
                                height: barHeight,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                  color: schoolColors[si],
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(3),
                                    topRight: Radius.circular(3),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            yearData['year'] as String,
                            style: TextStyle(
                              color:
                                  isDarkMode ? Colors.grey : Colors.grey[600],
                              fontSize: 11,
                            ),
                          ),
                        ],
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
