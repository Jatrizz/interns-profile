import 'package:flutter/material.dart';
import '../../utils/responsive.dart';

class RecentTimeLogs extends StatelessWidget {
  final bool isDarkMode;
  final List<Map<String, String>> logs;

  const RecentTimeLogs({
    super.key,
    required this.isDarkMode,
    required this.logs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Time Logs',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black87,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (logs.isEmpty)
            Text(
              'No time logs yet.',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                fontSize: 13,
              ),
            )
          else
            ...logs.map((log) => _LogRow(isDarkMode: isDarkMode, log: log)),
        ],
      ),
    );
  }
}

class _LogRow extends StatelessWidget {
  final bool isDarkMode;
  final Map<String, String> log;

  const _LogRow({required this.isDarkMode, required this.log});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: isMobile
              // mobile: stack date above time row
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log['date'] ?? '',
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[300] : Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${log['timeIn'] ?? '-'}  →  ${log['timeOut'] ?? '-'}',
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _hoursBadge(),
                      ],
                    ),
                  ],
                )
              // desktop: keep side by side
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      log['date'] ?? '',
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[300] : Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${log['timeIn'] ?? '-'}  →  ${log['timeOut'] ?? '-'}',
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 16),
                        _hoursBadge(),
                      ],
                    ),
                  ],
                ),
        ),
        Divider(
          color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
          height: 1,
        ),
      ],
    );
  }

  Widget _hoursBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF00BFFF).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${log['hours'] ?? '0'} hrs',
        style: const TextStyle(
          color: Color(0xFF00BFFF),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
