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
  static const _mobileRowHeight = 42.0;

  // Below this screen width we switch to fixed-width columns + horizontal scroll
  static const _minTableWidth = 560.0;

  // Fixed column widths for horizontal-scroll mode (with name / without name)
  static const _colWidthsWithName    = [110.0, 70.0, 70.0, 72.0, 72.0, 72.0, 90.0];
  static const _colWidthsWithoutName = [         70.0, 70.0, 72.0, 72.0, 72.0, 90.0];

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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final needsHScroll = screenWidth < _minTableWidth;

    final colWidths = showName ? _colWidthsWithName : _colWidthsWithoutName;

    final headerBg    = isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFEAEAEA);
    final rowEvenBg   = isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFFAFAFA);
    final rowOddBg    = isDarkMode ? const Color(0xFF252525) : Colors.white;
    final borderColor = isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0);
    final emptyRowBg  = isDarkMode ? const Color(0xFF272727) : const Color(0xFFFDFDFD);
    final headerColor = isDarkMode ? Colors.grey[400]! : Colors.grey[700]!;
    final textColor   = isDarkMode ? Colors.white : Colors.black87;

    final rowH = isMobile ? _mobileRowHeight : _rowHeight;
    final hPad = isMobile ? 8.0 : 12.0;
    final fontSize = isMobile ? 11.0 : 13.0;
    final headerFontSize = isMobile ? 10.0 : 12.0;

    // Flex columns for normal mode
    final columns = [
      if (showName) ('NAME', 3),
      ('DATE', 2),
      ('DAY', 2),
      ('TIME IN', 2),
      ('TIME OUT', 2),
      ('TOTAL HRS', 2),
      ('STATUS', 2),
    ];

    // ── Cell builders ────────────────────────────────────────────────────

    Widget headerCell(String text, {int flex = 1, double? width}) {
      final inner = Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: isMobile ? 10 : 14),
        child: Text(
          text,
          style: TextStyle(
            color: headerColor,
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

    Widget dataCell(String text, {int flex = 1, double? width}) {
      final inner = Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: isMobile ? 10 : 13),
        child: Text(
          text,
          style: TextStyle(color: textColor, fontSize: fontSize),
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
              _capitalize(status),
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
      final bg = index.isEven ? rowEvenBg : rowOddBg;

      List<Widget> cells;
      if (needsHScroll) {
        int ci = 0;
        cells = [
          if (showName) dataCell(log['name']?.toString() ?? '–',       width: colWidths[ci++]),
          dataCell(log['date']?.toString() ?? '–',        width: colWidths[ci++]),
          dataCell(log['day']?.toString() ?? '–',         width: colWidths[ci++]),
          dataCell(log['time_in']?.toString() ?? '–',     width: colWidths[ci++]),
          dataCell(log['time_out']?.toString() ?? '–',    width: colWidths[ci++]),
          dataCell(log['total_hours']?.toString() ?? '–', width: colWidths[ci++]),
          statusCell(log['status']?.toString() ?? '',     width: colWidths[ci]),
        ];
      } else {
        cells = [
          if (showName) dataCell(log['name']?.toString() ?? '–',       flex: 3),
          dataCell(log['date']?.toString() ?? '–',        flex: 2),
          dataCell(log['day']?.toString() ?? '–',         flex: 2),
          dataCell(log['time_in']?.toString() ?? '–',     flex: 2),
          dataCell(log['time_out']?.toString() ?? '–',    flex: 2),
          dataCell(log['total_hours']?.toString() ?? '–', flex: 2),
          statusCell(log['status']?.toString() ?? '',     flex: 2),
        ];
      }

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
            ? [
                for (int i = 0; i < columns.length; i++)
                  headerCell(columns[i].$1, width: colWidths[i]),
              ]
            : [
                for (final (col, flex) in columns) headerCell(col, flex: flex),
              ],
      ),
    );

    // ── Body ─────────────────────────────────────────────────────────────

    final bool needsVScroll = logs.length > _minRows;
    final int fillerCount = isSpecificDate ? 0 : (_minRows - logs.length).clamp(0, _minRows);

    Widget body;
    if (logs.isEmpty) {
      body = Column(
        children: [
          SizedBox(
            height: rowH * 2,
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
              itemBuilder: (_, i) => dataRow(i),
            ),
          ),
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
      final tableWidth = colWidths.reduce((a, b) => a + b) + 2;
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