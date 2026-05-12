import 'package:flutter/material.dart';
import '../../utils/responsive.dart';
import 'intern_calendar.dart';
import 'intern_list.dart';

class InternRightPanel extends StatelessWidget {
  final bool isDarkMode;
  final List<dynamic> interns;
  final DateTime currentDate;
  final DateTime calendarDate;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const InternRightPanel({
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
    // hidden on mobile — parent page handles showing
    // calendar + intern list inline below main content
    if (Responsive.isMobile(context)) return const SizedBox.shrink();

    return Container(
      width: Responsive.value(context,
          mobile: double.infinity, tablet: 240.0, desktop: 300.0),
      color: isDarkMode ? const Color(0xFF242424) : const Color(0xFFF5F5F5),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InternCalendar(
            isDarkMode: isDarkMode,
            currentDate: currentDate,
            calendarDate: calendarDate,
            onPreviousMonth: onPreviousMonth,
            onNextMonth: onNextMonth,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: InternList(
                isDarkMode: isDarkMode,
                interns: interns,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
