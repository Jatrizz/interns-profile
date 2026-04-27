import 'package:flutter/material.dart';

class TimeLogsFilters extends StatelessWidget {
  final bool isDarkMode;
  final String selectedMonth;
  final String selectedStatus;
  final String selectedWeek;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onWeekChanged;
  final bool isSpecificDate;
  final ValueChanged<bool> onToggleMode;

  const TimeLogsFilters({
    super.key,
    required this.isDarkMode,
    required this.selectedMonth,
    required this.selectedStatus,
    required this.selectedWeek,
    required this.onMonthChanged,
    required this.onStatusChanged,
    required this.onWeekChanged,
    required this.isSpecificDate,
    required this.onToggleMode,
  });

  static const List<String> _months = [
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

  DateTime? get _parsedDate {
    final parts = selectedMonth.split(' ');
    if (parts.length == 3) {
      final month = _months.indexOf(parts[0]) + 1;
      final day = int.tryParse(parts[1].replaceAll(',', ''));
      final year = int.tryParse(parts[2]);
      if (month > 0 && day != null && year != null) {
        return DateTime(year, month, day);
      }
    } else if (parts.length == 2) {
      final month = _months.indexOf(parts[0]) + 1;
      final year = int.tryParse(parts[1]);
      if (month > 0 && year != null) {
        return DateTime(year, month);
      }
    }
    return null;
  }

  DateTime get _initialDate {
    final parts = selectedMonth.split(' ');
    if (parts.length == 3) {
      final month = _months.indexOf(parts[0]) + 1;
      final day =
          int.tryParse(parts[1].replaceAll(',', '')) ?? DateTime.now().day;
      final year = int.tryParse(parts[2]) ?? DateTime.now().year;
      return DateTime(year, month, day);
    }
    return DateTime.now();
  }

  void _adjustDate(int direction) {
    final current = _parsedDate ?? DateTime.now();
    final DateTime adjusted;
    if (isSpecificDate) {
      adjusted = current.add(Duration(days: direction));
    } else {
      adjusted = DateTime(current.year, current.month + direction);
    }
    onMonthChanged(adjusted);
  }

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
              _toggleButton('Date', isSpecificDate, () => onToggleMode(true)),
              _toggleButton(
                  'Month', !isSpecificDate, () => onToggleMode(false)),
            ],
          ),
        ),
        _buildDatePicker(context),
        _buildLabel('Status'),
        _buildDropdown(
          value: selectedStatus,
          items: [
            'All',
            'Present',
            'On Time',
            'Late',
            'Absent',
            'Half Day',
            'Weekend'
          ],
          onChanged: onStatusChanged,
        ),
        if (!isSpecificDate) ...[
          _buildLabel('Week'),
          _buildDropdown(
            value: selectedWeek,
            items: ['All Weeks', 'Week 1', 'Week 2', 'Week 3', 'Week 4'],
            onChanged: onWeekChanged,
          ),
        ],
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

  Widget _buildDatePicker(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _navArrow(Icons.chevron_left, () => _adjustDate(-1)),
        _buildDatePickerButton(context),
        _navArrow(Icons.chevron_right, () => _adjustDate(1)),
      ],
    );
  }

  Widget _navArrow(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Icon(
          icon,
          size: 18,
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildDatePickerButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked;
        if (isSpecificDate) {
          picked = await showDatePicker(
            context: context,
            initialDate: _initialDate,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            initialEntryMode: DatePickerEntryMode.calendarOnly,
            builder: (context, child) => Theme(
              data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
              child: child!,
            ),
          );
        } else {
          picked = await _showMonthPickerDialog(context);
        }
        if (picked != null) {
          onMonthChanged(picked);
        }
      },
      child: Container(
        width: 170,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                selectedMonth,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSpecificDate ? Icons.calendar_month : Icons.calendar_today,
              size: 16,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Future<DateTime?> _showMonthPickerDialog(BuildContext context) async {
    int selectedYear = DateTime.now().year;
    int selectedMonthIndex = DateTime.now().month - 1;

    final parts = selectedMonth.split(' ');
    if (parts.isNotEmpty) {
      final idx = _months.indexOf(parts[0]);
      if (idx != -1) selectedMonthIndex = idx;
    }
    if (parts.isNotEmpty) {
      selectedYear = int.tryParse(parts.last) ?? selectedYear;
    }

    return showDialog<DateTime>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor:
                  isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
              contentPadding: const EdgeInsets.all(16),
              content: SizedBox(
                width: 320,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Year navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.chevron_left,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          onPressed: () => setDialogState(() => selectedYear--),
                        ),
                        Text(
                          '$selectedYear',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.chevron_right,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          onPressed: () => setDialogState(() => selectedYear++),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Month grid
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      childAspectRatio: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      children: List.generate(12, (index) {
                        final isSelected = index == selectedMonthIndex;
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(
                              context,
                              DateTime(selectedYear, index + 1),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF00BFFF)
                                  : (isDarkMode
                                      ? const Color(0xFF3A3A3A)
                                      : const Color(0xFFF0F0F0)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _months[index].substring(0, 3),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : (isDarkMode
                                        ? Colors.white
                                        : Colors.black),
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
