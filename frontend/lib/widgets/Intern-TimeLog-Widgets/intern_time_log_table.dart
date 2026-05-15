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

  static const _columns = ['DATE', 'DAY', 'TIME IN', 'TIME OUT', 'TOTAL HRS', 'STATUS'];
  static const _minRows = 8;
  static const _rowHeight = 46.0;
  static const _mobileRowHeight = 42.0;

  // Below this screen width we switch to fixed-width columns + horizontal scroll
  static const _minTableWidth = 520.0;

  // Fixed column widths used when horizontal scrolling
  static const _colWidths = [60.0, 90.0, 80.0, 80.0, 80.0, 100.0];

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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final needsHScroll = screenWidth < _minTableWidth;

    final theme = AppTheme.of(isDarkMode);
    final headerBg    = isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFEAEAEA);
    final rowEvenBg   = isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFFAFAFA);
    final rowOddBg    = isDarkMode ? const Color(0xFF252525) : Colors.white;
    final borderColor = isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0);
    final emptyRowBg  = isDarkMode ? const Color(0xFF272727) : const Color(0xFFFDFDFD);

    final rowH = isMobile ? _mobileRowHeight : _rowHeight;
    final hPad = isMobile ? 8.0 : 12.0;
    final fontSize = isMobile ? 11.0 : 13.0;
    final headerFontSize = isMobile ? 10.0 : 12.0;

    const flexes   = [1, 3, 2, 2, 2, 2];
    const centered = [false, true, false, false, false, false];

    // ── Cell builders (support both flex and fixed-width modes) ──────────

    Widget headerCell(String text, {int flex = 1, double? width, bool isCentered = false}) {
      final inner = Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: isMobile ? 10 : 14),
        child: Text(
          text,
          textAlign: isCentered ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            color: theme.textSecondary,
            fontSize: headerFontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      );
      return width != null
          ? SizedBox(width: width, child: inner)
          : Expanded(flex: flex, child: inner);
    }

    Widget dataCell(String text, {int flex = 1, double? width, Color? color, bool isCentered = false}) {
      final inner = Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: isMobile ? 10 : 13),
        child: Text(
          text,
          textAlign: isCentered ? TextAlign.center : TextAlign.start,
          style: TextStyle(color: color ?? theme.textPrimary, fontSize: fontSize),
          overflow: TextOverflow.ellipsis,
        ),
      );
      return width != null
          ? SizedBox(width: width, child: inner)
          : Expanded(flex: flex, child: inner);
    }

    Widget statusCell(String status, {int flex = 1, double? width}) {
      final color = _statusColor(status);
      final inner = Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: isMobile ? 8 : 10),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 8 : 14,
              vertical: isMobile ? 4 : 6,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _formatStatus(status),
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 10 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
      return width != null
          ? SizedBox(width: width, child: inner)
          : Expanded(flex: flex, child: inner);
    }

    // ── Row builders ─────────────────────────────────────────────────────

    Widget emptyRow(int index) => Container(
      height: rowH,
      decoration: BoxDecoration(
        color: index.isEven ? rowEvenBg : emptyRowBg,
        border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
      ),
    );

    Widget dataRow(int index) {
      final log = logs[index];
      final status = log['status']?.toString() ?? '';
      final bg = index.isEven ? rowEvenBg : rowOddBg;
      final cells = needsHScroll
          ? <Widget>[
              dataCell(log['date']?.toString() ?? '-',        width: _colWidths[0]),
              dataCell(log['day']?.toString() ?? '-',         width: _colWidths[1], isCentered: true),
              dataCell(log['time_in']?.toString() ?? '-',     width: _colWidths[2]),
              dataCell(log['time_out']?.toString() ?? '-',    width: _colWidths[3]),
              dataCell(log['total_hours']?.toString() ?? '-', width: _colWidths[4]),
              statusCell(status,                              width: _colWidths[5]),
            ]
          : <Widget>[
              dataCell(log['date']?.toString() ?? '-',        flex: flexes[0]),
              dataCell(log['day']?.toString() ?? '-',         flex: flexes[1], isCentered: true),
              dataCell(log['time_in']?.toString() ?? '-',     flex: flexes[2]),
              dataCell(log['time_out']?.toString() ?? '-',    flex: flexes[3]),
              dataCell(log['total_hours']?.toString() ?? '-', flex: flexes[4]),
              statusCell(status,                              flex: flexes[5]),
            ];
      return SizedBox(
        height: rowH,
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
          ),
          child: Row(children: cells),
        ),
      );
    }

    // ── Header ───────────────────────────────────────────────────────────

    final header = Container(
      decoration: BoxDecoration(
        color: headerBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: needsHScroll
            ? [for (int i = 0; i < _columns.length; i++)
                headerCell(_columns[i], width: _colWidths[i], isCentered: centered[i])]
            : [for (int i = 0; i < _columns.length; i++)
                headerCell(_columns[i], flex: flexes[i], isCentered: centered[i])],
      ),
    );

    // ── Body ─────────────────────────────────────────────────────────────

    final bool needsVScroll = logs.length > _minRows;

    Widget body;
    if (isSpecificDate) {
      body = logs.isEmpty ? emptyRow(0) : dataRow(0);
    } else if (logs.isEmpty) {
      body = Column(
        children: [
          SizedBox(
            height: rowH * 2,
            child: Center(
              child: Text('No records found.',
                  style: TextStyle(color: theme.textSecondary, fontSize: 14)),
            ),
          ),
          for (int i = 2; i < _minRows; i++) emptyRow(i),
        ],
      );
    } else if (needsVScroll) {
      final scrollController = ScrollController();
      body = SizedBox(
        height: rowH * _minRows,
        child: ScrollbarTheme(
          data: ScrollbarThemeData(
            thumbVisibility: WidgetStateProperty.all(true),
            trackVisibility: WidgetStateProperty.all(true),
            thickness: WidgetStateProperty.all(6),
            radius: const Radius.circular(4),
            thumbColor: WidgetStateProperty.all(
              isDarkMode ? const Color(0xFF5C9CFF) : const Color(0xFF2979FF),
            ),
            trackColor: WidgetStateProperty.all(
              isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFDDDDDD),
            ),
            trackBorderColor: WidgetStateProperty.all(Colors.transparent),
          ),
          child: Scrollbar(
            controller: scrollController,
            child: ListView.builder(
              controller: scrollController,
              itemCount: logs.length,
              itemBuilder: (context, index) => dataRow(index),
            ),
          ),
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

    // ── Container ────────────────────────────────────────────────────────

    Widget tableContent = Container(
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

    if (needsHScroll) {
      final tableWidth = _colWidths.reduce((a, b) => a + b) + 2;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(width: tableWidth, child: tableContent),
      );
    }

    // LayoutBuilder: when placed inside a bounded Expanded (old page layout),
    // clamp the table to the available height via ClipRect instead of overflowing.
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.hasBoundedHeight) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox.expand(child: tableContent),
          );
        }
        return tableContent;
      },
    );
  }
}