import 'package:flutter/material.dart';

class InternTimeLogFilters extends StatelessWidget {
  final bool isDarkMode;
  final String selectedMonth;
  final String selectedStatus;
  final String selectedWeek;
  final ValueChanged<String> onMonthChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onWeekChanged;

  const InternTimeLogFilters({
    super.key,
    required this.isDarkMode,
    required this.selectedMonth,
    required this.selectedStatus,
    required this.selectedWeek,
    required this.onMonthChanged,
    required this.onStatusChanged,
    required this.onWeekChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildMonthPicker(context),
        const SizedBox(width: 24),
        _buildLabel('Status'),
        const SizedBox(width: 8),
        _buildDropdown(
          value: selectedStatus,
          items: ['All', 'Present', 'Late', 'Absent', 'Half Day', 'Weekend'],
          onChanged: onStatusChanged,
        ),
        const SizedBox(width: 24),
        _buildLabel('Week'),
        const SizedBox(width: 8),
        _buildDropdown(
          value: selectedWeek,
          items: ['All Weeks', 'Week 1', 'Week 2', 'Week 3', 'Week 4'],
          onChanged: onWeekChanged,
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildMonthPicker(BuildContext context) {
    return Row(
      children: [
        _buildLabel('Month'),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: now,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              initialEntryMode: DatePickerEntryMode.calendarOnly,
              builder: (context, child) => Theme(
                data: ThemeData.dark(),
                child: child!,
              ),
            );
            if (picked != null) {
              final months = [
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
                'December'
              ];
              onMonthChanged('${months[picked.month - 1]} ${picked.year}');
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF2C2C2C)
                  : const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedMonth,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 14,
          ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    );
  }
}
