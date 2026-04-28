import 'package:flutter/material.dart';

class InternList extends StatelessWidget {
  final bool isDarkMode;
  final List<dynamic> interns;

  const InternList(
      {super.key, required this.isDarkMode, required this.interns});

  Color _statusColor(String status) {
    final normalized = status.toLowerCase().trim();

    switch (normalized) {
      case 'on-time':
        return const Color(0xFF4CAF50);
      case 'late':
        return const Color(0xFFFFA726);
      case 'absent':
        return const Color(0xFFEF5350);
      case 'half-day':
      case 'halfday':
      case 'half day':
        return const Color(0xFF42A5F5);
      case 'weekend':
      case 'holiday':
        return const Color(0xFFAB47BC);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Interns",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color:
                isDarkMode ? const Color(0xFF2E2E2E) : const Color(0xFFE8E8E8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: interns.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(15),
                  child: Text(
                    "No interns found",
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey : Colors.grey[600],
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: interns.length,
                  separatorBuilder: (_, __) => Divider(
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final intern = interns[index];
                    final status = intern['status'] ?? 'absent';
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "${index + 1}. ${intern['first_name']} ${intern['last_name']}",
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _statusColor(status),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
