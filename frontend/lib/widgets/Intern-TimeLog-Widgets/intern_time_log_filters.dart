import 'package:flutter/material.dart';

class InternTimeLogFilters extends StatelessWidget {
  final bool isDarkMode;
  final String selectedMonth;
  final String selectedStatus;
  final String selectedWeek;
  final bool isSpecificDate;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onWeekChanged;
  final ValueChanged<bool> onToggleMode;

  const InternTimeLogFilters({
    super.key,
    required this.isDarkMode,
    required this.selectedMonth,
    required this.selectedStatus,
    required this.selectedWeek,
    required this.isSpecificDate,
    required this.onMonthChanged,
    required this.onStatusChanged,
    required this.onWeekChanged,
    required this.onToggleMode,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Toggle
        Container(
          decoration: BoxDecoration(
            color:
                isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _toggleButton(
                  'Month', !isSpecificDate, () => onToggleMode(false)),
              _toggleButton('Date', isSpecificDate, () => onToggleMode(true)),
            ],
          ),
        ),
        _buildMonthPicker(context),
        _buildLabel('Status'),
        _buildDropdown(
          value: selectedStatus,
          items: ['All', 'Present', 'Late', 'Absent', 'Half Day', 'Weekend'],
          onChanged: onStatusChanged,
        ),
        if (!isSpecificDate) _buildLabel('Week'),
        if (!isSpecificDate)
          _buildDropdown(
            value: selectedWeek,
            items: ['All Weeks', 'Week 1', 'Week 2', 'Week 3', 'Week 4'],
            onChanged: onWeekChanged,
          ),
      ],
    );
  }

  Widget _toggleButton(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF00BFFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive
                ? Colors.white
                : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
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
    return GestureDetector(
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
          onMonthChanged(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFF0F0F0),
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
