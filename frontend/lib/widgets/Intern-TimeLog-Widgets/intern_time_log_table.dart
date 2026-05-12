import 'package:flutter/material.dart';
import '../../utils/responsive.dart';

class InternTimeLogTable extends StatelessWidget {
  final bool isDarkMode;
  final List<Map<String, dynamic>> logs;

  const InternTimeLogTable({
    super.key,
    required this.isDarkMode,
    required this.logs,
  });

  Color _statusColor(String status) {
    final normalized = status.toLowerCase().replaceAll(' ', '-');
    switch (normalized) {
      case 'on-time':
        return const Color(0xFF4CAF50);
      case 'late':
        return const Color(0xFFFFA726);
      case 'absent':
        return const Color(0xFFEF5350);
      case 'half-day':
        return const Color(0xFF42A5F5);
      case 'weekend':
        return const Color(0xFFAB47BC);
      default:
        return Colors.grey;
    }
  }

  String _capitalize(String text) {
    final normalized = text.toLowerCase().replaceAll(' ', '-');
    switch (normalized) {
      case 'on-time':
        return 'On Time';
      case 'half-day':
        return 'Half Day';
      case 'weekend':
        return 'Weekend/Holiday';
    }
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final borderColor =
        isDarkMode ? const Color(0xFF333333) : const Color(0xFFE0E0E0);
    final rowColor =
        isDarkMode ? const Color(0xFF242424) : const Color(0xFFF9F9F9);
    final headerColor = isDarkMode ? Colors.grey[400]! : Colors.grey[700]!;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    // fixed min width so table always looks proper
    const double minTableWidth = 600;

    final tableContent = Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // header
          Container(
            width: isMobile ? minTableWidth : null,
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
                _headerCell('DAY', flex: 2, color: headerColor),
                _headerCell('TIME IN', flex: 2, color: headerColor),
                _headerCell('TIME OUT', flex: 2, color: headerColor),
                _headerCell('TOTAL HOURS', flex: 2, color: headerColor),
                _headerCell('STATUS', flex: 2, color: headerColor),
              ],
            ),
          ),
          // rows
          if (logs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text('No records found.',
                    style: TextStyle(color: textColor, fontSize: 14)),
              ),
            )
          else
            ...logs.asMap().entries.map((entry) {
              final index = entry.key;
              final log = entry.value;
              final isLast = index == logs.length - 1;

              return Container(
                width: isMobile ? minTableWidth : null,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: isLast
                      ? null
                      : Border(bottom: BorderSide(color: borderColor)),
                ),
                child: Row(
                  children: [
                    _dataCell(log['date'] ?? '–', flex: 2, color: textColor),
                    _dataCell(log['day'] ?? '–', flex: 2, color: textColor),
                    _dataCell(log['time_in'] ?? '–', flex: 2, color: textColor),
                    _dataCell(log['time_out'] ?? '–',
                        flex: 2, color: textColor),
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
                            _capitalize(log['status'] ?? '–'),
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

    // on mobile wrap in horizontal scroll — same as admin table
    return isMobile
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: tableContent,
          )
        : tableContent;
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
      child: Text(text, style: TextStyle(color: color, fontSize: 13)),
    );
  }
}
