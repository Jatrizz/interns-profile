import 'package:flutter/material.dart';

class InternTimeLogTable extends StatelessWidget {
  final bool isDarkMode;
  final List<Map<String, dynamic>> logs;

  const InternTimeLogTable({
    super.key,
    required this.isDarkMode,
    required this.logs,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'Present':
        return const Color(0xFF4CAF50);
      case 'Late':
        return const Color(0xFFFFA726);
      case 'Absent':
        return const Color(0xFFEF5350);
      case 'Half Day':
        return const Color(0xFF42A5F5);
      case 'Weekend':
        return const Color(0xFFAB47BC);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerColor = isDarkMode ? Colors.grey[400]! : Colors.grey[700]!;
    final rowColor =
        isDarkMode ? const Color(0xFF242424) : const Color(0xFFF9F9F9);
    final borderColor =
        isDarkMode ? const Color(0xFF333333) : const Color(0xFFE0E0E0);
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // Header Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: rowColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: [
                _headerCell('DATE', flex: 2, color: headerColor),
                _headerCell('DAY', flex: 1, color: headerColor),
                _headerCell('TIME IN', flex: 2, color: headerColor),
                _headerCell('TIME OUT', flex: 2, color: headerColor),
                _headerCell('TOTAL HOURS', flex: 2, color: headerColor),
                _headerCell('STATUS', flex: 2, color: headerColor),
              ],
            ),
          ),
          // Data Rows
          ...logs.asMap().entries.map((entry) {
            final index = entry.key;
            final log = entry.value;
            final isLast = index == logs.length - 1;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(bottom: BorderSide(color: borderColor)),
              ),
              child: Row(
                children: [
                  _dataCell(log['date'] ?? '–', flex: 2, color: textColor),
                  _dataCell(log['day'] ?? '–', flex: 1, color: textColor),
                  _dataCell(log['time_in'] ?? '–', flex: 2, color: textColor),
                  _dataCell(log['time_out'] ?? '–', flex: 2, color: textColor),
                  _dataCell(log['total_hours'] ?? '–',
                      flex: 2, color: textColor),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: _statusColor(log['status'] ?? ''),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          log['status'] ?? '–',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _headerCell(String text, {required int flex, required Color color}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _dataCell(String text, {required int flex, required Color color}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 13),
      ),
    );
  }
}
