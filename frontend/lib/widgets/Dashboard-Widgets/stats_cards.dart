import 'package:flutter/material.dart';
import '../../utils/responsive.dart';

class StatsCards extends StatelessWidget {
  final bool isDarkMode;
  final int newInterns;
  final int totalInterns;
  final int totalSchools;

  const StatsCards({
    super.key,
    required this.isDarkMode,
    required this.newInterns,
    required this.totalInterns,
    required this.totalSchools,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final cards = [
      _buildCard("No. of New Interns", newInterns.toString()),
      _buildCard("Total No. of Interns", totalInterns.toString()),
      _buildCard("No. of Schools", totalSchools.toString()),
    ];

    return isMobile
        ? Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // ← stretch fills width
            children: [
              cards[0],
              const SizedBox(height: 15),
              cards[1],
              const SizedBox(height: 15),
              cards[2],
            ],
          )
        : Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 15),
              Expanded(child: cards[1]),
              const SizedBox(width: 15),
              Expanded(child: cards[2]),
            ],
          );
  }

  Widget _buildCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2E2E2E) : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // ← same as intern
        children: [
          Text(
            title,
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
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
