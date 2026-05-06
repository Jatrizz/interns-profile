import 'package:flutter/material.dart';

class RecentActivity extends StatelessWidget {
  final bool isDarkMode;
  final List<Map<String, dynamic>> activities;

  const RecentActivity({
    super.key,
    required this.isDarkMode,
    required this.activities,
  });

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  String _formatTime(BuildContext context, String? time) {
    if (time == null || time.isEmpty || time == '–') return '';
    try {
      final parsed = DateTime.parse("1970-01-01T$time");
      return TimeOfDay.fromDateTime(parsed).format(context);
    } catch (_) {
      return '';
    }
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return '';
    try {
      final parsed = DateTime.parse(date).toLocal();
      return "${_monthName(parsed.month)} ${parsed.day}";
    } catch (_) {
      return date;
    }
  }

  /// Filter to today only, then expand each log into
  /// separate clock-in and clock-out entries.
  List<Map<String, dynamic>> _todayEntries() {
    final today = DateTime.now();

    final todayLogs = activities.where((a) {
      if (a['log_date'] == null) return false;
      try {
        final d = DateTime.parse(a['log_date']).toLocal();
        return d.year == today.year &&
            d.month == today.month &&
            d.day == today.day;
      } catch (_) {
        return false;
      }
    }).toList();

    final entries = <Map<String, dynamic>>[];
    for (final log in todayLogs) {
      if (log['time_in'] != null &&
          log['time_in'].isNotEmpty &&
          log['time_in'] != '–') {
        entries.add({
          ...log,
          'action': 'clocked in',
          '_display_time': log['time_in'],
        });
      }

      if (log['time_out'] != null &&
          log['time_out'].isNotEmpty &&
          log['time_out'] != '–') {
        entries.add({
          ...log,
          'action': 'clocked out',
          '_display_time': log['time_out'],
        });
      }
    }

    // Sort descending — most recent at the top
    entries.sort((a, b) {
      try {
        final ta = DateTime.parse("1970-01-01T${a['_display_time']}");
        final tb = DateTime.parse("1970-01-01T${b['_display_time']}");
        return tb.compareTo(ta); // reversed: b vs a instead of a vs b
      } catch (_) {
        return 0;
      }
    });

    return entries; // no limit — shows all of today's entries
  }

  @override
  Widget build(BuildContext context) {
    final todayEntries = _todayEntries();
    final dateLabel = _formatDate(DateTime.now().toIso8601String());

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2E2E2E) : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Recent Activity",
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                dateLabel,
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.grey),
          const SizedBox(height: 8),
          todayEntries.isEmpty
              ? Text(
                  "No activity today",
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 13,
                  ),
                )
              : Column(
                  children: todayEntries.map((a) {
                    final isClockedOut = a['action'] == 'clocked out';
                    final timeStr = _formatTime(context, a['_display_time']);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(
                            isClockedOut
                                ? Icons.arrow_circle_up_rounded
                                : Icons.arrow_circle_down_rounded,
                            size: 18,
                            color: isClockedOut
                                ? Colors.orangeAccent
                                : Colors.greenAccent,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: a['name'] ?? '',
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' ${a['action']}',
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                  if (a['status'] != null)
                                    TextSpan(
                                      text: ' · ${a['status']}',
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                  if (timeStr.isNotEmpty)
                                    TextSpan(
                                      text: ' · $timeStr',
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.grey[500]
                                            : Colors.grey[500],
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}
