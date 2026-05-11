import 'package:flutter/material.dart';
import '../../utils/responsive.dart';

class TimeLogsPagination extends StatelessWidget {
  final bool isDarkMode;
  final int currentPage;
  final int totalPages;
  final int totalEntries;
  final int shownCount;
  final ValueChanged<int> onPageChanged;

  const TimeLogsPagination({
    super.key,
    required this.isDarkMode,
    required this.currentPage,
    required this.totalPages,
    required this.totalEntries,
    required this.shownCount,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    final pageButtons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _navButton('Prev',
            currentPage > 1 ? () => onPageChanged(currentPage - 1) : null),
        const SizedBox(width: 6),
        ...List.generate(totalPages, (i) {
          final page = i + 1;
          final isActive = page == currentPage;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => onPageChanged(page),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF00BCD4)
                      : (isDarkMode
                          ? const Color(0xFF2C2C2C)
                          : const Color(0xFFF0F0F0)),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$page',
                  style: TextStyle(
                    color: isActive
                        ? Colors.white
                        : (isDarkMode ? Colors.white : Colors.black),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }),
        _navButton(
            'Next',
            currentPage < totalPages
                ? () => onPageChanged(currentPage + 1)
                : null),
      ],
    );

    final entryText = Text(
      'Showing $shownCount of $totalEntries entries',
      style: TextStyle(
        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        fontSize: 13,
      ),
    );

    return isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              entryText,
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: pageButtons,
              ),
            ],
          )
        : Row(
            children: [
              entryText,
              const Spacer(),
              pageButtons,
            ],
          );
  }

  Widget _navButton(String label, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: onTap != null
              ? const Color(0xFF00BCD4)
              : (isDarkMode
                  ? const Color(0xFF2C2C2C)
                  : const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: onTap != null
                ? Colors.white
                : (isDarkMode ? Colors.grey[600]! : Colors.grey[400]!),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
