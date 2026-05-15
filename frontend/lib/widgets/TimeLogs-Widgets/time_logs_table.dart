import 'package:flutter/material.dart';

class TimeLogsTable extends StatelessWidget {
  final bool isDarkMode;
  final List<Map<String, dynamic>> logs;
  final bool showName;
  final bool isSpecificDate;

  const TimeLogsTable({
    super.key,
    required this.isDarkMode,
    required this.logs,
    required this.showName,
    this.isSpecificDate = false,
  });

  static const _minRows = 8;
  static const _rowHeight = 46.0;

  Color _statusColor(String status) {
    switch (status.toLowerCase().trim()) {
      case 'on-time':   return const Color(0xFF4CAF50);
      case 'late':      return const Color(0xFFFFA726);
      case 'absent':    return const Color(0xFFEF5350);
      case 'half-day':
      case 'half day':
      case 'halfday':   return const Color(0xFF42A5F5);
      case 'weekend':
      case 'holiday':   return const Color(0xFFAB47BC);
      default:          return Colors.grey;
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
    final headerBg    = isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFEAEAEA);
    final rowEvenBg   = isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFFAFAFA);
    final rowOddBg    = isDarkMode ? const Color(0xFF252525) : Colors.white;
    final borderColor = isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0);
    final emptyRowBg  = isDarkMode ? const Color(0xFF272727) : const Color(0xFFFDFDFD);
    final headerColor = isDarkMode ? Colors.grey[400]! : Colors.grey[700]!;
    final textColor   = isDarkMode ? Colors.white : Colors.black87;

    final columns = [
      if (showName) ('NAME', 3),
      ('DATE', 2),
      ('DAY', 2),
      ('TIME IN', 2),
      ('TIME OUT', 2),
      ('TOTAL HOURS', 2),
      ('STATUS', 2),
    ];

    Widget headerCell(String text, int flex) => Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Text(
          text,
          style: TextStyle(
            color: headerColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );

    Widget dataCell(String text, int flex) => Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        child: Text(
          text,
          style: TextStyle(color: textColor, fontSize: 13),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );

    Widget statusCell(String status, int flex) {
      final color = _statusColor(status);
      return Expanded(
        flex: flex,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _capitalize(status),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      );
    }

    Widget emptyRow(int index) => Container(
      height: _rowHeight,
      decoration: BoxDecoration(
        color: index.isEven ? rowEvenBg : emptyRowBg,
        border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
      ),
    );

    Widget dataRow(int index) {
      final log = logs[index];
      final bg  = index.isEven ? rowEvenBg : rowOddBg;
      return SizedBox(
        height: _rowHeight,
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
          ),
          child: Row(
            children: [
              if (showName) dataCell(log['name']?.toString() ?? '–', 3),
              dataCell(log['date']?.toString() ?? '–',        2),
              dataCell(log['day']?.toString() ?? '–',         2),
              dataCell(log['time_in']?.toString() ?? '–',     2),
              dataCell(log['time_out']?.toString() ?? '–',    2),
              dataCell(log['total_hours']?.toString() ?? '–', 2),
              statusCell(log['status']?.toString() ?? '',     2),
            ],
          ),
        ),
      );
    }

    final header = Container(
      decoration: BoxDecoration(
        color: headerBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [for (final (col, flex) in columns) headerCell(col, flex)],
      ),
    );

    final bool needsScroll = logs.length > _minRows;
    final int fillerCount  = isSpecificDate ? 0 : _minRows - logs.length;

    Widget body;
    if (logs.isEmpty) {
      body = Column(
        children: [
          SizedBox(
            height: _rowHeight * 2,
            child: Center(
              child: Text(
                'No records found.',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (!isSpecificDate)
            for (int i = 2; i < _minRows; i++) emptyRow(i),
        ],
      );
    } else if (needsScroll) {
      body = SizedBox(
        height: _rowHeight * _minRows,
        child: ListView.builder(
          itemCount: logs.length,
          itemBuilder: (_, i) => dataRow(i),
        ),
      );
    } else {
      body = Column(
        children: [
          for (int i = 0; i < logs.length; i++) dataRow(i),
          for (int i = 0; i < fillerCount; i++) emptyRow(logs.length + i),
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2E2E2E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [header, body],
      ),
    );
  }
}