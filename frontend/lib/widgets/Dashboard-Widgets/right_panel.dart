import 'package:flutter/material.dart';
import 'calendar.dart';
import 'dahsboard_intern_list.dart';

class RightPanel extends StatelessWidget {
  final bool isDarkMode;
  final List<dynamic> interns;
  final DateTime currentDate;
  final DateTime calendarDate;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const RightPanel({
    super.key,
    required this.isDarkMode,
    required this.interns,
    required this.currentDate,
    required this.calendarDate,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      color: isDarkMode ? const Color(0xFF242424) : const Color(0xFFF5F5F5),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CalendarWidget(
            isDarkMode: isDarkMode,
            currentDate: currentDate,
            calendarDate: calendarDate,
            onPreviousMonth: onPreviousMonth,
            onNextMonth: onNextMonth,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child:
                  DahsboardInternList(isDarkMode: isDarkMode, interns: interns),
            ),
          ),
        ],
      ),
    );
  }
}
