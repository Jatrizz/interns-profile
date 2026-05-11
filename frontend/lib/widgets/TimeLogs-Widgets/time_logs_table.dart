import 'package:flutter/material.dart';
import '../../utils/responsive.dart';

class TimeLogsTable extends StatelessWidget {
  final bool isDarkMode;
  final List<Map<String, dynamic>> logs;
  final bool showName;

  const TimeLogsTable({
    super.key,
    required this.isDarkMode,
    required this.logs,
    required this.showName,
  });

  Color _statusColor(String status) {
    switch (status.toLowerCase().trim()) {
      case 'on-time':
        return const Color(0xFF4CAF50);
      case 'late':
        return const Color(0xFFFFA726);
      case 'absent':
        return const Color(0xFFEF5350);
      case 'half-day':
      case 'half day':
      case 'halfday':
        return const Color(0xFF42A5F5);
      case 'weekend':
      case 'holiday':
        return const Color(0xFFAB47BC);
      default:
        return Colors.grey;
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    if (text.toLowerCase() == 'on-time') return 'On Time';
    if (text.toLowerCase() == 'half-day' ||
        text.toLowerCase() == 'halfday' ||
        text.toLowerCase() == 'half day') return 'Half Day';
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    final headerColor = isDarkMode ? Colors.grey[400]! : Colors.grey[700]!;
    final borderColor =
        isDarkMode ? const Color(0xFF333333) : const Color(0xFFE0E0E0);
    final rowBg =
        isDarkMode ? const Color(0xFF242424) : const Color(0xFFF9F9F9);
    final textColor = isDarkMode ? Colors.white : Colors.black;

    final tableContent = Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: isMobile ? 700 : null,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: rowBg,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: [
                if (showName) _headerCell('NAME', flex: 3, color: headerColor),
                _headerCell('DATE', flex: 2, color: headerColor),
                _headerCell('DAY', flex: 2, color: headerColor),
                _headerCell('TIME IN', flex: 2, color: headerColor),
                _headerCell('TIME OUT', flex: 2, color: headerColor),
                _headerCell('TOTAL HOURS', flex: 2, color: headerColor),
                _headerCell('STATUS', flex: 2, color: headerColor),
              ],
            ),
          ),

          // Rows
          if (logs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No records found.',
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ...logs.asMap().entries.map((entry) {
              final index = entry.key;
              final log = entry.value;
              final isLast = index == logs.length - 1;

              return Container(
                width: isMobile ? 700 : null,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: isLast
                      ? null
                      : Border(bottom: BorderSide(color: borderColor)),
                ),
                child: Row(
                  children: [
                    if (showName)
                      _dataCell(log['name'] ?? '–', flex: 3, color: textColor),
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
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 13),
      ),
    );
  }
}
