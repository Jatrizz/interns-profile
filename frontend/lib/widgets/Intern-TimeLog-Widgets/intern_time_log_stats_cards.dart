import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';

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
    final isMobile = Responsive.isMobile(context);
    final theme = AppTheme.of(isDarkMode);

    final cards = [
      {'label': 'Total Hours', 'value': totalHours},
      {'label': 'Remaining Hours', 'value': remainingHours},
      {'label': 'Late Arrivals', 'value': lateArrivals},
      {'label': 'Number of Absences', 'value': absences},
    ];

    Widget buildCard(Map<String, dynamic> card, {bool addMargin = true}) {
      return Container(
        margin: addMargin ? const EdgeInsets.only(right: 12) : EdgeInsets.zero,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: theme.cardBg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: theme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              card['label'] as String,
              style: TextStyle(color: theme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Text(
              '${card['value']}',
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    // mobile: 2x2 grid
    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: buildCard(cards[0])),
              Expanded(child: buildCard(cards[1], addMargin: false)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: buildCard(cards[2])),
              Expanded(child: buildCard(cards[3], addMargin: false)),
            ],
          ),
        ],
      );
    }

    // desktop: single row
    return Row(
      children: cards.asMap().entries.map((e) {
        return Expanded(
            child: buildCard(e.value, addMargin: e.key < cards.length - 1));
      }).toList(),
    );
  }
}
