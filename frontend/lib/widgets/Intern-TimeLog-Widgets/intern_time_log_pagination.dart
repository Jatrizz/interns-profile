import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class InternTimeLogPagination extends StatelessWidget {
  final bool isDarkMode;
  final int currentPage;
  final int totalPages;
  final int totalEntries;
  final int entriesPerPage;
  final int shownCount;
  final ValueChanged<int> onPageChanged;

  const InternTimeLogPagination({
    super.key,
    required this.isDarkMode,
    required this.currentPage,
    required this.totalPages,
    required this.totalEntries,
    required this.entriesPerPage,
    required this.shownCount,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(isDarkMode);
    return Row(
      children: [
        Text(
          'Showing $shownCount of $totalEntries entries',
          style: TextStyle(
            color: theme.textSecondary,
            fontSize: 13,
          ),
        ),
        const Spacer(),
        _buildPageButton(
            'Prev',
            currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
            theme),
        const SizedBox(width: 6),
        ...List.generate(totalPages, (index) {
          final page = index + 1;
          final isActive = page == currentPage;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => onPageChanged(page),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.accent : theme.cardInnerBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$page',
                  style: TextStyle(
                    color: isActive ? Colors.white : theme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }),
        _buildPageButton(
            'Next',
            currentPage < totalPages
                ? () => onPageChanged(currentPage + 1)
                : null,
            theme),
      ],
    );
  }

  Widget _buildPageButton(String label, VoidCallback? onTap, AppTheme theme) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: onTap != null ? AppTheme.accent : theme.cardInnerBg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: onTap != null ? Colors.white : theme.textMuted,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
