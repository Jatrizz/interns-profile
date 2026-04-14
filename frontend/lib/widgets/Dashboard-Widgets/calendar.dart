import 'package:flutter/material.dart';

class CalendarWidget extends StatelessWidget {
  final bool isDarkMode;
  final DateTime currentDate;
  final DateTime calendarDate;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const CalendarWidget({
    super.key,
    required this.isDarkMode,
    required this.currentDate,
    required this.calendarDate,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(
      calendarDate.year,
      calendarDate.month,
    );
    final firstWeekday =
        DateTime(calendarDate.year, calendarDate.month, 1).weekday % 7;
    final monthName = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ][calendarDate.month - 1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$monthName ${calendarDate.year}",
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: onPreviousMonth,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.chevron_left,
                      color: isDarkMode ? Colors.white : Colors.black,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: onNextMonth,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.chevron_right,
                      color: isDarkMode ? Colors.white : Colors.black,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Sun', 'Mon', 'Tues', 'Wed', 'Thurs', 'Fri', 'Sat']
              .map(
                (day) => Text(
                  day,
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey : Colors.grey[600],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 5),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemCount: firstWeekday + daysInMonth,
          itemBuilder: (context, index) {
            if (index < firstWeekday) return const SizedBox();
            final day = index - firstWeekday + 1;
            final isToday = day == currentDate.day &&
                calendarDate.month == currentDate.month &&
                calendarDate.year == currentDate.year;
            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isToday ? const Color(0xFF00BFFF) : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "$day",
                style: TextStyle(
                  color: isToday
                      ? Colors.white
                      : (isDarkMode ? Colors.white : Colors.black),
                  fontSize: 11,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
