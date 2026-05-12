import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';

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
    final isMobile = Responsive.isMobile(context);
    final theme = AppTheme.of(isDarkMode);

    final pageButtons = [
      _buildPageButton(
        'Prev',
        currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
        theme,
      ),
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
        currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
        theme,
      ),
    ];

    // mobile: stack entries count above page buttons
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Showing $shownCount of $totalEntries entries',
            style: TextStyle(color: theme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 0,
            runSpacing: 8,
            children: pageButtons,
          ),
        ],
      );
    }

    // desktop: entries left, buttons right
    return Row(
      children: [
        Text(
          'Showing $shownCount of $totalEntries entries',
          style: TextStyle(color: theme.textSecondary, fontSize: 13),
        ),
        const Spacer(),
        ...pageButtons,
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
