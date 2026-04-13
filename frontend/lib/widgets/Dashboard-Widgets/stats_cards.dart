import 'package:flutter/material.dart';

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
    return Row(
      children: [
        Expanded(
          child: _buildCard("No. of New Interns", newInterns.toString()),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildCard("Total No. of Interns", totalInterns.toString()),
        ),
        const SizedBox(width: 15),
        Expanded(child: _buildCard("No. of Schools", totalSchools.toString())),
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
        crossAxisAlignment: CrossAxisAlignment.center,
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
