import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

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
    final theme = AppTheme.of(isDarkMode);
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Toggle
        Container(
          decoration: BoxDecoration(
            color: theme.cardInnerBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.divider,
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
        _buildMonthPicker(context, theme),
        _buildLabel('Status', theme),
        _buildDropdown(
          value: selectedStatus,
          items: ['All', 'Present', 'Late', 'Absent', 'Half Day', 'Weekend'],
          onChanged: onStatusChanged,
          theme: theme,
        ),
        _buildLabel('Week', theme),
        _buildDropdown(
          value: selectedWeek,
          items: ['All Weeks', 'Week 1', 'Week 2', 'Week 3', 'Week 4'],
          onChanged: onWeekChanged,
          theme: theme,
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

  Widget _buildMonthPicker(BuildContext context, AppTheme theme) {
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
            data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
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
          color: theme.cardInnerBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.divider,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedMonth,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.calendar_today,
              size: 16,
              color: theme.iconMuted,
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
    required AppTheme theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: theme.cardInnerBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.divider,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: theme.cardBg,
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 14,
          ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: theme.iconMuted,
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
