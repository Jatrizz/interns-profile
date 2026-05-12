import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';

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
      if (month > 0 && year != null) return DateTime(year, month);
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
    final DateTime adjusted = isSpecificDate
        ? current.add(Duration(days: direction))
        : DateTime(current.year, current.month + direction);
    onMonthChanged(adjusted);
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(isDarkMode);

    // Wrap handles both mobile and desktop —
    // on narrow screens filters naturally wrap to next line
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Month / Date toggle
        Container(
          decoration: BoxDecoration(
            color: theme.cardInnerBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.divider),
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

        _buildDatePicker(context, theme),

        _buildLabel('Status', theme),
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
          theme: theme,
        ),

        if (!isSpecificDate) ...[
          _buildLabel('Week', theme),
          _buildDropdown(
            value: selectedWeek,
            items: ['All Weeks', 'Week 1', 'Week 2', 'Week 3', 'Week 4'],
            onChanged: onWeekChanged,
            theme: theme,
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
          color: isActive ? AppTheme.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            color:
                isActive ? Colors.white : AppTheme.of(isDarkMode).textSecondary,
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, AppTheme theme) {
    return Text(
      text,
      style: TextStyle(
        color: theme.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, AppTheme theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _navArrow(Icons.chevron_left, () => _adjustDate(-1), theme),
        _buildDatePickerButton(context, theme),
        _navArrow(Icons.chevron_right, () => _adjustDate(1), theme),
      ],
    );
  }

  Widget _navArrow(IconData icon, VoidCallback onTap, AppTheme theme) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Icon(icon, size: 18, color: theme.iconMuted),
      ),
    );
  }

  Widget _buildDatePickerButton(BuildContext context, AppTheme theme) {
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
          picked = await _showMonthPickerDialog(context, theme);
        }
        if (picked != null) onMonthChanged(picked);
      },
      child: Container(
        width: 170,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.cardInnerBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.divider),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                selectedMonth,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: theme.textPrimary, fontSize: 14),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSpecificDate ? Icons.calendar_month : Icons.calendar_today,
              size: 16,
              color: theme.iconMuted,
            ),
          ],
        ),
      ),
    );
  }

  Future<DateTime?> _showMonthPickerDialog(
      BuildContext context, AppTheme theme) async {
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
              backgroundColor: theme.cardBg,
              contentPadding: const EdgeInsets.all(16),
              content: SizedBox(
                width: 320,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.chevron_left,
                              color: theme.textPrimary),
                          onPressed: () => setDialogState(() => selectedYear--),
                        ),
                        Text(
                          '$selectedYear',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.chevron_right,
                              color: theme.textPrimary),
                          onPressed: () => setDialogState(() => selectedYear++),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      childAspectRatio: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      children: List.generate(12, (index) {
                        final isSelected = index == selectedMonthIndex;
                        return GestureDetector(
                          onTap: () => Navigator.pop(
                            context,
                            DateTime(selectedYear, index + 1),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.accent
                                  : theme.cardInnerBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _months[index].substring(0, 3),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : theme.textPrimary,
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
    required AppTheme theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: theme.cardInnerBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: theme.cardBg,
          style: TextStyle(color: theme.textPrimary, fontSize: 14),
          icon: Icon(Icons.keyboard_arrow_down, color: theme.iconMuted),
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
