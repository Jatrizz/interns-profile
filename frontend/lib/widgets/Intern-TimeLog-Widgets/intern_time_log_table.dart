import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class InternTimeLogTable extends StatelessWidget {
  final bool isDarkMode;
  final List<Map<String, dynamic>> logs;
  final bool isSpecificDate;

  const InternTimeLogTable({
    super.key,
    required this.isDarkMode,
    required this.logs,
    this.isSpecificDate = false,
  });

  static const _columns = ['DATE', 'DAY', 'TIME IN', 'TIME OUT', 'TOTAL HOURS', 'STATUS'];
  static const _minRows = 8;
  static const _rowHeight = 46.0;

  Color _statusColor(String status) {
    switch (status.toLowerCase().trim()) {
      case 'on-time':   return const Color(0xFF4CAF50);
      case 'late':      return const Color(0xFFFFA726);
      case 'half-day':
      case 'halfday':
      case 'half day':  return const Color(0xFF42A5F5);
      case 'absent':    return const Color(0xFFEF5350);
      case 'weekend':
      case 'holiday':   return const Color(0xFFAB47BC);
      default:          return Colors.grey;
    }
  }

  String _formatStatus(String status) {
    final n = status.toLowerCase().trim();
    if (n == 'on-time') return 'On Time';
    if (n == 'half-day' || n == 'halfday' || n == 'half day') return 'Half Day';
    if (status.isEmpty) return status;
    return status[0].toUpperCase() + status.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(isDarkMode);
    final headerBg    = isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFEAEAEA);
    final rowEvenBg   = isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFFAFAFA);
    final rowOddBg    = isDarkMode ? const Color(0xFF252525) : Colors.white;
    final borderColor = isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0);
    final emptyRowBg  = isDarkMode ? const Color(0xFF272727) : const Color(0xFFFDFDFD);

    const flexes  = [1, 3, 2, 2, 2, 2];
    const centered = [false, true, false, false, false, false];

    final bool needsScroll = logs.length > _minRows;

    Widget headerCell(String text, int flex, {bool isCentered = false}) => Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Text(
          text,
          textAlign: isCentered ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            color: theme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );

    Widget dataCell(String text, int flex, {Color? color, bool isCentered = false}) => Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        child: Text(
          text,
          textAlign: isCentered ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            color: color ?? theme.textPrimary,
            fontSize: 13,
          ),
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
                _formatStatus(status),
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

    // A blank filler row to pad up to _minRows
    Widget emptyRow(int index) => Container(
      height: _rowHeight,
      decoration: BoxDecoration(
        color: index.isEven ? rowEvenBg : emptyRowBg,
        border: Border(
          bottom: BorderSide(color: borderColor, width: 0.5),
        ),
      ),
    );

    // The actual data row
    Widget dataRow(int index) {
      final log = logs[index];
      final status = log['status']?.toString() ?? '';
      final bg = index.isEven ? rowEvenBg : rowOddBg;
      return SizedBox(
        height: _rowHeight,
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            border: Border(
              bottom: BorderSide(color: borderColor, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              dataCell(log['date']?.toString() ?? '-',        flexes[0]),
              dataCell(log['day']?.toString() ?? '-',         flexes[1], isCentered: true),
              dataCell(log['time_in']?.toString() ?? '-',     flexes[2]),
              dataCell(log['time_out']?.toString() ?? '-',    flexes[3]),
              dataCell(log['total_hours']?.toString() ?? '-', flexes[4]),
              statusCell(status,                              flexes[5]),
            ],
          ),
        ),
      );
    }

    // Fixed header widget
    final header = Container(
      decoration: BoxDecoration(
        color: headerBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          for (int i = 0; i < _columns.length; i++)
            headerCell(_columns[i], flexes[i], isCentered: centered[i]),
        ],
      ),
    );

    // Body: scrollable if > 8 rows, fixed height with fillers if <= 8
    Widget body;

    if (isSpecificDate) {
      body = logs.isEmpty ? emptyRow(0) : dataRow(0);
    }
    else if (logs.isEmpty) {
      body = Column(
        children: [
          SizedBox(
            height: _rowHeight * 2,
            child: Center(
              child: Text(
                'No records found.',
                style: TextStyle(color: theme.textSecondary, fontSize: 14),
              ),
            ),
          ),
          for (int i = 2; i < _minRows; i++) emptyRow(i),
        ],
      );
    } else if (needsScroll) {
      body = SizedBox(
        height: _rowHeight * _minRows,
        child: ListView.builder(
          itemCount: logs.length,
          itemBuilder: (context, index) => dataRow(index),
        ),
      );
    } else {
      final fillerCount = _minRows - logs.length;
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
        children: [
          header,
          body,
        ],
      ),
    );
  }
}